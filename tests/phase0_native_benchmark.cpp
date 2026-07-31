#include <sqlite3.h>
#include <sys/resource.h>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <numeric>
#include <string>
#include <utility>
#include <vector>

namespace {

using Clock = std::chrono::steady_clock;

long long elapsedUs(const Clock::time_point& start)
{
    return std::chrono::duration_cast<std::chrono::microseconds>(Clock::now() - start).count();
}

void row(
    const std::string& component,
    long long elapsed,
    long long operations,
    long long bytes,
    double checksum,
    const std::string& status = "ok")
{
    std::cout << "native," << component << ',' << elapsed << ',' << operations << ','
              << bytes << ',' << checksum << ',' << status << '\n';
}

} // namespace

int main()
{
    constexpr int kRows = 512;
    constexpr int kDimension = 128;
    constexpr int kTopK = 10;
    const std::filesystem::path root = std::filesystem::temp_directory_path()
        / "crexx-rag-phase0-native-benchmark.sqlite";
    std::filesystem::remove(root);

    sqlite3* db = nullptr;
    if (sqlite3_open(root.string().c_str(), &db) != SQLITE_OK) {
        return 1;
    }
    if (sqlite3_exec(db,
            "PRAGMA journal_mode=MEMORY; CREATE TABLE vectors(id INTEGER PRIMARY KEY, value BLOB NOT NULL); BEGIN IMMEDIATE;",
            nullptr, nullptr, nullptr) != SQLITE_OK) {
        return 2;
    }
    sqlite3_stmt* insert = nullptr;
    if (sqlite3_prepare_v2(db, "INSERT INTO vectors(id,value) VALUES(?,?)", -1, &insert, nullptr) != SQLITE_OK) {
        return 3;
    }

    std::vector<float> value(kDimension);
    auto totalStart = Clock::now();
    auto start = Clock::now();
    double writeChecksum = 0.0;
    for (int id = 1; id <= kRows; ++id) {
        for (int d = 0; d < kDimension; ++d) {
            value[static_cast<size_t>(d)] = static_cast<float>(((id * 17 + d * 13) % 101) - 50) / 50.0f;
        }
        writeChecksum += value[0];
        sqlite3_bind_int(insert, 1, id);
        sqlite3_bind_blob(insert, 2, value.data(), static_cast<int>(value.size() * sizeof(float)), SQLITE_TRANSIENT);
        if (sqlite3_step(insert) != SQLITE_DONE) {
            return 4;
        }
        sqlite3_reset(insert);
        sqlite3_clear_bindings(insert);
    }
    sqlite3_finalize(insert);
    if (sqlite3_exec(db, "COMMIT", nullptr, nullptr, nullptr) != SQLITE_OK) {
        return 5;
    }
    const long long sqliteWriteUs = elapsedUs(start);
    row("sqlite_write", sqliteWriteUs, kRows,
        static_cast<long long>(kRows) * kDimension * static_cast<long long>(sizeof(float)), writeChecksum);

    sqlite3_stmt* select = nullptr;
    if (sqlite3_prepare_v2(db, "SELECT id,value FROM vectors ORDER BY id", -1, &select, nullptr) != SQLITE_OK) {
        return 6;
    }
    std::vector<int> ids;
    std::vector<std::vector<unsigned char>> pages;
    ids.reserve(kRows);
    pages.reserve(kRows);
    start = Clock::now();
    long long transferBytes = 0;
    while (sqlite3_step(select) == SQLITE_ROW) {
        const int id = sqlite3_column_int(select, 0);
        const auto* blob = static_cast<const unsigned char*>(sqlite3_column_blob(select, 1));
        const int bytes = sqlite3_column_bytes(select, 1);
        ids.push_back(id);
        pages.emplace_back(blob, blob + bytes);
        transferBytes += bytes;
    }
    const long long transferUs = elapsedUs(start);
    sqlite3_finalize(select);
    row("vector_db_transfer", transferUs, kRows, transferBytes, ids.size());

    std::vector<std::vector<float>> decoded;
    decoded.reserve(kRows);
    start = Clock::now();
    double decodeChecksum = 0.0;
    for (const auto& page : pages) {
        std::vector<float> vector(static_cast<size_t>(kDimension));
        std::memcpy(vector.data(), page.data(), page.size());
        decodeChecksum += vector[0];
        decoded.push_back(std::move(vector));
    }
    const long long decodeUs = elapsedUs(start);
    row("vector_decode", decodeUs, kRows, transferBytes, decodeChecksum);

    std::vector<float> query(static_cast<size_t>(kDimension));
    for (int d = 0; d < kDimension; ++d) {
        query[static_cast<size_t>(d)] = static_cast<float>((d % 11) - 5) / 5.0f;
    }
    const double queryNorm = std::sqrt(std::inner_product(query.begin(), query.end(), query.begin(), 0.0));
    std::vector<std::pair<double, int>> scores;
    scores.reserve(kRows);
    start = Clock::now();
    double computeChecksum = 0.0;
    for (size_t i = 0; i < decoded.size(); ++i) {
        const auto& vector = decoded[i];
        const double dot = std::inner_product(vector.begin(), vector.end(), query.begin(), 0.0);
        const double norm = std::sqrt(std::inner_product(vector.begin(), vector.end(), vector.begin(), 0.0));
        const double cosine = dot / (norm * queryNorm);
        scores.emplace_back(cosine, ids[i]);
        computeChecksum += cosine;
    }
    const long long computeUs = elapsedUs(start);
    row("vector_compute", computeUs, static_cast<long long>(kRows) * kDimension, transferBytes, computeChecksum);

    start = Clock::now();
    std::partial_sort(scores.begin(), scores.begin() + kTopK, scores.end(),
        [](const auto& lhs, const auto& rhs) {
            if (lhs.first != rhs.first) {
                return lhs.first > rhs.first;
            }
            return lhs.second < rhs.second;
        });
    const long long selectionUs = elapsedUs(start);
    double selectionChecksum = 0.0;
    for (int i = 0; i < kTopK; ++i) {
        selectionChecksum += scores[static_cast<size_t>(i)].second;
    }
    row("vector_selection", selectionUs, kRows, 0, selectionChecksum);

    rusage usage {};
    getrusage(RUSAGE_SELF, &usage);
#if defined(__APPLE__)
    const long long peakBytes = usage.ru_maxrss;
#else
    const long long peakBytes = usage.ru_maxrss * 1024LL;
#endif
    row("vector_peak_memory", 0, kRows, peakBytes, peakBytes);
    row("vector_total", elapsedUs(totalStart), kRows, transferBytes, selectionChecksum);

    sqlite3_close(db);
    std::filesystem::remove(root);
    return 0;
}

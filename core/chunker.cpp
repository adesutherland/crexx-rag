#include "chunker.h"

#include <algorithm>
#include <cctype>
#include <sstream>
#include <string>
#include <vector>

namespace cprag {
namespace {

int clampOverlap(int chunkSize, int chunkOverlap)
{
    if (chunkSize <= 0 || chunkOverlap < 0) {
        return 0;
    }
    if (chunkOverlap >= chunkSize) {
        return chunkSize - 1;
    }
    return chunkOverlap;
}

std::string trimCopy(const std::string& value)
{
    const auto first = std::find_if_not(value.begin(), value.end(), [](unsigned char c) {
        return std::isspace(c) != 0;
    });
    const auto last = std::find_if_not(value.rbegin(), value.rend(), [](unsigned char c) {
        return std::isspace(c) != 0;
    }).base();
    return first >= last ? std::string() : std::string(first, last);
}

bool startsWith(const std::string& value, const std::string& prefix)
{
    return value.size() >= prefix.size() && value.compare(0, prefix.size(), prefix) == 0;
}

std::vector<std::string> splitLinesPreserveEmpty(const std::string& text)
{
    std::vector<std::string> lines;
    std::string current;
    std::istringstream stream(text);
    while (std::getline(stream, current, '\n')) {
        lines.push_back(current);
    }
    if (!text.empty() && text.back() == '\n') {
        lines.emplace_back();
    }
    return lines;
}

std::vector<std::string> splitKeepEmpty(const std::string& text, const std::string& separator)
{
    std::vector<std::string> parts;
    if (separator.empty()) {
        parts.reserve(text.size());
        for (char ch : text) {
            parts.emplace_back(1, ch);
        }
        return parts;
    }

    size_t pos = 0;
    while (true) {
        const size_t next = text.find(separator, pos);
        if (next == std::string::npos) {
            parts.push_back(text.substr(pos));
            break;
        }
        parts.push_back(text.substr(pos, next - pos));
        pos = next + separator.size();
    }
    return parts;
}

int findWordBoundary(const std::string& text, int idealPos, int maxLookback)
{
    const int searchStart = std::max(0, idealPos - maxLookback);
    for (int i = idealPos - 1; i >= searchStart; --i) {
        const char c = text[static_cast<size_t>(i)];
        if (c == ' ' || c == '\n') {
            return i + 1;
        }
    }
    return idealPos;
}

std::string extractOverlapSmart(const std::string& chunk, int overlapSize)
{
    if (overlapSize <= 0 || static_cast<int>(chunk.size()) <= overlapSize) {
        return chunk;
    }

    const int idealStart = static_cast<int>(chunk.size()) - overlapSize;
    const int searchStart = std::max(0, idealStart - 150);

    for (int i = idealStart - 1; i >= searchStart; --i) {
        const char c = chunk[static_cast<size_t>(i)];
        if (c == '\n' || c == '\r') {
            const std::string candidate = chunk.substr(static_cast<size_t>(i + 1));
            if (candidate.find(' ') != std::string::npos || candidate.size() > 3) {
                return candidate;
            }
        }
    }

    for (int i = idealStart - 1; i >= searchStart; --i) {
        if (chunk[static_cast<size_t>(i)] == '.'
            && i + 1 < static_cast<int>(chunk.size())
            && std::isspace(static_cast<unsigned char>(chunk[static_cast<size_t>(i + 1)])) != 0) {
            size_t boundary = static_cast<size_t>(i + 1);
            while (boundary < chunk.size() && std::isspace(static_cast<unsigned char>(chunk[boundary])) != 0) {
                ++boundary;
            }
            if (boundary < chunk.size()) {
                const std::string candidate = chunk.substr(boundary);
                if (candidate.size() >= 10) {
                    return candidate;
                }
            }
        }
    }

    for (int i = idealStart - 1; i >= searchStart; --i) {
        if (chunk[static_cast<size_t>(i)] == ' ') {
            const std::string candidate = chunk.substr(static_cast<size_t>(i + 1));
            if (candidate.size() >= 10) {
                return candidate;
            }
        }
    }

    return chunk.substr(chunk.size() - static_cast<size_t>(overlapSize));
}

bool isMarkdownHeader(const std::string& line)
{
    const std::string trimmed = trimCopy(line);
    size_t hashes = 0;
    while (hashes < trimmed.size() && trimmed[hashes] == '#') {
        ++hashes;
    }
    return hashes >= 1 && hashes <= 6 && (hashes == trimmed.size() || trimmed[hashes] == ' ');
}

bool isRexxCommentStart(const std::string& text)
{
    const std::string trimmed = trimCopy(text);
    return startsWith(trimmed, "/*") || startsWith(trimmed, "--");
}

std::vector<std::string> hardSplit(const std::string& text, int chunkSize, int chunkOverlap)
{
    std::vector<std::string> chunks;
    int pos = 0;
    std::string overlap;
    while (pos < static_cast<int>(text.size())) {
        std::string chunk = overlap;
        const int remaining = chunkSize - static_cast<int>(chunk.size());
        if (remaining <= 0) {
            chunks.push_back(chunk);
            overlap = extractOverlapSmart(chunk, chunkOverlap);
            continue;
        }

        int end = std::min(pos + remaining, static_cast<int>(text.size()));
        if (end < static_cast<int>(text.size())) {
            const int boundary = findWordBoundary(text, end, 50);
            if (boundary > pos) {
                end = boundary;
            }
        }
        chunk += text.substr(static_cast<size_t>(pos), static_cast<size_t>(end - pos));
        pos = end;
        if (!chunk.empty()) {
            chunks.push_back(chunk);
            overlap = chunkOverlap > 0 ? extractOverlapSmart(chunk, chunkOverlap) : std::string();
        }
    }
    return chunks;
}

std::vector<std::string> recursiveSplit(
    const std::string& text,
    int chunkSize,
    int chunkOverlap,
    const std::vector<std::string>& separators,
    size_t separatorIndex,
    ChunkFileType fileType)
{
    if (static_cast<int>(text.size()) <= chunkSize) {
        return {text};
    }
    if (separatorIndex >= separators.size()) {
        return hardSplit(text, chunkSize, chunkOverlap);
    }

    const std::string& separator = separators[separatorIndex];
    std::vector<std::string> result;
    std::string current;
    const std::vector<std::string> parts = splitKeepEmpty(text, separator);

    for (size_t partIndex = 0; partIndex < parts.size(); ++partIndex) {
        std::vector<std::string> pieces = static_cast<int>(parts[partIndex].size()) > chunkSize
            ? recursiveSplit(parts[partIndex], chunkSize, chunkOverlap, separators, separatorIndex + 1, fileType)
            : std::vector<std::string>{parts[partIndex]};

        for (size_t pieceIndex = 0; pieceIndex < pieces.size(); ++pieceIndex) {
            const bool firstPieceOfPart = pieceIndex == 0;
            std::string candidate = current;
            if (!candidate.empty() && !separator.empty() && firstPieceOfPart) {
                candidate += separator;
            }
            candidate += pieces[pieceIndex];

            if (static_cast<int>(candidate.size()) <= chunkSize) {
                current = candidate;
                continue;
            }

            if (fileType == ChunkFileType::CodeRexx
                && !current.empty()
                && (separator == "\n" || separator == "\n\n")
                && isRexxCommentStart(current)
                && !isRexxCommentStart(pieces[pieceIndex])
                && static_cast<int>(pieces[pieceIndex].size()) <= chunkSize) {
                current = candidate;
                continue;
            }

            if (!current.empty()) {
                result.push_back(current);
                current = chunkOverlap > 0 ? extractOverlapSmart(current, chunkOverlap) : std::string();
            }

            if (!current.empty() && !separator.empty() && firstPieceOfPart) {
                current += separator;
            }
            current += pieces[pieceIndex];
            if (static_cast<int>(current.size()) > chunkSize) {
                const std::vector<std::string> forced = hardSplit(current, chunkSize, chunkOverlap);
                result.insert(result.end(), forced.begin(), forced.end());
                current.clear();
            }
        }
    }

    if (!current.empty()) {
        result.push_back(current);
    }
    return result;
}

std::vector<std::string> markdownChunks(const std::string& text, int chunkSize, int chunkOverlap)
{
    std::vector<std::string> chunks;
    std::string current;
    bool currentHeaderOnly = false;
    bool lastLineWasTable = false;
    const int tableMaxChunkSize = chunkSize + chunkSize / 4;
    const std::vector<std::string> lines = splitLinesPreserveEmpty(text);

    for (size_t i = 0; i < lines.size(); ++i) {
        const bool isLast = i + 1 == lines.size();
        const bool isHeader = isMarkdownHeader(lines[i]);
        if (!current.empty() && isHeader) {
            chunks.push_back(current);
            current.clear();
            currentHeaderOnly = false;
        }

        const bool isTableRow = startsWith(trimCopy(lines[i]), "|");
        const bool nextIsTableRow = !isLast && startsWith(trimCopy(lines[i + 1]), "|");
        std::string lineWithSep = lines[i];
        if (!isLast) {
            lineWithSep.push_back('\n');
        }

        const std::string candidate = current + lineWithSep;
        if (currentHeaderOnly && static_cast<int>(candidate.size()) > chunkSize) {
            current = candidate;
            if (!trimCopy(lines[i]).empty() && !isHeader) {
                currentHeaderOnly = false;
            }
            lastLineWasTable = isTableRow;
            continue;
        }

        if (static_cast<int>(candidate.size()) <= chunkSize
            || ((isTableRow || lastLineWasTable || nextIsTableRow)
                && static_cast<int>(candidate.size()) <= tableMaxChunkSize)) {
            current = candidate;
            if (current.size() == lineWithSep.size()) {
                currentHeaderOnly = isHeader;
            } else if (currentHeaderOnly && !trimCopy(lines[i]).empty() && !isHeader) {
                currentHeaderOnly = false;
            }
            lastLineWasTable = isTableRow;
            continue;
        }

        if (!current.empty()) {
            chunks.push_back(current);
            current = chunkOverlap > 0 ? extractOverlapSmart(current, chunkOverlap) + lineWithSep : lineWithSep;
        } else {
            const std::vector<std::string> forced = hardSplit(lineWithSep, chunkSize, chunkOverlap);
            chunks.insert(chunks.end(), forced.begin(), forced.end());
        }
        currentHeaderOnly = isHeader && current == lineWithSep;
        lastLineWasTable = isTableRow;
    }

    if (!current.empty()) {
        chunks.push_back(current);
    }
    return chunks;
}

std::vector<std::string> separatorsForType(ChunkFileType fileType)
{
    if (fileType == ChunkFileType::CodeRexx) {
        return {
            "\n::routine", "\n::ROUTINE",
            "\n::method", "\n::METHOD",
            "\n::requires", "\n::REQUIRES",
            " Return\n", " RETURN\n", " return\n",
            " Exit\n", " EXIT\n", " exit\n",
            "\n\n", "\n", ":\n", " ", ""};
    }
    return {"\n\n", "\n", " ", ""};
}

} // namespace

std::vector<std::string> chunkText(
    const std::string& text,
    int chunkSize,
    int chunkOverlap,
    ChunkFileType fileType)
{
    if (text.empty()) {
        return {};
    }
    if (chunkSize <= 0 || static_cast<int>(text.size()) <= chunkSize) {
        return {text};
    }

    const int effectiveOverlap = clampOverlap(chunkSize, chunkOverlap);
    if (fileType == ChunkFileType::Markdown) {
        return markdownChunks(text, chunkSize, effectiveOverlap);
    }
    return recursiveSplit(text, chunkSize, effectiveOverlap, separatorsForType(fileType), 0, fileType);
}

} // namespace cprag


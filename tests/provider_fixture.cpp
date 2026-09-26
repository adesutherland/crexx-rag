#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <poll.h>
#include <signal.h>
#include <sys/socket.h>
#include <unistd.h>

#include <chrono>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>
#include <unordered_map>

namespace {

bool send_all(int client, const std::string& value)
{
    std::size_t sent = 0;
    while (sent < value.size()) {
        const ssize_t count = ::send(client, value.data() + sent, value.size() - sent, 0);
        if (count <= 0) return false;
        sent += static_cast<std::size_t>(count);
    }
    return true;
}

std::string request_path(const std::string& request)
{
    const std::size_t first_space = request.find(' ');
    if (first_space == std::string::npos) return {};
    const std::size_t second_space = request.find(' ', first_space + 1);
    if (second_space == std::string::npos) return {};
    return request.substr(first_space + 1, second_space - first_space - 1);
}

std::string header_value(const std::string& request, const std::string& name)
{
    const std::string wanted = name + ":";
    const std::size_t start = request.find(wanted);
    if (start == std::string::npos) return {};
    const std::size_t value_start = request.find_first_not_of(" \t", start + wanted.size());
    if (value_start == std::string::npos) return {};
    const std::size_t end = request.find("\r\n", value_start);
    return request.substr(value_start, end == std::string::npos ? end : end - value_start);
}

std::string escaped_candidate_for_label(const std::string& request, const std::string& label)
{
    const std::string label_marker = "\\\"label\\\":\\\"" + label + "\\\"";
    const std::size_t label_pos = request.find(label_marker);
    if (label_pos == std::string::npos) return {};
    const std::string id_marker = "\\\"candidate_id\\\":\\\"";
    const std::size_t id_pos = request.rfind(id_marker, label_pos);
    if (id_pos == std::string::npos) return {};
    const std::size_t value_start = id_pos + id_marker.size();
    const std::size_t value_end = request.find("\\\"", value_start);
    if (value_end == std::string::npos) return {};
    return request.substr(value_start, value_end - value_start);
}

std::string escaped_citation(const std::string& request)
{
    if (request.find("crexx-rag.answer-context/3") != std::string::npos
        && request.find("\\\"citation\\\":\\\"E1\\\"") != std::string::npos) return "E1";
    const std::size_t value_start = request.find("crexx-rag:");
    if (value_start == std::string::npos) return {};
    const std::size_t value_end = request.find("\\\"", value_start);
    if (value_end == std::string::npos) return {};
    return request.substr(value_start, value_end - value_start);
}

std::string json_string(const std::string& value)
{
    std::string output = "\"";
    for (const char ch : value) {
        if (ch == '\\' || ch == '"') output.push_back('\\');
        output.push_back(ch);
    }
    output.push_back('"');
    return output;
}

std::string escaped_field_after(const std::string& request, const std::string& field,
                                std::size_t after = 0)
{
    const std::string marker = "\\\"" + field + "\\\":\\\"";
    const std::size_t start = request.find(marker, after);
    if (start == std::string::npos) return {};
    const std::size_t value_start = start + marker.size();
    const std::size_t end = request.find("\\\"", value_start);
    return end == std::string::npos ? std::string{} : request.substr(value_start, end - value_start);
}

std::string last_escaped_field(const std::string& request, const std::string& field)
{
    const std::string marker = "\\\"" + field + "\\\":\\\"";
    const std::size_t start = request.rfind(marker);
    return start == std::string::npos ? std::string{}
        : escaped_field_after(request, field, start);
}

std::string escaped_page_cursor(const std::string& request, const std::string& kind)
{
    // History order is not a cursor contract. Select the furthest page of
    // this kind by its explicit after key, then use that page's next cursor.
    const std::string marker = "\\\"kind\\\":\\\"" + kind + "\\\"";
    std::string furthest_after;
    std::string cursor;
    for (std::size_t page = request.find(marker); page != std::string::npos;
         page = request.find(marker, page + marker.size())) {
        const std::string after = escaped_field_after(request, "after", page);
        const std::string next = escaped_field_after(request, "next_cursor", page);
        if (!next.empty() && (cursor.empty() || after > furthest_after)) {
            furthest_after = after;
            cursor = next;
        }
    }
    return cursor;
}

std::string backlog_resolution(const std::string& action, const std::string& object_id,
                               const std::string& question = {}, const std::string& evidence = "[]",
                               const std::string& relationship = {})
{
    return "{\"action\":" + json_string(action) + ",\"object_id\":" + json_string(object_id)
        + ",\"target_concept_id\":" + json_string(relationship.empty() ? "" : "C2")
        + ",\"canonical_label\":\"\",\"concept_type\":\"\",\"successors\":[],\"reason\":\"The exact late source passage supports this directed dependency.\",\"evidence\":"
        + evidence + ",\"effective_from\":\"\",\"effective_to\":\"\",\"qualifiers_json\":\"{}\",\"question\":"
        + json_string(question) + ",\"dispositions\":[],\"relationship_type\":"
        + json_string(relationship) + ",\"resolution_text\":\"\"}";
}

const char* reason_phrase(int status)
{
    if (status == 200) return "OK";
    if (status == 400) return "Bad Request";
    if (status == 429) return "Too Many Requests";
    if (status == 503) return "Service Unavailable";
    return "Error";
}

} // namespace

int main(int argc, char** argv)
{
    ::signal(SIGPIPE, SIG_IGN);
    const int port = argc > 1 ? std::atoi(argv[1]) : 18991;
    const int requests = argc > 2 ? std::atoi(argv[2]) : 4;
    const std::string scenario = argc > 3 ? argv[3] : "default";
    const int server = ::socket(AF_INET, SOCK_STREAM, 0);
    if (server < 0) return 1;
    int reuse = 1;
    ::setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    sockaddr_in address {};
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    address.sin_port = htons(static_cast<uint16_t>(port));
    if (::bind(server, reinterpret_cast<sockaddr*>(&address), sizeof(address)) != 0
        || ::listen(server, requests) != 0) {
        ::close(server);
        return 2;
    }
    socklen_t address_size = sizeof(address);
    if (::getsockname(server, reinterpret_cast<sockaddr*>(&address), &address_size) != 0) return 2;
    std::cout << "READY " << ntohs(address.sin_port) << std::endl;

    if (scenario == "zero-outbound" && requests == 0) {
        pollfd unexpected {server, POLLIN, 0};
        if (::poll(&unexpected, 1, 1000) > 0) {
            const int client = ::accept(server, nullptr, nullptr);
            if (client >= 0) ::close(client);
            std::cout << "SUMMARY scenario=zero-outbound connections=1" << std::endl;
            ::close(server);
            return 5;
        }
        std::cout << "SUMMARY scenario=zero-outbound connections=0" << std::endl;
        ::close(server);
        return 0;
    }

    int close_requests = 0;
    int paired_client = -1;
    std::string paired_response;
    int barrier_pairs = 0;
    int first_pass_extractions = 0;
    int large_acquisition_steps = 0;
    int large_target_stage = 0;
    int large_target_passage_pages = 0;
    int large_target_catalogue_pages = 0;
    std::string large_target_citation;
    std::string large_target_evidence;
    int completed_requests = 0;
    std::unordered_map<std::string, int> retry_attempts;
    std::string embedding_retry_target;
    for (int index = 0; index < requests; ++index) {
        pollfd ready {server, POLLIN, 0};
        // Library setup and separately compiled VM fixtures can precede a
        // request. This is the harness idle lifetime, not a provider-call
        // timeout; the product's timeout/backoff assertions remain unchanged.
        const int idle_ms = scenario == "embedding-exhaustion" ? 120000 : 60000;
        if (::poll(&ready, 1, idle_ms) <= 0) {
            std::cerr << "IDLE_TIMEOUT scenario=" << scenario
                      << " request=" << index + 1 << '/' << requests
                      << " idle_ms=" << idle_ms << std::endl;
            ::close(server);
            return 3;
        }
        const int client = ::accept(server, nullptr, nullptr);
        if (client < 0) {
            ::close(server);
            return 4;
        }
        std::string request;
        char input[4096];
        for (;;) {
            const ssize_t received = ::recv(client, input, sizeof(input), 0);
            if (received <= 0) break;
            request.append(input, static_cast<std::size_t>(received));
            const std::size_t header_end = request.find("\r\n\r\n");
            if (header_end != std::string::npos) {
                const std::size_t content_length_pos = request.find("Content-Length:");
                std::size_t content_length = 0;
                if (content_length_pos != std::string::npos) {
                    content_length = static_cast<std::size_t>(std::strtoull(
                        request.c_str() + content_length_pos + 15, nullptr, 10));
                }
                if (request.size() >= header_end + 4 + content_length) break;
            }
        }

        const std::string path = request_path(request);
        // Optional test-only capture of JSON bodies, excluding credential headers.
        if (const char* directory = std::getenv("CREXXRAG_FIXTURE_CAPTURE_DIR")) {
            const std::size_t body_start = request.find("\r\n\r\n");
            if (body_start == std::string::npos) return 10;
            std::ofstream capture(std::string(directory) + "/" + std::to_string(::getpid())
                + "-" + std::to_string(index) + ".json", std::ios::binary);
            capture << request.substr(body_start + 4);
            if (!capture) return 10;
        }
        std::cout << "REQUEST " << path << std::endl;
        if (request.find("Connection: close") != std::string::npos) ++close_requests;
        std::string body;
        std::string extra_headers;
        int http_status = 200;
        if (path == "/openai/v1/responses") {
            const bool valid_auth = request.find("Authorization: Bearer synthetic-openai-key") != std::string::npos;
            const bool valid_shape = request.find("\"model\":\"gpt-5.6-luna\"") != std::string::npos
                && request.find("\"type\":\"input_image\"") != std::string::npos
                && request.find("\"image_url\":\"https://fixture.invalid/image.png\"") != std::string::npos
                && request.find("\"temperature\":0") != std::string::npos
                && request.find("\"format\":{\"type\":\"json_schema\"") != std::string::npos;
            if (!valid_auth || !valid_shape) {
                http_status = 400;
                body = R"({"error":{"message":"OpenAI Responses request shape mismatch"}})";
            } else {
                body = R"({"id":"resp-openai-001","model":"gpt-5.6-luna","status":"completed","output":[{"type":"message","content":[{"type":"output_text","text":"{\"answer\":\"openai\"}"}]}],"usage":{"input_tokens":11,"output_tokens":5}})";
            }
        } else if (path == "/openai/v1/embeddings") {
            const bool valid_auth = request.find("Authorization: Bearer synthetic-openai-key") != std::string::npos;
            const bool valid_shape = request.find("\"model\":\"text-embedding-3-small\"") != std::string::npos
                && request.find("\"input\":[\"index one\",\"index two\"]") != std::string::npos
                && request.find("\"dimensions\":3") != std::string::npos;
            if (!valid_auth || !valid_shape) {
                http_status = 400;
                body = R"({"error":{"message":"OpenAI embedding request shape mismatch"}})";
            } else {
                body = R"({"data":[{"index":0,"embedding":[0.2,0.3,0.4]},{"index":1,"embedding":[-0.2,-0.3,-0.4]}],"usage":{"prompt_tokens":6,"total_tokens":6}})";
            }
        } else if (path == "/anthropic/v1/messages") {
            const bool valid_auth = request.find("x-api-key: synthetic-anthropic-key") != std::string::npos
                && request.find("anthropic-version: 2023-06-01") != std::string::npos;
            const bool valid_shape = request.find("\"model\":\"claude-haiku-4-5\"") != std::string::npos
                && request.find("\"type\":\"document\"") != std::string::npos
                && request.find("\"url\":\"https://fixture.invalid/source.pdf\"") != std::string::npos
                && request.find("\"temperature\":0") != std::string::npos
                && request.find("\"output_config\":{\"format\":{\"type\":\"json_schema\"") != std::string::npos;
            if (!valid_auth || !valid_shape) {
                http_status = 400;
                body = R"({"error":{"message":"Anthropic Messages request shape mismatch"}})";
            } else {
                body = R"({"id":"msg-anthropic-001","model":"claude-haiku-4-5","content":[{"type":"text","text":"{\"answer\":\"anthropic\"}"}],"stop_reason":"end_turn","usage":{"input_tokens":12,"output_tokens":5}})";
            }
        } else if (path.find("/gemini/v1beta/models/gemini-3.5-flash-lite:generateContent") != std::string::npos) {
            const bool valid_auth = request.find("x-goog-api-key: synthetic-product-gemini-key") != std::string::npos;
            const bool valid_structured = request.find("\"responseMimeType\":\"application/json\"") != std::string::npos
                && request.find("\"responseJsonSchema\"") != std::string::npos
                && request.find("\"additionalProperties\":false") != std::string::npos;
            if (request.find("crexx-rag.library-report-context/1") != std::string::npos) {
                const std::string citation = escaped_citation(request);
                const bool valid_report = valid_auth && valid_structured && !citation.empty()
                    && request.find("Summarize only the supplied cREXX-RAG library report context") != std::string::npos
                    && request.find("\"overview\"") != std::string::npos
                    && request.find("\"subjects\"") != std::string::npos;
                if (!valid_report) {
                    http_status = 400;
                    body = R"({"error":{"message":"product Gemini report request shape mismatch"}})";
                } else {
                    const std::string returned_citation = scenario == "product-report-invalid"
                        ? "crexx-rag:unknown-report-citation"
                        : citation;
                    const std::string narrative = "{\"overview\":\"The library covers a documented service dependency.\",\"citations\":[\""
                        + returned_citation
                        + "\"],\"subjects\":[{\"label\":\"Service dependency\",\"description\":\"BillingService is linked to CustomerDatabase in the supplied passage.\",\"citations\":[\""
                        + returned_citation + "\"]}]}";
                    body = "{\"responseId\":\"product-gemini-report-001\",\"candidates\":[{\"content\":{\"parts\":[{\"text\":"
                        + json_string(narrative)
                        + "}]},\"finishReason\":\"STOP\"}],\"usageMetadata\":{\"promptTokenCount\":240,\"candidatesTokenCount\":48}}";
                }
            } else if (request.find("Durable resolution input:") != std::string::npos) {
                const bool correcting = request.find("Citation correction (one attempt)") != std::string::npos;
                if (scenario == "product-backlog-upgrade" && request.find("\"question\",\"dispositions\"") == std::string::npos) {
                    http_status = 400;
                    body = R"({"error":{"message":"Invalid schema for response_format codex_output_schema: Missing dispositions.","type":"invalid_request_error","code":"invalid_json_schema","param":"text.format.schema"}})";
                } else if (!valid_auth || !valid_structured || (!correcting && request.find("maintenance-resolution") == std::string::npos)
                    || (scenario != "product-backlog-advanced" && scenario != "product-backlog-correction-advanced" && scenario != "product-backlog-upgrade" && scenario != "product-backlog-large-acquisition" && scenario != "product-backlog-large-target" && scenario != "product-first-pass" && request.find("fixture-resolution-prompt") == std::string::npos)
                    || (!correcting && request.find("Reference contract:") == std::string::npos)) {
                    http_status = 400;
                    body = R"({"error":{"message":"product Gemini resolution request shape mismatch"}})";
                } else {
                    std::string resolution = scenario == "product-backlog-malformed"
                        ? R"({"action":"synthetic-product-gemini-key"})"
                        : scenario == "product-backlog-rejected"
                        ? R"({"action":"retain","object_id":"fixture-note","target_concept_id":"","canonical_label":"","concept_type":"","successors":[],"reason":"synthetic-product-gemini-key","evidence":[{"evidence_id":"fixture-note-link","quote":"An unsupported invented quotation."}],"effective_from":"","effective_to":"","qualifiers_json":"{}","question":"","dispositions":[],"relationship_type":"","resolution_text":""})"
                        : R"({"action":"retain","object_id":"fixture-note","target_concept_id":"","canonical_label":"","concept_type":"","successors":[],"reason":"The independently quoted passage answers the note.","evidence":[{"evidence_id":"fixture-note-link","quote":"billingservice depends on customerdatabase."}],"effective_from":"","effective_to":"","qualifiers_json":"{}","question":"","dispositions":[],"relationship_type":"","resolution_text":""})";
                    if (scenario == "product-backlog-large-acquisition") {
                        ++large_acquisition_steps;
                        resolution = large_acquisition_steps == 1
                            ? R"({"action":"inspect","object_id":"","target_concept_id":"","canonical_label":"","concept_type":"","successors":[],"reason":"Inspect catalogue.","evidence":[],"effective_from":"","effective_to":"","qualifiers_json":"{}","question":"catalogue","dispositions":[],"relationship_type":"","resolution_text":""})"
                            : R"({"action":"acquisition-wait","object_id":"","target_concept_id":"","canonical_label":"","concept_type":"","successors":[],"reason":"The inspected catalogue prefix does not justify a change across the remaining subject.","evidence":[],"effective_from":"","effective_to":"","qualifiers_json":"{}","question":"Inspect remaining catalogue candidates and source passages","dispositions":[],"relationship_type":"","resolution_text":"Only the first catalogue page was inspected; no full-subject assessment was made."})";
                    }
                    if (scenario == "product-backlog-large-target") {
                        if (large_target_stage == 0) {
                            resolution = backlog_resolution("inspect", "", "passages");
                            large_target_stage = 1;
                            ++large_target_passage_pages;
                        } else if (large_target_stage == 1) {
                            const std::size_t late = request.find("\\\"evidence_id\\\":\\\"zz-late-subject\\\"");
                            if (late != std::string::npos) {
                                large_target_citation = escaped_field_after(request, "context_citation", late);
                                if (large_target_citation.empty()) return 6;
                                resolution = backlog_resolution("inspect", "", "catalogue");
                                large_target_stage = 2;
                                ++large_target_catalogue_pages;
                            } else {
                                const std::string cursor = escaped_page_cursor(request, "passages");
                                if (cursor.empty() || large_target_passage_pages >= 4) return 6;
                                resolution = backlog_resolution("inspect", cursor, "passages");
                                ++large_target_passage_pages;
                            }
                        } else if (large_target_stage == 2) {
                            if (request.find("\\\"concept_id\\\":\\\"zz-target\\\"") != std::string::npos) {
                                resolution = backlog_resolution("inspect", "zz-target", "catalogue-target");
                                large_target_stage = 3;
                            } else {
                                const std::string cursor = escaped_page_cursor(request, "catalogue");
                                if (cursor.empty() || large_target_catalogue_pages >= 4) return 6;
                                resolution = backlog_resolution("inspect", cursor, "catalogue");
                                ++large_target_catalogue_pages;
                            }
                        } else if (large_target_stage == 3) {
                            resolution = backlog_resolution("read", large_target_citation);
                            large_target_stage = 4;
                        } else if (large_target_stage == 4) {
                            if (request.find("\\\"evidence_id\\\":\\\"E1\\\"") == std::string::npos
                                || request.find("\\\"concept_id\\\":\\\"C2\\\"") == std::string::npos) return 6;
                            large_target_evidence = "E1";
                            resolution = backlog_resolution("propose-relationship", "S1", "",
                                "[{\"evidence_id\":" + json_string(large_target_evidence)
                                + ",\"quote\":\"An invented dependency quotation.\"}]", "depends-on");
                            large_target_stage = 5;
                        } else if (large_target_stage == 5) {
                            if (!correcting || request.find("An invented dependency quotation.") == std::string::npos) return 6;
                            resolution = backlog_resolution("propose-relationship", "S1", "",
                                "[{\"evidence_id\":" + json_string(large_target_evidence)
                                + ",\"quote\":\"PlatformService depends on AzureStore.\"}]", "depends-on");
                            large_target_stage = 6;
                        } else return 6;
                    }
                    if (scenario == "product-backlog-advanced" || scenario == "product-backlog-upgrade"
                        || scenario == "product-first-pass") {
                        if (request.find("Resolve the maintenance question using validated source evidence") == std::string::npos
                            || request.find("advanced-resolver") == std::string::npos
                            || request.find("final reasoning route") == std::string::npos
                            || request.find("prompt_sha256") == std::string::npos) return 6;
                        resolution = R"({"action":"no-change","object_id":"","target_concept_id":"","canonical_label":"","concept_type":"","successors":[],"reason":"The retained evidence does not justify an additional change.","evidence":[],"effective_from":"","effective_to":"","qualifiers_json":"{}","question":"","dispositions":[],"relationship_type":"","resolution_text":""})";
                        if (scenario == "product-first-pass")
                            resolution = R"({"action":"extract","object_id":"","target_concept_id":"","canonical_label":"","concept_type":"","successors":[],"reason":"A corrected typed extraction can assess the source passage.","evidence":[],"effective_from":"","effective_to":"","qualifiers_json":"{}","question":"","dispositions":[],"relationship_type":"","resolution_text":""})";
                    }
                    if (scenario.rfind("product-backlog-correction", 0) == 0) {
                        if (request.find("Never insert ellipses") == std::string::npos
                            || request.find("Selected source spans") == std::string::npos
                            || (correcting && (request.find("selected connection") == std::string::npos
                                || request.find("Unsupported original quotation.") == std::string::npos
                                || request.find("\"role\":\"model\"") == std::string::npos))) return 6;
                        if (!correcting || scenario == "product-backlog-correction-failed") {
                            const std::string original = "billingservice depends on customerdatabase.";
                            resolution.replace(resolution.find(original), original.size(),
                                correcting ? "Unsupported correction quotation." : "Unsupported original quotation.");
                        }
                    }
                    if (request.find("Reference contract:") != std::string::npos || correcting) {
                        auto position = resolution.find("fixture-note-link");
                        if (position != std::string::npos) resolution.replace(position, std::string("fixture-note-link").size(), "E1");
                        position = resolution.find("fixture-note");
                        if (position != std::string::npos) resolution.replace(position, std::string("fixture-note").size(), "S1");
                    }
                    body = "{\"responseId\":\"product-gemini-resolution-001\",\"candidates\":[{\"content\":{\"parts\":[{\"text\":"
                        + json_string(resolution)
                        + "}]},\"finishReason\":\"STOP\"}],\"usageMetadata\":{\"promptTokenCount\":210,\"candidatesTokenCount\":64}}";
                }
            } else if (request.find("crexx-rag.answer-context/2") != std::string::npos
                       || request.find("crexx-rag.answer-context/3") != std::string::npos) {
                const std::string citation = escaped_citation(request);
                const bool valid_answer = valid_auth && valid_structured && !citation.empty()
                    && (scenario.find("product-query") != 0 || request.find("\\\"citation\\\":\\\"E1\\\"") != std::string::npos)
                    && (scenario.find("product-provider-smoke") != 0
                        || (request.find("crexx-rag.answer-context/2") != std::string::npos
                            && citation.rfind("crexx-rag:", 0) == 0))
                    && request.find("only citation IDs present") != std::string::npos
                    && request.find("grounding") != std::string::npos;
                if (!valid_answer) {
                    http_status = 400;
                    body = R"({"error":{"message":"product Gemini answer request shape mismatch"}})";
                } else {
                    std::string citations = "[\"" + citation + "\"]";
                    std::string grounding = "supported";
                    std::string answer_text = "BillingService depends on CustomerDatabase.";
                    if (scenario == "product-query-insufficient") {
                        citations = "[]";
                        grounding = "insufficient";
                        answer_text = "The supplied evidence does not answer the question.";
                    }
                    if (scenario == "product-query-partial") {
                        grounding = "partial";
                        answer_text = "The evidence establishes the documented dependency, but does not establish its operational impact.";
                    }
                    if (scenario == "product-query-invalid" || scenario == "product-provider-smoke-invalid") {
                        if (index == 0) citations = "[\"crexx-rag:unknown-citation\"]";
                        if (index == 1) citations = "[\"" + citation + "\",\"" + citation + "\"]";
                        if (index == 2) citations = "[]";
                    }
                    const std::string answer = "{\"grounding\":\"" + grounding + "\",\"answer\":"
                        + json_string(answer_text) + ",\"citations\":" + citations
                        + (scenario == "product-query-invalid" && index == 3 ? ",\"extra\":true}" : "}");
                    body = "{\"responseId\":\"product-gemini-answer-001\",\"candidates\":[{\"content\":{\"parts\":[{\"text\":"
                        + json_string(answer)
                        + "}]},\"finishReason\":\"STOP\"}],\"usageMetadata\":{\"promptTokenCount\":210,\"candidatesTokenCount\":"
                        + (scenario == "product-query-invalid" && index == 4 ? "1025" : "32") + "}}";
                }
            } else {
                const std::string source_id = escaped_candidate_for_label(request, "billingservice");
                const std::string target_id = escaped_candidate_for_label(request, "customerdatabase");
                const bool improvement = request.find("improve-extraction") != std::string::npos;
                const bool valid_output_reservation =
                    request.find("\"maxOutputTokens\":512") != std::string::npos
                    || request.find("\"maxOutputTokens\":1024") != std::string::npos
                    || request.find("\"maxOutputTokens\":2048") != std::string::npos
                    || request.find("\"maxOutputTokens\":4096") != std::string::npos;
                if (!valid_auth || !valid_structured || request.find("crexx-rag.work-input/1") == std::string::npos
                    || request.find("crexx-rag.discovery-context/1") == std::string::npos
                    || request.find("crexx-rag.glossary/1") == std::string::npos
                    || request.find("Maximum mentions: 16; relationships: 16; notes:") == std::string::npos
                    || !valid_output_reservation
                    || (scenario != "product-first-pass" && (source_id.empty() || target_id.empty()))) {
                    http_status = 400;
                    body = R"({"error":{"message":"product Gemini extraction request shape mismatch"}})";
                } else {
                    std::string proposal;
                    if (scenario == "product-first-pass" && improvement && ++first_pass_extractions <= 2) {
                        proposal = R"({"mentions":[{"label":"BillingService","canonical_label":"BillingService","concept_type":"application-component","evidence_quote":"An invented quotation.","aliases":[]}],"relationships":[],"notes":[]})";
                    } else if (improvement) {
                        proposal =
                            "{\"mentions\":[],\"relationships\":[],\"notes\":["
                            "{\"kind\":\"insight\",\"text\":\"The repeated dependency deserves explicit validation.\",\"importance_millionths\":820000,\"uncertainty_millionths\":280000,\"next_action\":\"Compare the two independently cited dependency statements.\",\"evidence_quote\":\"BillingService depends on CustomerDatabase.\"}]}";
                    } else if (scenario == "product-extraction-malformed") {
                        proposal = "{\"mentions\":[";
                    } else if (scenario == "product-extraction-invalid-span") {
                        proposal =
                            "{\"mentions\":["
                            "{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"synthetic-product-gemini-key invented quotation\",\"aliases\":[]},"
                            "{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]}"
                            "],\"relationships\":[],\"notes\":[]}";
                    } else if (scenario == "product-extraction-unknown-type") {
                        proposal =
                            "{\"mentions\":["
                            "{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"unknown-component\",\"evidence_quote\":\"BillingService\",\"aliases\":[]},"
                            "{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]}"
                            "],\"relationships\":[],\"notes\":[]}";
                    } else if (scenario == "product-extraction-unknown-relationship") {
                        proposal =
                            "{\"mentions\":["
                            "{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"BillingService\",\"aliases\":[]},"
                            "{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]}"
                            "],\"relationships\":["
                            "{\"source_mention\":0,\"relationship_type\":\"unknown-relationship\",\"target_mention\":1,\"evidence_quote\":\"BillingService depends on CustomerDatabase.\",\"confidence_millionths\":940000}],\"notes\":[]}";
                    } else {
                        proposal =
                            "{\"mentions\":["
                            "{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"BillingService\",\"aliases\":[]},"
                            "{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]},"
                            "{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"Again, BillingService depends on CustomerDatabase.\",\"aliases\":[]},"
                            "{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"Again, BillingService depends on CustomerDatabase.\",\"aliases\":[]}"
                            "],\"relationships\":["
                            "{\"source_mention\":0,\"relationship_type\":\"depends-on\",\"target_mention\":1,\"evidence_quote\":\"BillingService depends on CustomerDatabase.\",\"confidence_millionths\":940000},"
                            "{\"source_mention\":2,\"relationship_type\":\"depends-on\",\"target_mention\":3,\"evidence_quote\":\"Again, BillingService depends on CustomerDatabase.\",\"confidence_millionths\":930000}],\"notes\":[]}";
                    }
                    // The fixture has no historical or bibliographic assertions.
                    if (request.find("crexx-rag.support-assessment/1") != std::string::npos) {
                        const std::string annotation = R"fixture(,"assessment":{"temporal":{"schema":"crexx-rag.period/1","kind":"unknown","start":{"value":"","precision":"unresolved","certainty":"stated","calendar":"unspecified","constraint":"on","earliest":"","latest":""},"end":{"value":"","precision":"unresolved","certainty":"stated","calendar":"unspecified","constraint":"on","earliest":"","latest":""},"end_condition":"unknown"},"temporal_quote":"","modality":"asserted","stance":"assertion","directness":"direct","polarity":"support","voice":"","voice_quote":"","voice_description_id":"","origin":"unknown","origin_quote":"","asserted_period":{"schema":"crexx-rag.period/1","kind":"unknown","start":{"value":"","precision":"unresolved","certainty":"stated","calendar":"unspecified","constraint":"on","earliest":"","latest":""},"end":{"value":"","precision":"unresolved","certainty":"stated","calendar":"unspecified","constraint":"on","earliest":"","latest":""},"end_condition":"unknown"},"asserted_quote":"","asserted_description_id":"","derivation_ids":[]})fixture";
                        const std::string marker = "\"confidence_millionths\":";
                        std::size_t cursor = 0;
                        while ((cursor = proposal.find(marker, cursor)) != std::string::npos) {
                            cursor += marker.size();
                            while (cursor < proposal.size() && proposal[cursor] >= '0' && proposal[cursor] <= '9') ++cursor;
                            proposal.insert(cursor, annotation);
                            cursor += annotation.size();
                        }
                    }
                    body = "{\"responseId\":\"product-gemini-extract-001\",\"candidates\":[{\"content\":{\"parts\":[{\"text\":"
                        + json_string(proposal)
                        + "}]},\"finishReason\":\"STOP\"}],\"usageMetadata\":{\"promptTokenCount\":180,\"candidatesTokenCount\":60}}";
                }
            }
        } else if (path.find("/gemini/v1beta/models/gemini-embedding-2:embedContent") != std::string::npos) {
            const bool valid_auth = request.find("x-goog-api-key: synthetic-product-gemini-key") != std::string::npos;
            const bool valid_shape = request.find("\"outputDimensionality\":768") != std::string::npos
                && (scenario == "embedding-scale" || request.find("BillingService depends on CustomerDatabase") != std::string::npos
                    || request.find("What does BillingService depend on?") != std::string::npos);
            if (!valid_auth || !valid_shape) {
                http_status = 400;
                body = R"({"error":{"message":"product Gemini embedding request shape mismatch"}})";
            } else {
                body = "{\"embedding\":{\"values\":[";
                for (int dimension = 0; dimension < 768; ++dimension) {
                    if (dimension != 0) body += ',';
                    body += dimension % 2 == 0 ? "0.03125" : "-0.03125";
                }
                body += "]},\"usageMetadata\":{\"promptTokenCount\":24}}";
                if (scenario == "embedding-recovery" || scenario == "embedding-exhaustion") {
                    const std::string identity = header_value(request, "Idempotency-Key");
                    if (embedding_retry_target.empty()) embedding_retry_target = identity;
                    const int attempt = ++retry_attempts[identity];
                    if (identity == embedding_retry_target && (attempt <= 2 || scenario == "embedding-exhaustion")) {
                        http_status = (scenario == "embedding-exhaustion" && attempt > 2) ? 503 : 429;
                        if (attempt == 1) extra_headers = "Retry-After: 1\r\n";
                        body = R"({"error":{"message":"synthetic embedding rate limit"}})";
                    }
                    const auto timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(
                        std::chrono::system_clock::now().time_since_epoch()).count();
                    std::cout << "EMBEDDING_CALL identity=" << identity << " attempt=" << attempt
                              << " status=" << http_status << " epoch_ms=" << timestamp << std::endl;
                }
            }
        } else if (path.find("/gemini/v1beta/models/gemini-2.5-flash-lite:generateContent") != std::string::npos) {
            const bool valid_auth = request.find("x-goog-api-key: synthetic-gemini-key") != std::string::npos;
            const bool valid_shape = request.find("\"fileData\":{\"mimeType\":\"audio/wav\",\"fileUri\":\"https://fixture.invalid/audio.wav\"") != std::string::npos
                && request.find("\"temperature\":0") != std::string::npos
                && request.find("\"responseMimeType\":\"application/json\"") != std::string::npos
                && request.find("\"responseJsonSchema\"") != std::string::npos;
            if (!valid_auth || !valid_shape) {
                http_status = 400;
                body = R"({"error":{"message":"Gemini generateContent request shape mismatch"}})";
            } else {
                body = R"({"responseId":"gemini-response-001","candidates":[{"content":{"parts":[{"text":"{\"answer\":\"gemini\"}"}]},"finishReason":"STOP"}],"usageMetadata":{"promptTokenCount":13,"candidatesTokenCount":5}})";
            }
        } else if (path.find("/gemini/v1beta/models/gemini-embedding-2:batchEmbedContents") != std::string::npos) {
            const bool valid_auth = request.find("x-goog-api-key: synthetic-gemini-key") != std::string::npos;
            const bool valid_shape = request.find("\"model\":\"models/gemini-embedding-2\"") != std::string::npos
                && request.find("\"outputDimensionality\":3") != std::string::npos
                && request.find("\"text\":\"vector one\"") != std::string::npos
                && request.find("\"text\":\"vector two\"") != std::string::npos;
            if (!valid_auth || !valid_shape) {
                http_status = 400;
                body = R"({"error":{"message":"Gemini embedding request shape mismatch"}})";
            } else {
                body = R"({"embeddings":[{"values":[0.3,0.4,0.5]},{"values":[-0.3,-0.4,-0.5]}],"usageMetadata":{"promptTokenCount":4}})";
            }
        } else if (path == "/v1/chat/completions") {
            if (request.find("\"model\":\"local-structured-") != std::string::npos) {
                const bool valid_shape = request.find("Authorization: Bearer synthetic-local-key") != std::string::npos
                    && request.find(R"("messages":[{"role":"system","content":"Return the requested structure."},{"role":"user","content":"Classify Edinburgh."},{"role":"assistant","content":"{\"label\":\"wrong\"}"},{"role":"user","content":"Correct the label using the evidence."}])") != std::string::npos
                    && request.find(R"("max_tokens":64)") != std::string::npos
                    && request.find(R"("temperature":0)") != std::string::npos
                    && request.find(R"("response_format":{"type":"json_schema","json_schema":{"name":"cprag_response","strict":true,"schema":{"type":"object","properties":{"label":{"type":"string","enum":["place"]}},"required":["label"],"additionalProperties":false}}})") != std::string::npos;
                if (!valid_shape) {
                    http_status = 400;
                    body = R"({"error":{"message":"local structured generation request shape mismatch"}})";
                } else {
                    std::string content = R"({"label":"place"})";
                    std::string finish = "stop";
                    if (request.find(R"("model":"local-structured-2")") != std::string::npos) content = "not JSON";
                    if (request.find(R"("model":"local-structured-3")") != std::string::npos) content = R"({"other":"invented"})";
                    if (request.find(R"("model":"local-structured-4")") != std::string::npos) finish = "length";
                    body = "{\"id\":\"local-structured-001\",\"choices\":[{\"message\":{\"content\":" + json_string(content)
                        + "},\"finish_reason\":" + json_string(finish) + "}],\"usage\":{\"prompt_tokens\":9,\"completion_tokens\":4}}";
                }
            } else if (request.find("\"model\":\"structured-valid\"") != std::string::npos) {
                const bool valid_schema = request.find("\"response_format\":{\"type\":\"json_schema\"") != std::string::npos
                    && request.find("\"strict\":true") != std::string::npos
                    && request.find("\"max_completion_tokens\":32") != std::string::npos;
                if (!valid_schema) {
                    body = R"({"error":{"message":"structured request shape mismatch"}})";
                } else {
                    body = R"({"id":"structured-001","choices":[{"message":{"content":"{\"answer\":\"ok\",\"score\":1}"},"finish_reason":"stop"}],"usage":{"prompt_tokens":7,"completion_tokens":6}})";
                }
            } else if (request.find("\"model\":\"structured-invalid\"") != std::string::npos) {
                body = R"({"id":"structured-002","choices":[{"message":{"content":"{\"other\":true}"},"finish_reason":"stop"}],"usage":{"prompt_tokens":7,"completion_tokens":3}})";
            } else if (request.find("\"model\":\"retry-local-") != std::string::npos) {
                const std::string request_id = header_value(request, "X-Client-Request-Id");
                const int attempt = ++retry_attempts[request_id];
                if (attempt == 1) {
                    http_status = 429;
                    extra_headers = "Retry-After: 1\r\n";
                    body = R"({"error":{"message":"synthetic rate limit"}})";
                } else if (attempt == 2) {
                    http_status = 503;
                    body = R"({"error":{"message":"synthetic unavailable"}})";
                } else {
                    body = R"({"id":"retry-001","choices":[{"message":{"content":"retry complete"},"finish_reason":"stop"}],"usage":{"prompt_tokens":3,"completion_tokens":2}})";
                }
            } else if (request.find("\"model\":\"nonretry-local\"") != std::string::npos) {
                http_status = 400;
                body = R"({"error":{"message":"synthetic invalid request"}})";
            } else {
                const bool valid_model = request.find("\"model\":\"local-chat\"") != std::string::npos;
                const bool valid_stream = request.find("\"stream\":false") != std::string::npos;
                const bool valid_temperature = scenario == "hardening"
                    || request.find("\"temperature\":0") != std::string::npos;
                const bool valid_unicode = request.find("Generate Gr\xc3\xa0" "dh \xe4\xb8\xad") != std::string::npos;
                if (!valid_model || !valid_stream || !valid_temperature || !valid_unicode) {
                    body = R"({"error":{"message":"OpenAI-compatible generation request shape mismatch"}})";
                } else {
                    body = R"({"id":"chatcmpl-local-001","model":"local-chat","choices":[{"index":0,"message":{"role":"assistant","content":"loopback OpenAI generation Gr\u00e0dh \u4e2d"},"finish_reason":"stop"}],"usage":{"prompt_tokens":9,"completion_tokens":4,"total_tokens":13}})";
                }
            }
        } else if (path == "/v1/embeddings") {
            if (request.find("\"model\":\"batch-local\"") != std::string::npos) {
                const bool valid_batch = request.find("\"input\":[\"alpha\",\"beta\"]") != std::string::npos;
                const bool valid_dimensions = request.find("\"dimensions\":3") != std::string::npos;
                if (!valid_batch || !valid_dimensions) {
                    body = R"({"error":{"message":"batch embedding request shape mismatch"}})";
                } else {
                    body = R"({"data":[{"index":0,"embedding":[0.1,0.2,0.3]},{"index":1,"embedding":[-0.1,-0.2,-0.3]}],"usage":{"prompt_tokens":4,"total_tokens":4}})";
                }
            } else {
                const bool valid_model = request.find("\"model\":\"local-embed\"") != std::string::npos;
                const bool valid_encoding = request.find("\"encoding_format\":\"float\"") != std::string::npos;
                const bool valid_input = request.find("\"input\":\"Embed this locally\"") != std::string::npos;
                if (!valid_model || !valid_encoding || !valid_input) {
                    body = R"({"error":{"message":"OpenAI-compatible embedding request shape mismatch"}})";
                } else {
                    body = R"({"object":"list","model":"local-embed","data":[{"object":"embedding","index":0,"embedding":[0.125,-0.25,0.5]}],"usage":{"prompt_tokens":4,"total_tokens":4}})";
                }
            }
        } else if (path.find("loopback-generate") != std::string::npos) {
            body = R"({"candidates":[{"content":{"parts":[{"text":"loopback generation"}]} }],"usageMetadata":{"promptTokenCount":3,"candidatesTokenCount":2}})";
        } else if (path.find("loopback-embed") != std::string::npos) {
            const bool top_level_dimension = request.find("\"outputDimensionality\":3") != std::string::npos;
            const bool nested_config = request.find("\"embedContentConfig\"") != std::string::npos;
            if (!top_level_dimension || nested_config) {
                body = R"({"error":{"message":"embedding dimensionality request shape mismatch"}})";
            } else {
                body = R"({"embedding":{"values":[0.25,-0.5,0.75]},"usageMetadata":{"promptTokenCount":2}})";
            }
        } else if (path.find("malformed") != std::string::npos) {
            body = "{\"candidates\":[";
        } else if (path.find("timeout") != std::string::npos) {
            std::this_thread::sleep_for(std::chrono::milliseconds(300));
            body = R"({"candidates":[{"content":{"parts":[{"text":"too late"}]}}]})";
        } else if (path.find("provider-error") != std::string::npos) {
            body = R"({"error":{"message":"fixture provider failure"}})";
        } else {
            body = R"({"error":{"message":"unexpected loopback path"}})";
        }
        if (scenario == "product-hold-response" && index == 0) {
            if (argc != 5) return 9;
            const int control = ::open(argv[4], O_RDONLY | O_NONBLOCK);
            if (control < 0) return 9;
            std::cout << "RESPONSE_HELD" << std::endl;
            pollfd release {control, POLLIN, 0};
            if (::poll(&release, 1, 30000) <= 0) { ::close(control); return 9; }
            char token = 0;
            if (::read(control, &token, 1) != 1 || token != 'R') { ::close(control); return 9; }
            ::close(control);
        }
        if (scenario == "product-manifest-fault"
            && request.find("crexx-rag.discovery-context/1") != std::string::npos) {
            if (argc != 5 || ::mkdir(argv[4], 0700) != 0) return 9;
            std::cout << "MANIFEST_FAULT_READY" << std::endl;
        }
        const std::string response = "HTTP/1.1 " + std::to_string(http_status) + " " + reason_phrase(http_status)
            + "\r\nContent-Type: application/json\r\nContent-Length: "
            + std::to_string(body.size()) + "\r\nX-Request-Id: loopback-request-" + std::to_string(index + 1)
            + "\r\n" + extra_headers + "Connection: close\r\n\r\n" + body;
        if ((scenario == "product-concurrent"
             && request.find("Durable resolution input:") != std::string::npos)
            || ((scenario == "product-concurrent-extraction" || scenario == "product-concurrent-held-extraction")
                && request.find("crexx-rag.discovery-context/1") != std::string::npos)) {
            // A rendezvous, not a sleep: neither response is released until
            // two independent product workers have reached the provider.
            if (paired_client < 0) {
                paired_client = client;
                paired_response = response;
            } else {
                if (scenario == "product-concurrent-held-extraction") {
                    if (argc != 5) return 9;
                    const int control = ::open(argv[4], O_RDONLY | O_NONBLOCK);
                    if (control < 0) return 9;
                    std::cout << "PAIR_HELD " << barrier_pairs + 1 << std::endl;
                    pollfd release {control, POLLIN, 0};
                    if (::poll(&release, 1, 30000) <= 0) { ::close(control); return 9; }
                    char token = 0;
                    if (::read(control, &token, 1) != 1 || token != 'R') { ::close(control); return 9; }
                    ::close(control);
                }
                if (!send_all(paired_client, paired_response) || !send_all(client, response)) return 7;
                ::close(paired_client);
                ::close(client);
                paired_client = -1;
                ++barrier_pairs;
                std::cout << "BARRIER_PAIR " << barrier_pairs << std::endl;
            }
        } else {
            send_all(client, response);
            ::close(client);
        }
        completed_requests = index + 1;
        if (scenario == "product-backlog-large-target" && large_target_stage == 6) break;
    }
    if (paired_client >= 0) { ::close(paired_client); ::close(server); return 8; }
    if (scenario == "product-backlog-large-target"
        && (large_target_stage != 6 || large_target_passage_pages < 2
            || large_target_catalogue_pages < 2)) return 9;
    std::cout << "SUMMARY scenario=" << scenario << " connections=" << completed_requests
              << " request_connection_close=" << close_requests
              << " barrier_pairs=" << barrier_pairs
              << " passage_pages=" << large_target_passage_pages
              << " catalogue_pages=" << large_target_catalogue_pages << std::endl;
    ::close(server);
    return 0;
}

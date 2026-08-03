#include <arpa/inet.h>
#include <netinet/in.h>
#include <poll.h>
#include <signal.h>
#include <sys/socket.h>
#include <unistd.h>

#include <chrono>
#include <cstdlib>
#include <iostream>
#include <string>
#include <thread>

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

} // namespace

int main(int argc, char** argv)
{
    ::signal(SIGPIPE, SIG_IGN);
    const int port = argc > 1 ? std::atoi(argv[1]) : 18991;
    const int requests = argc > 2 ? std::atoi(argv[2]) : 4;
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
    std::cout << "READY " << port << std::endl;

    for (int index = 0; index < requests; ++index) {
        pollfd ready {server, POLLIN, 0};
        if (::poll(&ready, 1, 10000) <= 0) {
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
        std::cout << "REQUEST " << path << std::endl;
        std::string body;
        if (path == "/v1/chat/completions") {
            const bool valid_model = request.find("\"model\":\"local-chat\"") != std::string::npos;
            const bool valid_stream = request.find("\"stream\":false") != std::string::npos;
            const bool valid_unicode = request.find("Generate Gr\xc3\xa0" "dh \xe4\xb8\xad") != std::string::npos;
            if (!valid_model || !valid_stream || !valid_unicode) {
                body = R"({"error":{"message":"OpenAI-compatible generation request shape mismatch"}})";
            } else {
                body = R"({"id":"chatcmpl-local-001","model":"local-chat","choices":[{"index":0,"message":{"role":"assistant","content":"loopback OpenAI generation Gr\u00e0dh \u4e2d"},"finish_reason":"stop"}],"usage":{"prompt_tokens":9,"completion_tokens":4,"total_tokens":13}})";
            }
        } else if (path == "/v1/embeddings") {
            const bool valid_model = request.find("\"model\":\"local-embed\"") != std::string::npos;
            const bool valid_encoding = request.find("\"encoding_format\":\"float\"") != std::string::npos;
            const bool valid_input = request.find("\"input\":\"Embed this locally\"") != std::string::npos;
            if (!valid_model || !valid_encoding || !valid_input) {
                body = R"({"error":{"message":"OpenAI-compatible embedding request shape mismatch"}})";
            } else {
                body = R"({"object":"list","model":"local-embed","data":[{"object":"embedding","index":0,"embedding":[0.125,-0.25,0.5]}],"usage":{"prompt_tokens":4,"total_tokens":4}})";
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
        const std::string response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: "
            + std::to_string(body.size()) + "\r\nConnection: close\r\n\r\n" + body;
        send_all(client, response);
        ::close(client);
    }
    ::close(server);
    return 0;
}

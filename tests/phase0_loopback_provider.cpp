#include <arpa/inet.h>
#include <netinet/in.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>

#include <chrono>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <thread>

int main(int argc, char** argv)
{
    const int port = argc > 1 ? std::atoi(argv[1]) : 18765;
    const int requests = argc > 2 ? std::atoi(argv[2]) : 2;
    const int server = ::socket(AF_INET, SOCK_STREAM, 0);
    if (server < 0) {
        return 1;
    }
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
    for (int request = 0; request < requests; ++request) {
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
        char input[8192];
        const ssize_t received = ::recv(client, input, sizeof(input), 0);
        if (received <= 0) {
            ::close(client);
            ::close(server);
            return 5;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(25));
        const std::string body = "{\"text\":\"loopback-ok\",\"embedding\":[1.0,0.0,0.0]}";
        const std::string response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: "
            + std::to_string(body.size()) + "\r\nConnection: close\r\n\r\n" + body;
        size_t sent = 0;
        while (sent < response.size()) {
            const ssize_t count = ::send(client, response.data() + sent, response.size() - sent, 0);
            if (count <= 0) {
                break;
            }
            sent += static_cast<size_t>(count);
        }
        ::close(client);
    }
    ::close(server);
    return 0;
}

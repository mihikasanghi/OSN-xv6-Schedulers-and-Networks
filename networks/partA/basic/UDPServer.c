#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>

#define PORT 8855
#define BUFFER_SIZE 1024

// Function to display error message and exit the program
void display_error(const char *error_msg) {
    printf("\033[1;31mERROR: %s\n\033[0m", error_msg);
    exit(EXIT_FAILURE);
}

// Function to retrieve the IP address of the host machine
char* get_host_ip() {
    char host_buffer[256];
    struct hostent *host_info;
    
    if (gethostname(host_buffer, sizeof(host_buffer)) != 0) 
        display_error("Error in obtaining IP address");

    host_info = gethostbyname(host_buffer);
    if (host_info == NULL) 
        display_error("Error in obtaining IP address");

    return inet_ntoa(*((struct in_addr*)host_info->h_addr_list[0]));
}

// Function to create a socket and return its file descriptor
int create_udp_socket() {
    int socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (socket_fd == -1) 
        display_error("Socket creation failed");
    return socket_fd;
}

// Function to bind the socket to the server address
void bind_socket(int socket_fd, struct sockaddr_in *server_addr) {
    if (bind(socket_fd, (struct sockaddr*)server_addr, sizeof(*server_addr)) == -1)
        display_error("Couldn't bind socket");
}

// Function to receive a message from the client
void receive_message(int socket_fd, char* buffer, struct sockaddr_in *client_addr, socklen_t *addr_size) {
    if (recvfrom(socket_fd, buffer, BUFFER_SIZE, 0, (struct sockaddr*)client_addr, addr_size) < 0)
        display_error("Nothing was received from client");
}

// Function to send a message to the client
void send_message(int socket_fd, const char* message, struct sockaddr_in *client_addr) {
    if (sendto(socket_fd, message, strlen(message), 0, (struct sockaddr*)client_addr, sizeof(*client_addr)) == -1)
        display_error("Couldn't send message to client");
}

int main() {
    char* ip_address = get_host_ip();
    int socket_fd = create_udp_socket();
    struct sockaddr_in server_addr, client_addr;
    socklen_t addr_size = sizeof(client_addr);
    char client_response[BUFFER_SIZE];

    memset(&server_addr, '\0', sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    bind_socket(socket_fd, &server_addr);

    receive_message(socket_fd, client_response, &client_addr, &addr_size);
    printf("Received from client: %s\n", client_response);

    char* server_msg = "Hello Client! Server has received your message.\0";
    send_message(socket_fd, server_msg, &client_addr);

    close(socket_fd);
    return 0;
}

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
char* retrieve_ip_address() {
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
int create_socket() {
    int socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (socket_fd == -1) 
        display_error("Socket creation failed");
    return socket_fd;
}

// Function to configure the server address structure
void configure_server_addr(struct sockaddr_in *server_addr, const char* ip_address) {
    server_addr->sin_family = AF_INET;
    server_addr->sin_port = htons(PORT);
    server_addr->sin_addr.s_addr = inet_addr(ip_address);
}

// Function to send a message to the server
void send_message_to_server(int socket_fd, const char* message, struct sockaddr_in *server_addr) {
    if (sendto(socket_fd, message, strlen(message), 0, (struct sockaddr*)server_addr, sizeof(*server_addr)) == -1)
        display_error("Couldn't send message to server");
}

// Function to receive a message from the server
void receive_message_from_server(int socket_fd, char* buffer, struct sockaddr_in *server_addr) {
    socklen_t addr_size = sizeof(*server_addr);
    if (recvfrom(socket_fd, buffer, BUFFER_SIZE, 0, (struct sockaddr*)server_addr, &addr_size) < 0)
        display_error("Nothing was received from server");
}

int main() {
    char* ip_address = retrieve_ip_address();
    int socket_fd = create_socket();
    struct sockaddr_in server_addr;
    char server_response[BUFFER_SIZE];
    char* client_msg = "Hello Server! This is the Client.\0";

    configure_server_addr(&server_addr, ip_address);
    send_message_to_server(socket_fd, client_msg, &server_addr);
    receive_message_from_server(socket_fd, server_response, &server_addr);

    printf("Received from server: %s\n", server_response);

    close(socket_fd);
    return 0;
}

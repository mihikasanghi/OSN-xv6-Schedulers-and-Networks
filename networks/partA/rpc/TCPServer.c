#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>

#define PORT1 8897
#define PORT2 8896
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
    
    // Get host name
    if (gethostname(host_buffer, sizeof(host_buffer)) != 0) 
        display_error("Error in obtaining IP address");

    // Get host entry info
    host_info = gethostbyname(host_buffer);
    if (host_info == NULL) 
        display_error("Error in obtaining IP address");

    return inet_ntoa(*((struct in_addr*)host_info->h_addr_list[0]));
}

int main() {
    char* ip_address = retrieve_ip_address();
    int server_fd, connection_fd, addr_length;
    struct sockaddr_in server_addr, client_addr;

    // Create socket
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == -1) 
        display_error("Socket creation failed");

    memset(&server_addr, '\0', sizeof(server_addr));

    // Configure server address structure
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    // Bind socket to the server address
    if (bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
        display_error("Couldn't bind socket");

    // Listen for client connections
    if (listen(server_fd, 5) == -1)
        display_error("Listening failed");
    
    addr_length = sizeof(client_addr);

    // Accept client connection
    connection_fd = accept(server_fd, (struct sockaddr *)&client_addr, &addr_length);
    if (connection_fd < 0)
        display_error("Couldn't establish connection");

    char client_response[BUFFER_SIZE];

    // Receive message from client
    if (recv(connection_fd, client_response, BUFFER_SIZE, 0) < 0)
        display_error("Nothing was received from client");
    printf("Received from client: %s\n", client_response);

    char* server_msg = "Hello, Client! Server has received your message";

    // Send message to client
    if (send(connection_fd, server_msg, strlen(server_msg), 0) == -1)
        display_error("Couldn't send message to client");

    // Close connections
    close(connection_fd);
    close(server_fd);
    return 0;
}

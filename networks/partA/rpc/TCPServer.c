#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>

#define PORTA 8897
#define PORTB 8896
#define BUFFER_SIZE 1024

// Function to display error message and exit the program
void handle_error(const char *error_msg)
{
    printf("\033[1;31mERROR: %s\n\033[0m", error_msg);
    exit(EXIT_FAILURE);
}

// Function to retrieve the IP address of the host machine
char *get_host_ip()
{
    char host_buffer[256];
    struct hostent *host_info;

    if (gethostname(host_buffer, sizeof(host_buffer)) != 0)
        handle_error("Error in obtaining IP address");

    host_info = gethostbyname(host_buffer);
    if (host_info == NULL)
        handle_error("Error in obtaining IP address");

    return inet_ntoa(*((struct in_addr *)host_info->h_addr_list[0]));
}

// Function to create a socket and return its file descriptor
int create_server_socket()
{
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_fd == -1)
        handle_error("Socket creation failed");
    return socket_fd;
}

// Function to bind the socket to the server address
void bind_server_socket(int socket_fd, struct sockaddr_in *server_addr)
{
    if (bind(socket_fd, (struct sockaddr *)server_addr, sizeof(*server_addr)) == -1)
        handle_error("Couldn't bind socket");
}

// Function to listen for incoming connections
void listen_for_connections(int socket_fd)
{
    if (listen(socket_fd, 5) == -1)
        handle_error("Listening failed");
}

// Function to accept a client connection
int accept_client_connection(int socket_fd, struct sockaddr_in *client_addr, socklen_t *addr_size)
{
    int connection_fd = accept(socket_fd, (struct sockaddr *)client_addr, addr_size);
    if (connection_fd < 0)
        handle_error("Couldn't establish connection");
    return connection_fd;
}

// Function to receive a message from the client
void receive_client_message(int connection_fd, char *buffer)
{
    if (recv(connection_fd, buffer, BUFFER_SIZE, 0) < 0)
        handle_error("Nothing was received from client");
}

// Function to send a message to the client
void send_server_message(int connection_fd, const char *message)
{
    if (send(connection_fd, message, strlen(message), 0) == -1)
        handle_error("Couldn't send message to client");
}

int main()
{
    char *ip_address = get_host_ip();
    int socket_fd_A = create_server_socket();
    int socket_fd_B = create_server_socket();
    struct sockaddr_in server_addr_A, server_addr_B, client_addr_A, client_addr_B;
    socklen_t addr_size_A = sizeof(client_addr_A);
    socklen_t addr_size_B = sizeof(client_addr_B);

    memset(&server_addr_A, '\0', sizeof(server_addr_A));
    server_addr_A.sin_family = AF_INET;
    server_addr_A.sin_port = htons(PORTA);
    server_addr_A.sin_addr.s_addr = INADDR_ANY;

    memset(&server_addr_B, '\0', sizeof(server_addr_B));
    server_addr_B.sin_family = AF_INET;
    server_addr_B.sin_port = htons(PORTB);
    server_addr_B.sin_addr.s_addr = INADDR_ANY;

    bind_server_socket(socket_fd_A, &server_addr_A);
    listen_for_connections(socket_fd_A);
    int connection_fd_A = accept_client_connection(socket_fd_A, &client_addr_A, &addr_size_A);

    bind_server_socket(socket_fd_B, &server_addr_B);
    listen_for_connections(socket_fd_B);
    int connection_fd_B = accept_client_connection(socket_fd_B, &client_addr_B, &addr_size_B);

    while (1)
    {
        // connection_fd_A = accept_client_connection(socket_fd_A, &client_addr_A, &addr_size_A);
        // connection_fd_B = accept_client_connection(socket_fd_B, &client_addr_B, &addr_size_B);

        char reply_A[BUFFER_SIZE], reply_B[BUFFER_SIZE];
        strcpy(reply_A, "");
        strcpy(reply_B, "");

        // Recieving rock paper scissor from client A and B
        receive_client_message(connection_fd_A, reply_A);
        receive_client_message(connection_fd_B, reply_B);

        char *server_msg_to_A = (char *)calloc(256, sizeof(char));
        char *server_msg_to_B = (char *)calloc(256, sizeof(char));
        // strcpy(server_msg, "Hello Client! Server has received your message.\0");
        // send_server_message(connection_fd, server_msg);

        if (reply_A[0] == reply_B[0])
        {
            strcpy(server_msg_to_A, "The match has been tied.\n");
            strcpy(server_msg_to_B, "The match has been tied.\n");
        }
        else if (reply_A[0] - reply_B[0] == 1 || (reply_A[0] == 0 && reply_B[0] == 2))
        {
            strcpy(server_msg_to_A, "The match has been won by you :) \n");
            strcpy(server_msg_to_B, "The match has been lost by you :( \n");
        }
        else
        {
            strcpy(server_msg_to_B, "The match has been won by you :) \n");
            strcpy(server_msg_to_A, "The match has been lost by you :( \n");
        }

        strcat(server_msg_to_A, "Would you like to play again? Y or N\n");
        strcat(server_msg_to_B, "Would you like to play again? Y or N\n");

        // Sending the result to client A and B and asking if they want to play again
        send_server_message(connection_fd_A, server_msg_to_A);
        send_server_message(connection_fd_B, server_msg_to_B);

        // Recieving the reply from client A and B if they want to continue
        receive_client_message(connection_fd_A, reply_A);
        receive_client_message(connection_fd_B, reply_B);

        if (reply_A[0] == 'Y' && reply_B[0] == 'Y')
        {
            strcpy(server_msg_to_A, "1");
            strcpy(server_msg_to_B, "1");
            send_server_message(connection_fd_A, server_msg_to_A);
            send_server_message(connection_fd_B, server_msg_to_B);
        }
        else
        {
            strcpy(server_msg_to_A, "0");
            strcpy(server_msg_to_B, "0");
            send_server_message(connection_fd_A, server_msg_to_A);
            send_server_message(connection_fd_B, server_msg_to_B);
            break;
        }
    }
    close(connection_fd_A);
    close(connection_fd_B);
    close(socket_fd_A);
    close(socket_fd_B);
    return 0;
}

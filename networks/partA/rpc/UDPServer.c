#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>

#define PORTA 8800
#define PORTB 8801
#define BUFFER_SIZE 1024

// Function to display error message and exit the program
void display_error(const char *error_msg)
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
        display_error("Error in obtaining IP address");

    host_info = gethostbyname(host_buffer);
    if (host_info == NULL)
        display_error("Error in obtaining IP address");

    return inet_ntoa(*((struct in_addr *)host_info->h_addr_list[0]));
}

// Function to create a socket and return its file descriptor
int create_udp_socket()
{
    int socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (socket_fd == -1)
        display_error("Socket creation failed");
    return socket_fd;
}

// Function to bind the socket to the server address
void bind_socket(int socket_fd, struct sockaddr_in *server_addr)
{
    if (bind(socket_fd, (struct sockaddr *)server_addr, sizeof(*server_addr)) == -1)
        display_error("Couldn't bind socket");
}

// Function to receive a message from the client
void receive_message(int socket_fd, char *buffer, struct sockaddr_in *client_addr, socklen_t *addr_size)
{
    if (recvfrom(socket_fd, buffer, BUFFER_SIZE, 0, (struct sockaddr *)client_addr, addr_size) < 0)
        display_error("Nothing was received from client");
}

// Function to send a message to the client
void send_message(int socket_fd, const char *message, struct sockaddr_in *client_addr)
{
    if (sendto(socket_fd, message, strlen(message), 0, (struct sockaddr *)client_addr, sizeof(*client_addr)) == -1)
        display_error("Couldn't send message to client");
}

int main()
{
    char *ip_address = get_host_ip();
    int socket_fd_A = create_udp_socket();
    int socket_fd_B = create_udp_socket();
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

    bind_socket(socket_fd_A, &server_addr_A);
    bind_socket(socket_fd_B, &server_addr_B);

    while (1)
    {
        char reply_A[BUFFER_SIZE], reply_B[BUFFER_SIZE];
        strcpy(reply_A, "");
        strcpy(reply_B, "");

        receive_message(socket_fd_A, reply_A, &client_addr_A, &addr_size_A);
        receive_message(socket_fd_B, reply_B, &client_addr_B, &addr_size_B);

        char *server_msg_to_A = (char *)calloc(256, sizeof(char));
        char *server_msg_to_B = (char *)calloc(256, sizeof(char));

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

        send_message(socket_fd_A, server_msg_to_A, &client_addr_A);
        send_message(socket_fd_B, server_msg_to_B, &client_addr_B);

        receive_message(socket_fd_A, reply_A, &client_addr_A, &addr_size_A);
        receive_message(socket_fd_B, reply_B, &client_addr_B, &addr_size_B);

        if (reply_A[0] == 'Y' && reply_B[0] == 'Y')
        {
            strcpy(server_msg_to_A, "1");
            strcpy(server_msg_to_B, "1");
            send_message(socket_fd_A, server_msg_to_A, &client_addr_A);
            send_message(socket_fd_B, server_msg_to_B, &client_addr_B);
        }
        else
        {
            strcpy(server_msg_to_A, "0");
            strcpy(server_msg_to_B, "0");
            send_message(socket_fd_A, server_msg_to_A, &client_addr_A);
            send_message(socket_fd_B, server_msg_to_B, &client_addr_B);

            break;
        }
    }

    close(socket_fd_A);
    return 0;
}

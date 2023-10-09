#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <sys/time.h>

#define STRINGSIZE 1024
#define PORT 5000
#define CHUNKSIZE 5
#define SERVER_IP "127.0.0.1"
#define TIMEOUT 2
#define MAX_RESEND 3

int *ack;
struct timeval *transmission_times;

struct ThreadArgs
{
    char **chunks;
    int num_chunks;
    struct sockaddr_in server_addr;
    int client_socket;
};

struct Chunk
{
    char chunk[CHUNKSIZE + 1]; // +1 for null-terminator
    int chunk_index;
    int total_chunks;
    int sent_counter;
};

void *send_chunks(void *args)
{
    struct ThreadArgs thread_args = *(struct ThreadArgs *)args;
    char **chunks = thread_args.chunks;
    int num_chunks = thread_args.num_chunks;
    struct sockaddr_in server_addr = thread_args.server_addr;
    int client_socket = thread_args.client_socket;

    transmission_times = (struct timeval *)malloc(num_chunks * sizeof(struct timeval));
    if (!transmission_times)
    {
        perror("Failed to allocate memory for transmission_times");
        exit(1);
    }

    for (int i = 0; i < num_chunks; i++)
    {
        struct Chunk chunk;
        strcpy(chunk.chunk, chunks[i]);
        chunk.chunk_index = i;
        chunk.total_chunks = num_chunks;
        chunk.sent_counter = 1;

        if (sendto(client_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
        {
            perror("Error in sending message");
            close(client_socket);
            exit(1);
        }
        else
        {
            gettimeofday(&transmission_times[i], NULL);
            printf("Chunk %d with message %s sent to the server\n", i, chunk.chunk);
        }
    }

    free(transmission_times);
    transmission_times = NULL;
}

void *receive_acks(void *args)
{
    struct ThreadArgs thread_args = *(struct ThreadArgs *)args;
    int client_socket = thread_args.client_socket;
    struct sockaddr_in server_addr = thread_args.server_addr;
    int num_chunks = thread_args.num_chunks;

    ack = (int *)malloc(num_chunks * sizeof(int));
    if (!ack)
    {
        perror("Failed to allocate memory for ack");
        exit(1);
    }

    for (int i = 0; i < num_chunks; i++)
    {
        struct Chunk chunk;
        socklen_t server_addr_len = sizeof(server_addr);
        if (recvfrom(client_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)&server_addr, &server_addr_len) == -1)
        {
            perror("Error in receiving message");
            close(client_socket);
            exit(1);
        }
        else
        {
            ack[chunk.chunk_index] = 1;
            printf("Acknowledgement received for chunk %d\n", chunk.chunk_index);
        }
    }

    free(ack);
    ack = NULL;
}

void *resend_chunks(void *args)
{
    struct ThreadArgs thread_args = *(struct ThreadArgs *)args;
    int client_socket = thread_args.client_socket;
    struct sockaddr_in server_addr = thread_args.server_addr;
    int num_chunks = thread_args.num_chunks;
    char **chunks = thread_args.chunks;

    for (int i = 0; i < num_chunks; i++)
    {
        struct Chunk chunk;
        strcpy(chunk.chunk, chunks[i]);
        chunk.chunk_index = i;
        chunk.total_chunks = num_chunks;
        chunk.sent_counter = 1;

        while (ack[i] != 1 && chunk.sent_counter < MAX_RESEND)
        {
            struct timeval current_time;
            gettimeofday(&current_time, NULL);
            timersub(&current_time, &transmission_times[i], &current_time);
            if (current_time.tv_sec > TIMEOUT)
            {
                if (sendto(client_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
                {
                    perror("Error in sending message");
                    close(client_socket);
                    exit(1);
                }
                else
                {
                    gettimeofday(&transmission_times[i], NULL);
                    printf("Chunk %d with message %s sent to the server\n", i, chunk.chunk);
                }
                chunk.sent_counter++;
            }
        }
    }
}

char **divide_message(char *message, int chunk_size)
{
    int num_chunks = strlen(message) / chunk_size;
    int remainder = strlen(message) % chunk_size != 0;
    num_chunks += remainder;

    char **chunks = (char **)malloc(num_chunks * sizeof(char *));
    if (!chunks)
    {
        perror("Failed to allocate memory for chunks");
        exit(1);
    }

    for (int i = 0; i < num_chunks; i++)
    {
        chunks[i] = (char *)malloc((chunk_size + 1) * sizeof(char));
        if (!chunks[i])
        {
            perror("Failed to allocate memory for a chunk");
            exit(1);
        }

        strncpy(chunks[i], message + i * chunk_size, chunk_size);
        chunks[i][chunk_size] = '\0';
    }

    return chunks;
}

void send_message()
{
    char message_client[STRINGSIZE];
    int client_socket;
    struct sockaddr_in server_addr;
    printf("Enter the input message: ");
    fgets(message_client, STRINGSIZE, stdin);
    message_client[strlen(message_client) - 1] = '\0';
    char message[STRINGSIZE];
    strcpy(message, message_client);

    client_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (client_socket == -1)
    {
        perror("Socket creation failed");
        exit(1);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    if (inet_pton(AF_INET, SERVER_IP, &server_addr.sin_addr) <= 0)
    {
        perror("Invalid server address");
        close(client_socket);
        exit(1);
    }

    char **chunks = divide_message(message, CHUNKSIZE);
    int num_chunks = strlen(message) / CHUNKSIZE + (strlen(message) % CHUNKSIZE != 0);

    if (sendto(client_socket, &num_chunks, sizeof(num_chunks), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
    {
        perror("Error in sending message");
        close(client_socket);
        exit(1);
    }
    else
    {
        printf("Number of chunks sent to the server are %d with length %ld\n", num_chunks, strlen(message));
    }

    pthread_t send_thread, receive_thread, resend_thread;
    struct ThreadArgs thread_args;
    thread_args.chunks = chunks;
    thread_args.num_chunks = num_chunks;
    thread_args.server_addr = server_addr;
    thread_args.client_socket = client_socket;
    pthread_create(&send_thread, NULL, send_chunks, (void *)&thread_args);
    pthread_create(&receive_thread, NULL, receive_acks, (void *)&thread_args);
    pthread_create(&resend_thread, NULL, resend_chunks, (void *)&thread_args);

    pthread_join(send_thread, NULL);
    pthread_join(receive_thread, NULL);
    pthread_join(resend_thread, NULL);

    close(client_socket);

    for (int i = 0; i < num_chunks; i++)
    {
        free(chunks[i]);
    }
    free(chunks);
    chunks = NULL;
}

void receive_message()
{
    printf("Waiting for server to send message...\n");
    int client_socket;
    struct sockaddr_in server_addr;
    socklen_t server_addr_len = sizeof(server_addr);

    client_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (client_socket == -1)
    {
        perror("Socket creation failed");
        exit(1);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(client_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
    {
        perror("Error in binding socket to the server address");
        close(client_socket);
        exit(1);
    }

    int num_chunks_received;
    if (recvfrom(client_socket, &num_chunks_received, sizeof(num_chunks_received), 0, (struct sockaddr *)&server_addr, &server_addr_len) == -1)
    {
        perror("Error in receiving message");
        close(client_socket);
        exit(1);
    }
    else
    {
        printf("Number of chunks received from the server are %d\n", num_chunks_received);
    }

    int received_chunks[num_chunks_received];
    memset(received_chunks, 0, num_chunks_received * sizeof(int));

    char **chunks_received = (char **)malloc(num_chunks_received * sizeof(char *));
    if (!chunks_received)
    {
        perror("Failed to allocate memory for chunks_received");
        close(client_socket);
        exit(1);
    }

    for (int i = 0; i < num_chunks_received; i++)
    {
        struct Chunk chunk;
        if (recvfrom(client_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)&server_addr, &server_addr_len) == -1)
        {
            perror("Error in receiving message");
            close(client_socket);
            exit(1);
        }
        else if (received_chunks[chunk.chunk_index] == 0)
        {
            chunks_received[chunk.chunk_index] = (char *)malloc((CHUNKSIZE + 1) * sizeof(char));
            if (!chunks_received[chunk.chunk_index])
            {
                perror("Failed to allocate memory for a chunk_received");
                close(client_socket);
                exit(1);
            }

            strcpy(chunks_received[chunk.chunk_index], chunk.chunk);
            printf("Chunk %d with message %s received from the server\n", chunk.chunk_index, chunk.chunk);
            received_chunks[chunk.chunk_index] = 1;

            if (sendto(client_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
            {
                perror("Error in sending message");
                close(client_socket);
                exit(1);
            }
            else
            {
                printf("Acknowledgement sent for chunk %d\n", chunk.chunk_index);
            }
        }
        else
        {
            i--;
        }
    }

    close(client_socket);

    char message[STRINGSIZE];
    message[0] = '\0';
    for (int i = 0; i < num_chunks_received; i++)
    {
        strcat(message, chunks_received[i]);
    }
    printf("The message received from the server is %s with length %ld\n", message, strlen(message));

    for (int i = 0; i < num_chunks_received; i++)
    {
        free(chunks_received[i]);
    }
    free(chunks_received);
    chunks_received = NULL;
}

int main()
{
    while (1)
    {
        receive_message();
        printf("\n\n\n");
        send_message();
    }

    return 0;
}

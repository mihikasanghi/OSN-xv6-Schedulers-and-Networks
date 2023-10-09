#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
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
    char chunk[CHUNKSIZE];
    int chunk_index;
    int total_chunks;
    int sent_counter;
};

void initialize_transmission_times(int num_chunks) {
    transmission_times = (struct timeval *)malloc(num_chunks * sizeof(struct timeval));
}

void configure_chunk(struct Chunk *chunk, char *chunk_data, int index, int total) {
    strcpy(chunk->chunk, chunk_data);
    chunk->chunk_index = index;
    chunk->total_chunks = total;
    chunk->sent_counter = 1;
}

void handle_send_error(int client_socket) {
    perror("Error in sending message");
    close(client_socket);
    exit(1);
}

void log_chunk_sent(int index, char *chunk_data) {
    printf("Chunk %d with message %s sent to the client\n", index, chunk_data);
}

void *send_chunks(void *args) {
    struct ThreadArgs thread_args = *(struct ThreadArgs *)args;
    char **chunks = thread_args.chunks;
    int num_chunks = thread_args.num_chunks;
    struct sockaddr_in server_addr = thread_args.server_addr;
    int client_socket = thread_args.client_socket;

    initialize_transmission_times(num_chunks);

    for (int i = 0; i < num_chunks; i++) {
        struct Chunk chunk;
        configure_chunk(&chunk, chunks[i], i, num_chunks);

        if (sendto(client_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1) {
            handle_send_error(client_socket);
        } else {
            gettimeofday(&transmission_times[i], NULL);
            log_chunk_sent(i, chunk.chunk);
        }
    }
}

void initialize_ack_array(int num_chunks)
{
    ack = (int *)malloc(num_chunks * sizeof(int));
}

int receive_acknowledgement(int client_socket, struct Chunk *chunk, struct sockaddr_in *server_addr)
{
    socklen_t server_addr_len = sizeof(*server_addr);
    return recvfrom(client_socket, chunk, sizeof(*chunk), 0, (struct sockaddr *)server_addr, &server_addr_len);
}

void handle_acknowledgement_error(int client_socket)
{
    perror("Error in receiving message");
    close(client_socket);
    exit(1);
}

void update_acknowledgement(struct Chunk *chunk)
{
    ack[chunk->chunk_index] = 1;
    printf("Acknowledgement received for chunk %d\n", chunk->chunk_index);
}

void *receive_acks(void *args)
{
    struct ThreadArgs thread_args = *(struct ThreadArgs *)args;
    int client_socket = thread_args.client_socket;
    struct sockaddr_in server_addr = thread_args.server_addr;
    int num_chunks = thread_args.num_chunks;

    initialize_ack_array(num_chunks);

    for (int i = 0; i < num_chunks; i++)
    {
        struct Chunk chunk;

        if (receive_acknowledgement(client_socket, &chunk, &server_addr) == -1)
        {
            handle_acknowledgement_error(client_socket);
        }
        else
        {
            update_acknowledgement(&chunk);
        }
    }
}

void initialize_chunk(struct Chunk *chunk, char *chunk_data, int index, int total_chunks)
{
    strcpy(chunk->chunk, chunk_data);
    chunk->chunk_index = index;
    chunk->total_chunks = total_chunks;
    chunk->sent_counter = 1;
}

int should_resend_chunk(int ack_status, int sent_counter)
{
    return ack_status != 1 && sent_counter < MAX_RESEND;
}

int has_timed_out(struct timeval *transmission_time, int timeout)
{
    struct timeval current_time, difference;
    gettimeofday(&current_time, NULL);
    timersub(&current_time, transmission_time, &difference);
    return difference.tv_sec > timeout;
}

void resend_chunk(int client_socket, struct Chunk *chunk, struct sockaddr_in *server_addr, struct timeval *transmission_time)
{
    if (sendto(client_socket, chunk, sizeof(*chunk), 0, (struct sockaddr *)server_addr, sizeof(*server_addr)) == -1)
    {
        perror("Error in sending message");
        close(client_socket);
        exit(1);
    }
    else
    {
        gettimeofday(transmission_time, NULL);
        printf("Chunk %d with message %s sent to the client\n", chunk->chunk_index, chunk->chunk);
    }
    chunk->sent_counter++;
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
        initialize_chunk(&chunk, chunks[i], i, num_chunks);

        while (should_resend_chunk(ack[i], chunk.sent_counter))
        {
            if (has_timed_out(&transmission_times[i], TIMEOUT))
            {
                resend_chunk(client_socket, &chunk, &server_addr, &transmission_times[i]);
            }
        }
    }
}

int calculate_num_chunks(const char *message, int chunk_size)
{
    int num_chunks = strlen(message) / chunk_size;
    if (strlen(message) % chunk_size != 0)
    {
        num_chunks++;
    }
    return num_chunks;
}

void allocate_and_fill_chunks(char **chunks, const char *message, int num_chunks, int chunk_size)
{
    for (int i = 0; i < num_chunks; i++)
    {
        chunks[i] = (char *)malloc((chunk_size + 1) * sizeof(char)); // +1 for '\0'
        strncpy(chunks[i], message + i * chunk_size, chunk_size);
        chunks[i][chunk_size] = '\0'; // Ensure null-termination
    }
}

char **divide_message(const char *message, int chunk_size)
{
    int num_chunks = calculate_num_chunks(message, chunk_size);
    char **chunks = (char **)malloc(num_chunks * sizeof(char *));

    allocate_and_fill_chunks(chunks, message, num_chunks, chunk_size);

    return chunks;
}

// Function to create a socket and configure the server address
int setup_client_socket(struct sockaddr_in *server_addr)
{
    int client_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (client_socket == -1)
    {
        perror("Socket creation failed");
        exit(1);
    }

    server_addr->sin_family = AF_INET;
    server_addr->sin_port = htons(PORT);
    if (inet_pton(AF_INET, SERVER_IP, &server_addr->sin_addr) <= 0)
    {
        perror("Invalid server address");
        close(client_socket);
        exit(1);
    }
    return client_socket;
}

// Function to send the number of chunks to the server
void send_num_chunks(int client_socket, int num_chunks, struct sockaddr_in *server_addr)
{
    if (sendto(client_socket, &num_chunks, sizeof(num_chunks), 0, (struct sockaddr *)server_addr, sizeof(*server_addr)) == -1)
    {
        perror("Error in sending message");
        close(client_socket);
        exit(1);
    }
    else
    {
        printf("Number of chunks sent to the server are %d\n", num_chunks);
    }
}

// Function to create threads for sending, receiving, and resending chunks
void create_threads(char **chunks, int num_chunks, struct sockaddr_in *server_addr, int client_socket)
{
    pthread_t send_thread, receive_thread, resend_thread;
    struct ThreadArgs thread_args;
    thread_args.chunks = chunks;
    thread_args.num_chunks = num_chunks;
    thread_args.server_addr = *server_addr;
    thread_args.client_socket = client_socket;

    pthread_create(&send_thread, NULL, send_chunks, (void *)&thread_args);
    pthread_create(&receive_thread, NULL, receive_acks, (void *)&thread_args);
    pthread_create(&resend_thread, NULL, resend_chunks, (void *)&thread_args);

    pthread_join(send_thread, NULL);
    pthread_join(receive_thread, NULL);
    pthread_join(resend_thread, NULL);
}

// Function to free the memory allocated to the chunks
void free_chunks_memory(char **chunks, int num_chunks)
{
    for (int i = 0; i < num_chunks; i++)
    {
        free(chunks[i]);
    }
}

// Main function to send a message
void send_message()
{
    char message_client[STRINGSIZE];
    struct sockaddr_in server_addr;

    printf("Enter the input message: ");
    fgets(message_client, STRINGSIZE, stdin);
    message_client[strlen(message_client) - 1] = '\0';

    int client_socket = setup_client_socket(&server_addr);

    char **chunks = divide_message(message_client, CHUNKSIZE);
    int num_chunks = (strlen(message_client) / CHUNKSIZE) + (strlen(message_client) % CHUNKSIZE != 0);

    send_num_chunks(client_socket, num_chunks, &server_addr);
    create_threads(chunks, num_chunks, &server_addr, client_socket);

    close(client_socket);
    free_chunks_memory(chunks, num_chunks);
}

int setup_server_socket(struct sockaddr_in *server_addr)
{
    int server_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (server_socket == -1)
    {
        perror("Socket creation failed");
        exit(1);
    }

    server_addr->sin_family = AF_INET;
    server_addr->sin_port = htons(PORT);
    server_addr->sin_addr.s_addr = INADDR_ANY;

    if (bind(server_socket, (struct sockaddr *)server_addr, sizeof(*server_addr)) == -1)
    {
        perror("Error in binding socket to the client address");
        close(server_socket);
        exit(1);
    }
    return server_socket;
}

int receive_num_chunks(int server_socket, struct sockaddr_in *client_addr, socklen_t *client_addr_len)
{
    int num_chunks_received;
    if (recvfrom(server_socket, &num_chunks_received, sizeof(num_chunks_received), 0, (struct sockaddr *)client_addr, client_addr_len) == -1)
    {
        perror("Error in receiving message");
        close(server_socket);
        exit(1);
    }
    printf("Number of chunks received from the client are %d\n", num_chunks_received);
    return num_chunks_received;
}

void receive_chunks(int server_socket, char **chunks_received, int num_chunks_received, struct sockaddr_in *client_addr, socklen_t *client_addr_len)
{
    int received_chunks[num_chunks_received];
    memset(received_chunks, 0, num_chunks_received * sizeof(int));

    for (int i = 0; i < num_chunks_received; i++)
    {
        struct Chunk chunk;
        if (recvfrom(server_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)client_addr, client_addr_len) == -1)
        {
            perror("Error in receiving message");
            close(server_socket);
            exit(1);
        }
        else if (received_chunks[chunk.chunk_index] == 0)
        {
            chunks_received[chunk.chunk_index] = (char *)malloc(CHUNKSIZE * sizeof(char));
            strcpy(chunks_received[chunk.chunk_index], chunk.chunk);
            printf("Chunk %d with message %s received from the client\n", chunk.chunk_index, chunk.chunk);
            received_chunks[chunk.chunk_index] = 1;

            if (sendto(server_socket, &chunk, sizeof(chunk), 0, (struct sockaddr *)client_addr, sizeof(*client_addr)) == -1)
            {
                perror("Error in sending message");
                close(server_socket);
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
}

void reconstruct_message(char **chunks_received, int num_chunks_received)
{
    char message[STRINGSIZE];
    message[0] = '\0';
    for (int i = 0; i < num_chunks_received; i++)
    {
        strcat(message, chunks_received[i]);
    }
    printf("The message received from the client is %s and length is %ld\n", message, strlen(message));
}

void receive_message()
{
    printf("Waiting for client to send message...\n");
    struct sockaddr_in client_addr;
    socklen_t client_addr_len = sizeof(client_addr);

    int server_socket = setup_server_socket(&client_addr);
    int num_chunks_received = receive_num_chunks(server_socket, &client_addr, &client_addr_len);

    char **chunks_received = (char **)malloc(num_chunks_received * sizeof(char *));
    receive_chunks(server_socket, chunks_received, num_chunks_received, &client_addr, &client_addr_len);
    close(server_socket);

    reconstruct_message(chunks_received, num_chunks_received);
}

int main()
{
    while (1)
    {
        send_message();

        printf("\n\n\n");

        receive_message();
    }

    return 0;
}

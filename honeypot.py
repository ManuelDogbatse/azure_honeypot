#!/usr/bin/env python3

import socket

HOST = "127.0.0.1" # Loopback address
PORT = 2222

def main():
    # Make a TCP socket that communicates via IP addresses
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Allow port to be reused after closing socket
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(100)

    # Get connected client's IP address and port number
    client_sock, (client_ip, client_port) = server_sock.accept()
    print(f"Connection from {client_ip}:{client_port}")
    # Send message to client
    client_sock.send(b"Hello!\n")
    # read message from client
    print(client_sock.recv(256).decode())

if __name__ == "__main__":
    main()

#!/usr/bin/env python3

import socket       # Library for network sockets
import paramiko     # Library for SSH server

HOST = "127.0.0.1"
PORT = 2222

    ## Send message to client
    #client_sock.send(b"Hello!\n")
    ## Read message from client
    #print(client_sock.recv(256).decode())


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
    # Create an SSH session over client socket
    transport = paramiko.Transport(client_sock)
    # Generate key required for SSH server and add key to SSH session
    server_key = paramiko.RSAKey.generate(2048)
    transport.add_server_key(server_key)
    # Create SSH server interface
    ssh = paramiko.ServerInterface()
    # Start server with SSH server interface
    transport.start_server(server=ssh)

if __name__ == "__main__":
    main()

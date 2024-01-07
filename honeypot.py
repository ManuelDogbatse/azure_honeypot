#!/usr/bin/env python3

import socket       # Network sockets
import paramiko     # SSH server
import threading    # Multithreading

HOST = "127.0.0.1"
PORT = 2222

    ## Send message to client
    #client_sock.send(b"Hello!\n")
    ## Read message from client
    #print(client_sock.recv(256).decode())

class SSHServer(paramiko.ServerInterface):
    def check_auth_password(self, username: str, password: str) -> int:
        print(f"username: {username}, password: {password}")
        return paramiko.AUTH_FAILED

def handle_connection(client_sock):
    # Create an SSH session over client socket
    transport = paramiko.Transport(client_sock)
    #server_key = paramiko.RSAKey.generate(2048)
    # Retrieve pre-generated key from file
    server_key = paramiko.RSAKey.from_private_key_file('id_rsa')
    transport.add_server_key(server_key)
    # Create SSH server interface
    ssh = SSHServer()
    # Start server with SSH server interface
    transport.start_server(server=ssh)

def main():
    # Make a TCP socket that communicates via IP addresses
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Allow port to be reused after closing socket
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen()

    # While loop to keep accepting connections when client socket disconnects
    while True:
        # Get connected client's IP address and port number
        client_sock, (client_ip, client_port) = server_sock.accept()
        print(f"Connection from {client_ip}:{client_port}")
        # Implement threading to handle mutliple SSH sessions
        t = threading.Thread(target=handle_connection, args=(client_sock,))
        t.start()

if __name__ == "__main__":
    main()

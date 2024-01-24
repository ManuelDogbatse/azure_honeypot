#!/usr/bin/env python3

import os
import sys
import re
import socket
import paramiko
import threading
import logging
import traceback
from base64 import b64encode
from binascii import hexlify

# Constant variables
# Default host and port set to localhost for testing
HOST = os.environ["HOST"]
PORT = int(os.environ["PORT"])

SERVER_KEY = paramiko.RSAKey(filename="server_key")
# Banner for Ubuntu 22.04
SSH_BANNER = "SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.6"
LOG_FILE = "logs/ssh_logs.log"

# Setting up logging format for paramiko
logging.basicConfig(
    format="%(asctime)s -- %(levelname)s -- %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO,
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logging.getLogger("paramiko").propagate = False

# Print message in stderr output stream
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# Encode user input with base64 encoding to avoid parsing errors
def encode_string(str):
    return b64encode(str.encode('utf-8')).decode('utf-8')

# Defining honeypot attributes
class HoneypotServer(paramiko.ServerInterface):
    # Get client's IP address and port number
    def __init__(self, client_addr):
        (self.client_ip, self.client_port) = client_addr

    # Defining server interface methods
    def get_allowed_auths(self, username):
        return "publickey,password"

    # Log password authentication attempt
    def check_auth_password(self, username, password):
        b64_username = encode_string(username)
        b64_password = encode_string(password)

        logging.info(f"password auth attempt -- ip address: {self.client_ip} -- port: {self.client_port} -- username: {b64_username} -- password: {b64_password}")
        return paramiko.AUTH_FAILED

    # Log public key authentication attempt
    def check_auth_publickey(self, username, key):
        b_username = username.encode('utf-8')

        fingerprint = hexlify(key.get_fingerprint()).decode(encoding="utf-8")
        logging.info(f"public key auth attempt -- ip address: {self.client_ip} -- port: {self.client_port} -- username: {b64_username} -- key name: {key.get_name()} -- md5 fingerprint: {encode_string(fingerprint)} -- base64: {key.get_base64()} -- bits: {key.get_bits()}")
        return paramiko.AUTH_FAILED

# Handle new connection to SSH server
def handle_connection(client_sock, client_addr):
    print(f"new client connection -- ip address: {client_addr[0]} -- port: {client_addr[1]}")
    try:
        # Create object to store client socket
        transport = paramiko.Transport(client_sock)
        # Retrieve pre-generated key from file
        transport.add_server_key(SERVER_KEY)
        # Change the banner to appear more convincing
        transport.local_version = SSH_BANNER
        # Create SSH server interface for client socket
        ssh = HoneypotServer(client_addr)
        try:
            # Start server with SSH server interface for client socket
            transport.start_server(server=ssh)
        except Exception as err:
            eprint("*** SSH negotiation failed")
            raise Exception("SSH negotiation failed")
    except Exception as err:
        print(f"The error: {err}")
        eprint(f"!!! Exception: {err.__class__}: {err}")
        try:
            transport.close()
        except Exception:
            pass

def main():
    try:
        # Make a TCP socket that communicates via IP addresses
        server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # Allow port to be reused after closing socket
        server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_sock.bind((HOST, PORT))
    except Exception as err:
        eprint(f"*** Bind failed: {err}")
        traceback.print_exc()
        sys.exit(1)

    threads = []
    # While loop to keep accepting connections when client socket disconnects
    while True:
        try:
            server_sock.listen(100)
            print(f"Listening for connection on port {PORT}...")
            print(f"IP address: {HOST}")
            # Get connected client's IP address and port number
            client_sock, client_addr = server_sock.accept()
        except Exception as err:
            eprint(f"*** Listen/accept failed: {err}")
            traceback.print_exc()
        # Invoking new session for connnected client
        # Implement threading to handle mutliple SSH sessions
        new_thread = threading.Thread(target=handle_connection, args=(client_sock, client_addr))
        new_thread.start()
        threads.append(new_thread)

        for thread in threads:
            thread.join()

if __name__ == "__main__":
    main()

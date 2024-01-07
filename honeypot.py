#!/usr/bin/env python3

import socket       # Network sockets
import paramiko     # SSH server
import threading    # Multithreading
import logging
from eprint import eprint

HOST = "127.0.0.1"
PORT = 2222
SERVER_KEY = paramiko.RSAKey(filename="server_key")

# Logging format
# asctime: Current time
# 
logging.basicConfig(
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        level=logging.INFO,
        )
        #filename="ssh_honeypot.log")

# Defining honeypot attributes
class HoneypotServer(paramiko.ServerInterface):

    def __init__(self, client_addr):
        (self.client_ip, self.client_port) = client_addr

    def check_channel_request(self, kind, chanid):
        logging.info(f"client called check_channel_request({self.client_ip}:{self.client_port}): {kind}")
        if kind == "session":
            return paramiko.OPEN_SUCCEEDED

    def get_allowed_auths(self, username):
        logging.info(f"client called get_allowed_auths ({self.client_ip}:{self.client_port}) with username {username}")
        return "publickey,password"

    #def check_auth_publickey(self, username, key):


    # Check login attempt using password, and log the username and password used
    def check_auth_password(self, username, password):
        logging.info(f"login attempt ({self.client_ip}:{self.client_port}): username: {username}, password: {password}")
        return paramiko.AUTH_FAILED

def handle_connection(client_sock, client_addr):
    try:
        # Create an SSH session over client socket
        transport = paramiko.Transport(client_sock)
        # Retrieve pre-generated key from file
        transport.add_server_key(SERVER_KEY)
        # Create SSH server interface
        ssh = HoneypotServer(client_addr)
        try:
            # Start server with SSH server interface
            transport.start_server(server=ssh)
#        except paramiko.ssh_exception.SSHException:
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

    threads = []
    # While loop to keep accepting connections when client socket disconnects
    while True:
        try:
            server_sock.listen(100)
            print("Listening for connection...")
            # Get connected client's IP address and port number
            client_sock, client_addr = server_sock.accept()
        except Exception as err:
            eprint(f"*** Listen/accept failed: {err}")
            traceback.print_exc()
        # Implement threading to handle mutliple SSH sessions
        new_thread = threading.Thread(target=handle_connection, args=(client_sock, client_addr))
        new_thread.start()
        threads.append(new_thread)

    for thread in threads:
        thread.join()

if __name__ == "__main__":
    main()

#!/bin/bash

# Create public and private server key
create_server_key() {
    # If server keys already exist, overwrite them
    if [[ $(find "$(pwd)" -maxdepth 1 -name "server_key*") ]] 
    then
        printf "SSH server keys already exist.\nGenerating new public and private keys for SSH server...\n"
    ssh-keygen -t rsa -b 3072 -f server_key -q -N "" <<< $$'\ny' >/dev/null 2>&1
    echo "SSH keys successfully generated"
    else
        echo "Generating public and private keys for SSH server..."
    ssh-keygen -t rsa -b 3072 -f server_key -q -N ""
    echo "SSH keys successfully generated"
    fi
}

create_server_key

#!/bin/bash

ENV="./.env"

# Change IP address environment variable to default route
update_ip() {
    replace_ip=""
    while [[ "$replace_ip" != 'y' && "$replace_ip" != 'n' ]]
    do
        echo "Would you like to update the IP address? (y/n)"
        read input
        replace_ip="$(echo "$input" | awk '{print tolower($0)}')"
        if [[ "$replace_ip" == 'y' ]]
        then
            echo "Updating IP address"
            sed -i 's/HOST=\".*\"/HOST=\"0.0.0.0\"/' "$ENV"
            printf "IP address updated to default route (0.0.0.0)\n\n"
        elif [[ "$replace_ip" == 'n' ]]
        then
            printf "Skipping IP address update\n\n"
            break
        else
            printf "Invalid input. Did not input 'y' or 'n'\n\n"
        fi
    done
}

# Change port environment variable to user input
update_port() {
    port=""
    re='^[0-9]+$'
    # Loop until user inputs a number between 1024 and 49151
    while [[ ! "$port" =~ $re ]] || ! [[ "$port" -ge "1024" && "$port" -le "49151" ]] 
    do
        echo "Please enter a port number for the server (1024-49151). Press Enter to skip:"
        read port
        if [[ "$port" =~ $re ]]
        then
            if [[ "$port" -ge "1024" && "$port" -le "49151" ]]
            then
                echo "Changing port number to $port"
                sed -i 's/PORT=[0-9]*/PORT='"$port"'/' "$ENV"
                printf "Port updated to %s\n\n" "$port"
            else
                printf "Invalid input. Port number not in the valid range\n\n"
            fi
        elif [[ -z "$port" ]]
        then
            printf "Skipping port number update\n\n"
            break
        else
            printf "Invalid input. Inputted string instead of number\n\n"
        fi
    done 
}

# Change app.ipgeolocation.io API key
update_api_key() {
    echo "Please enter the API key from your app.ipgeolocation.io account. Press Enter to skip:"
    read api_key
    if [[ -z "$api_key" ]]
    then
        printf "Skipping API key update\n\n"
    else
        echo "Changing API key to $api_key"
        sed -i 's/IPGEO_API_KEY=\".*\"/IPGEO_API_KEY=\"'"$api_key"'\"/' "$ENV"
        printf "API key updated to ${api_key}\n\n"
    fi
}

# Create public and private server keys
update_server_keys() {
    # If server keys already exist, ask user for permission to overwrite current keys
    if [[ $(find "$(pwd)" -maxdepth 1 -name "server_key*") ]] 
    then
        replace_keys=""
        # Loop until user enters 'y' for yes or 'n' for no
        while [[ "$replace_keys" != 'y' && "$replace_keys" != 'n' ]]
        do
            echo "SSH server keys already exist."
            echo "Would you like to replace the keys? (y/n)"
            read input
            replace_keys="$(echo "$input" | awk '{print tolower($0)}')"
            if [[ "$replace_keys" == 'y' ]]
            then
                echo "Generating new public and private keys for SSH server..."
                ssh-keygen -t rsa -b 3072 -f server_key -q -N "" <<< $$'\ny' >/dev/null 2>&1
                printf "SSH keys successfully replaced\n\n"
            elif [[ "$replace_keys" == 'n' ]]
            then
                printf "Skipping SSH key update\n\n"
            else
                printf "Invalid input. Did not input 'y' or 'n'\n\n"
            fi
        done
    else
        echo "Generating public and private keys for SSH server..."
        ssh-keygen -t rsa -b 3072 -f server_key -q -N ""
        printf "SSH keys successfully generated\n\n"
    fi
}

update_ip
update_port
update_api_key
update_server_keys

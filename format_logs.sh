#!/bin/bash

# Log arrays
declare -a connection_logs=()
declare -a passwd_auth_logs=()
declare -a pub_key_auth_logs=()

# Place desired logs in respective arrays
while IFS='\n' read -r line
do
    # Get new connection logs
    if [ $(grep -ic -P 'no auth attempt' <<< "$line") -eq 1 ]
    then
        connection_logs+=("$line")
    elif [ $(grep -ic -P 'password auth attempt' <<< "$line") -eq 1 ]
    then
        passwd_auth_logs+=("$line")
    elif [ $(grep -ic -P 'public key auth attempt' <<< "$line") -eq 1 ]
    then
        pub_key_auth_logs+=("$line")
    fi
done < "./ssh_honeypot.log"

echo "New Connection Logs:"
for line in "${connection_logs[@]}"
do
    echo $line
done
echo ""

echo "Password Authentication Logs:"
for line in "${passwd_auth_logs[@]}"
do
    echo $line
done
echo ""

echo "Public Key Authentication Logs:"
for line in "${pub_key_auth_logs[@]}"
do
    echo $line
done
echo ""

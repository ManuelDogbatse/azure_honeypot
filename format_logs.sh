#!/bin/bash

# Log arrays
declare -a connection_logs=()
declare -a passwd_auth_logs=()
declare -a pub_key_auth_logs=()

# Place desired logs in respective arrays
get_ssh_logs() {
    while IFS='\n' read -r line
    do
        # Get new connection logs
        if [[ "$line" =~ .*"no auth attempt".* ]];
        then
            connection_logs+=("$line")
        elif [[ "$line" =~ .*"password auth attempt".* ]];
        then
            passwd_auth_logs+=("$line")
        elif [[ "$line" =~ .*"public key auth attempt".* ]];
        then
            pub_key_auth_logs+=("$line")
        fi
    done < "$1"
}
get_ssh_logs "./ssh_honeypot.log"

geo_log="${connection_logs[0]}"
# Trim space in awk function
trim_space='{for (i=1; i <= NF; i++) {
    gsub(/^[ \t]+/,"",$i)
    gsub(/[ \t]+$/,"",$i)
} }'
# Print all columns in awk function
print_columns='{for (i=1; i <= NF; i++) {
    print $i
} }'
geo_log_awk="$trim_space $print_columns"
IFS=$'\n' read -r -d '' -a geo_log_arr < <(echo "$geo_log" | awk -F '--' "$geo_log_awk")
#geo_log_arr=( $(echo "$geo_log" | awk -F '--' "$geo_log_awk") ) 
echo "Arr: ${geo_log_arr[0]}"
#echo "Message: $msg"
#passwd_log="${passwd_auth_logs[0]}"
#passwd_log_awk="$trim_space $print_all"
#echo "$passwd_log" | awk -F '--' "$passwd_log_awk"
#pub_key_log="${pub_key_auth_logs[0]}"
#pub_key_log_awk="$trim_space $print_all"
#echo "$pub_key_log" | awk -F '--' "$pub_key_log_awk"

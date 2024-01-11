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
trim_space='{for (i=1; i <= NF; i++) {
    gsub(/^[ \t]+/,"",$i)
    gsub(/[ \t]+$/,"",$i)
} }' 
geo_log_awk='{print $0}'
geo_log_awk_final="$trim_space $geo_log_awk"
echo "$geo_log" | awk -F '--' "$geo_log_awk_final"
#echo "New Connection Logs:"
#for line in "${connection_logs[@]}"
#do
#    echo $line
#done
#echo ""
#
#echo "Password Authentication Logs:"
#for line in "${passwd_auth_logs[@]}"
#do
#    echo $line
#done
#echo ""
#
#echo "Public Key Authentication Logs:"
#for line in "${pub_key_auth_logs[@]}"
#do
#   echo $line
#done
#echo ""

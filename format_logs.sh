#!/bin/bash

# awk functions
# Trim space in awk function
TRIM_SPACE_COMMAND='{for (i=1; i <= NF; i++) {
    gsub(/^[ \t]+/,"",$i)
    gsub(/[ \t]+$/,"",$i)
} }'
# Print all columns in awk function
PRINT_COLUMNS_COMMAND='{for (i=1; i <= NF; i++) {
    print $i
} }'
AWK_COMMAND="$TRIM_SPACE_COMMAND $PRINT_COLUMNS_COMMAND"

# Regular expressions for log values
REGEXP_STD="(?<=\:\s).*$"
REGEXP_INPUT="(?<=').*(?='$)"

# Log arrays
declare -a geo_logs=()
declare -a uname_logs=()
declare -a passwd_logs=()
declare -a pub_key_logs=()
declare -a auth_type_logs=()

# Format geolocation logs
format_geo_logs() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a geo_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    echo "Time: ${geo_log_arr[0]}"
    echo "Message: ${geo_log_arr[2]}"
    geo_log_arr[3]=$(echo "${geo_log_arr[3]}" | grep -Po "$REGEXP_STD")
    echo "IP Address: ${geo_log_arr[3]}"
    geo_log_arr[5]=$(echo "${geo_log_arr[5]}" | grep -Po "$REGEXP_INPUT")
    echo "Username: ${geo_log_arr[5]}"
}

# Place desired logs in respective arrays
get_ssh_logs() {
    while IFS='\n' read -r line
    do
        # Get new connection logs
        if [[ "$line" =~ .*"no auth attempt".* ]];
        then
            format_geo_logs "$line"
        elif [[ "$line" =~ .*"password auth attempt".* ]];
        then
            declare -a passwd_auth_logs=()
            passwd_auth_logs+=("$line")
        elif [[ "$line" =~ .*"public key auth attempt".* ]];
        then
            declare -a pub_key_auth_logs=()
            pub_key_auth_logs+=("$line")
        fi
    done < "$1"
}
get_ssh_logs "./ssh_honeypot.log"

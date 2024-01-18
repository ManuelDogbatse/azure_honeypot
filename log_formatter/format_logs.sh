#!/bin/bash

LOG_FILE="ssh_logs.log"
LOG_DIR="logs/"
TEST_IP_ADDR="1.1.1.1"

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

# Decode custom '%' symbol encoding used to prevent user input from interfering with log parsing
decode_string() {
    echo "$1" | sed -e 's/%%/%/g' | sed -e 's/%-/-/g' | sed -e 's/%'\''/'\''/g'
}

# Write logs to file
write_to_file() {
    echo "$1" >> "${LOG_DIR}$2"
}

# Format password authentication logs
format_password_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a password_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    timestamp="${password_log_arr[0]}"
    ip_address="$(echo "${password_log_arr[3]}" | grep -Po "$REGEXP_STD")"
    username="$(decode_string "$(echo "${password_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )"
    password="$(decode_string "$(echo "${password_log_arr[6]}" | grep -Po "$REGEXP_INPUT")" )"
    label="${username:0:10} $ip_address $timestamp"

    # Make API call to IP geolocation website to retrieve latitude, longitude, and country
    # Uncomment the line below when hosted publicly
    #response=$(curl -4 -s "https://api.ipgeolocation.io/ipgeo?apiKey=${IPGEO_API_KEY}&ip=${ip_address}")
    # Comment the line below when hosted publicly
    response=$(curl -4 -s "https://api.ipgeolocation.io/ipgeo?apiKey=${IPGEO_API_KEY}&ip=${TEST_IP_ADDR}")
    # Pass values in JSON object to variables
IFS=$'\n' read -r -d '' latitude longitude country < <(echo "$response" | jq -r '.latitude,.longitude,.country_name')

    # Create new log for syslog server and write to log file
    password_log_str="label:$label,ip_address:$ip_address,latitude:$latitude,longitude:$longitude,country:$country,username:$username,password:$password,timestamp:$timestamp"
    write_to_file "$password_log_str" "./ssh_password_logins.log"
    #echo "$password_log_str"
}

# Format public key authentication logs
format_public_key_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a public_key_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    timestamp="${public_key_log_arr[0]}"
    ip_address="$(echo "${public_key_log_arr[3]}" | grep -Po "$REGEXP_STD")"
    username="$(decode_string "$(echo "${public_key_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )"
    key_type=$(echo "${public_key_log_arr[6]}" | grep -Po "$REGEXP_STD")
    fingerprint=$(echo "${public_key_log_arr[7]}" | grep -Po "$REGEXP_STD")
    base64=$(echo "${public_key_log_arr[8]}" | grep -Po "$REGEXP_STD")
    bits=$(echo "${public_key_log_arr[9]}" | grep -Po "$REGEXP_STD")
    label="${username:0:10} $ip_address $timestamp"
     
    # Make API call to IP geolocation website to retrieve latitude, longitude, and country
    # Uncomment the line below when hosted publicly
    #response=$(curl -4 -s "https://api.ipgeolocation.io/ipgeo?apiKey=${IPGEO_API_KEY}&ip=${ip_address}")
    # Comment the line below when hosted publicly
    response=$(curl -4 -s "https://api.ipgeolocation.io/ipgeo?apiKey=${IPGEO_API_KEY}&ip=${TEST_IP_ADDR}")
    # Pass values in JSON object to variables
IFS=$'\n' read -r -d '' latitude longitude country < <(echo "$response" | jq -r '.latitude,.longitude,.country_name')

    # Create new log for syslog server and write to log file
    public_key_log_str="label:$label,ip_address:$ip_address,latitude:$latitude,longitude:$longitude,country:$country,username:$username,key_type:$key_type,fingerprint:$fingerprint,base64:$base64,bits:$bits,timestamp:$timestamp"
    write_to_file "$public_key_log_str" "./ssh_public_key_logins.log"
    #echo "$public_key_log_str"
}

# Format SSH logs based on the type of authentication used
format_ssh_logs() {
    if [[ "$1" =~ .*"password auth attempt".* ]];
    then
        format_password_log "$1"
    elif [[ "$1" =~ .*"public key auth attempt".* ]];
    then
        format_public_key_log "$1"
    fi
}

# Read log file line by line and format each log
read_log_file() {
    while IFS='\n' read -r line
    do
        format_ssh_logs "$line"
    done < "$1"
}

# Format the latest log from the log file
format_log_on_modify() {
    line="$(tail -n1 "$1")"
    format_ssh_logs "$line"
}

# Listen to modifications to the log file and format the latest line when added
tail_log_file() {
    while inotifywait -qq -e modify "$1"
    do
        # Run each modification in the background for parallelisation
        format_log_on_modify "$1" &
    done
}

#read_log_file "${LOG_DIR}${LOG_FILE}"
tail_log_file "${LOG_DIR}$LOG_FILE"

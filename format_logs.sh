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

decode_string() {
    echo "$1" | sed -e 's/%%/%/g' | sed -e 's/%-/-/g' | sed -e 's/%'\''/'\''/g'
}

# Write logs to file
write_to_file() {
    echo "$1" >> "$2"
}

# Format geolocation logs
format_geo_logs() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a geo_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    geo_log_arr[3]=$(echo "${geo_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    country="United Kingdom"
    label="$country ${geo_log_arr[3]}"
    latitude=-4.0000
    longitude=25.0000
    geo_log_str="label:$label,ip_address:${geo_log_arr[3]},latitude:$latitude,longitude:$longitude,country:$country,timestamp:${geo_log_arr[0]}"
    #write_to_file "${geo_log_str" "./geo.log"
    echo "$geo_log_str"
}

# Format username logs
format_uname_logs() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a uname_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    uname_log_arr[3]=$(echo "${uname_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    uname_log_arr[5]=$(echo "${uname_log_arr[5]}" | grep -Po "$REGEXP_INPUT")
    label="${uname_log_arr[5]} ${uname_log_arr[3]}"
    uname_log_str="label:$label,ip_address:${uname_log_arr[3]},username:${uname_log_arr[5]},timestamp:${uname_log_arr[0]}"
    #write_to_file "$uname_log_str" "./uname.log"
    echo "$uname_log_str"
}

# Format password authentication logs
format_passwd_logs() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a passwd_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    passwd_log_arr[3]=$(echo "${passwd_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    passwd_log_arr[5]=$(decode_string "$(echo "${passwd_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )
    # Reformat password field
    passwd_log_arr[6]=$(decode_string "$(echo "${passwd_log_arr[6]}" | grep -Po "$REGEXP_INPUT")" )
    label="${passwd_log_arr[5]} ${passwd_log_arr[6]} ${passwd_log_arr[3]}"
    passwd_log_str="label:$label,ip_address:${passwd_log_arr[3]},username:${passwd_log_arr[5]},password:${passwd_log_arr[6]},timestamp:${passwd_log_arr[0]}"
    #write_to_file "$passwd_log_str" "./passwd.log"
    echo "$passwd_log_str"
}

# Place desired logs in respective arrays
get_ssh_logs() {
    while IFS='\n' read -r line
    do
        if [[ "$line" =~ .*"no auth attempt".* ]];
        then
            format_geo_logs "$line"
            format_uname_logs "$line"
        elif [[ "$line" =~ .*"password auth attempt".* ]];
        then
            format_passwd_logs "$line"
        elif [[ "$line" =~ .*"public key auth attempt".* ]];
        then
            declare -a pub_key_auth_logs=()
            pub_key_auth_logs+=("$line")
        fi
    done < "$1"
}
get_ssh_logs "./ssh_honeypot.log"

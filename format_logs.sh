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
format_geo_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a geo_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    geo_log_arr[3]=$(echo "${geo_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    country="United Kingdom"
    #label="$country ${geo_log_arr[3]}"
    label="geo_log"
    latitude=-4.0000
    longitude=25.0000
    geo_log_str="label:$label,ip_address:${geo_log_arr[3]},latitude:$latitude,longitude:$longitude,country:$country,timestamp:${geo_log_arr[0]}"
    write_to_file "$geo_log_str" "./geo.log"
    #echo "$geo_log_str"
}

# Format username logs
format_uname_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a uname_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    uname_log_arr[3]=$(echo "${uname_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    uname_log_arr[5]=$(decode_string "$(echo "${uname_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )
    #label="${uname_log_arr[5]} ${uname_log_arr[3]}"
    label="uname_log"
    uname_log_str="label:$label,ip_address:${uname_log_arr[3]},username:${uname_log_arr[5]},timestamp:${uname_log_arr[0]}"
    write_to_file "$uname_log_str" "./uname.log"
    #echo "$uname_log_str"
}

# Format password authentication logs
format_passwd_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a passwd_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    passwd_log_arr[3]=$(echo "${passwd_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    passwd_log_arr[5]=$(decode_string "$(echo "${passwd_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )
    # Reformat password field
    passwd_log_arr[6]=$(decode_string "$(echo "${passwd_log_arr[6]}" | grep -Po "$REGEXP_INPUT")" )
    #label="${passwd_log_arr[5]} ${passwd_log_arr[6]} ${passwd_log_arr[3]}"
    label="passwd_log"
    passwd_log_str="label:$label,ip_address:${passwd_log_arr[3]},username:${passwd_log_arr[5]},password:${passwd_log_arr[6]},timestamp:${passwd_log_arr[0]}"
    write_to_file "$passwd_log_str" "./passwd.log"
    #echo "$passwd_log_str"
}

# Format public key authentication logs
format_pub_key_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a pub_key_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    pub_key_log_arr[3]=$(echo "${pub_key_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    pub_key_log_arr[5]=$(decode_string "$(echo "${pub_key_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )
    # Reformat key name field
    pub_key_log_arr[6]=$(echo "${pub_key_log_arr[6]}" | grep -Po "$REGEXP_STD")
    # Reformat fingerprint field
    pub_key_log_arr[7]=$(echo "${pub_key_log_arr[7]}" | grep -Po "$REGEXP_STD")
    # Reformat base64 field
    pub_key_log_arr[8]=$(echo "${pub_key_log_arr[8]}" | grep -Po "$REGEXP_STD")
    # Reformat bits field
    pub_key_log_arr[9]=$(echo "${pub_key_log_arr[9]}" | grep -Po "$REGEXP_STD")
    label="pub_key_log"
    pub_key_log_str="label:$label,ip_address:${pub_key_log_arr[3]},username:${pub_key_log_arr[5]},key_name:${pub_key_log_arr[6]},fingerprint:${pub_key_log_arr[7]},base64:${pub_key_log_arr[8]},bits:${pub_key_log_arr[9]},timestamp:${pub_key_log_arr[0]}"
    write_to_file "$pub_key_log_str" "./pub_key.log"
    #echo "$pub_key_log_str"
}

format_auth_type_log() {
    # Split log by '--' and store each line as an item in an array
    IFS=$'\n' read -r -d '' -a auth_type_log_arr < <(echo "$1" | awk -F '--' "$AWK_COMMAND")
    # Reformat IP address field
    auth_type_log_arr[3]=$(echo "${auth_type_log_arr[3]}" | grep -Po "$REGEXP_STD")
    # Reformat username field
    auth_type_log_arr[5]=$(decode_string "$(echo "${auth_type_log_arr[5]}" | grep -Po "$REGEXP_INPUT")" )
    case "${auth_type_log_arr[2]}" in
        "password auth attempt")
            auth_type="passwd";;
        "public key auth attempt")
            auth_type="pub_key";;
    esac
    label="auth_type"
    auth_type_log_str="label:$label,ip_address:${auth_type_log_arr[3]},username:${auth_type_log_arr[5]},auth_type:$auth_type,timestamp:${auth_type_log_arr[0]}"
    write_to_file "$auth_type_log_str" "./auth_type.log"
    #echo "$auth_type_log_str"
}

# Place desired logs in respective arrays
get_ssh_logs() {
    while IFS='\n' read -r line
    do
        if [[ "$line" =~ .*"no auth attempt".* ]];
        then
            format_geo_log "$line"
            format_uname_log "$line"
        elif [[ "$line" =~ .*"password auth attempt".* ]];
        then
            format_passwd_log "$line"
            format_auth_type_log "$line"
        elif [[ "$line" =~ .*"public key auth attempt".* ]];
        then
            format_pub_key_log "$line"
            format_auth_type_log "$line"
        fi
    done < "$1"
}
get_ssh_logs "./ssh_honeypot.log"

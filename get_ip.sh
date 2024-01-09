#!/bin/bash

# Get IP type from flag
# 1 - Localhost "127.0.0.1"
# 2 - Private IP Address "10.x.x.x|172.16.x.x|192.168.x.x"
# 3 - Public IP Address "x.x.x.x"
get_ip_type() {
    local OPTIND t
    getopts t: OPTION
    echo $OPTARG
}

# Change IP address environment variable
update_env() {
	# Change value of IP address inside string
    sed -i 's/\".*\"/\"1.2.3.4\"/' $1
}

case $ip_type in
    1) echo "Localhost";;
    2) echo "Private IP address";;
    3) echo "Public IP address";;
esac

ip_type=$(get_ip_type $@)
echo "Type of IP: $ip_type"
update_env "./.env"

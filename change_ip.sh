#!/bin/bash

ENV="./.env"
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
    sed -i 's/HOST=\".*\"/HOST=\"'"$1"'\"/' $2
}

# Get the new IP address and update the IP address environment variable
change_ip() {
    case $1 in
        1)
            echo "Changing honeypot IP address to localhost"
            update_env "127.0.0.1" "$ENV"
            echo "IP address updated to 127.0.0.1"
            ;;
        2)  
            priv_ip="$(hostname -I | awk '{print $1}')"
            echo "Changing honeypot IP address to private IP address"
            update_env "$priv_ip" "$ENV"
            echo "IP address updated to $priv_ip"
            ;;
        3) 
            pub_ip="$(curl -4 -s icanhazip.com)"
            echo "Changing honeypot IP address to public IP address"
            update_env "$pub_ip" "$ENV"
            echo "IP address updated to $pub_ip"
            ;;
    esac
}

ip_type=$(get_ip_type $@)
echo "Type of IP: $ip_type"
change_ip $ip_type

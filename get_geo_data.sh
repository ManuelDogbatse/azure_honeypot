#!/bin/bash

# Get API key from .env file
ENV="./.env"
API_KEY="$(sed -n '/IPGEO_API_KEY/p' "$ENV" | awk -F '"' '{print $2}')"
IP_ADDR="1.1.1.1"

# Make API call to IP geolocation website to retrieve latitude, longitude, and country
response=$(curl -4 -s "https://api.ipgeolocation.io/ipgeo?apiKey=${API_KEY}&ip=${IP_ADDR}")
# Pass values in JSON object to variables
#echo "$(echo "$response" | jq '.')"
IFS=$'\n' read -r -d '' latitude longitude country < <(echo "$response" | jq -r '.latitude,.longitude,.country_name')
printf 'Latitude: %s\nLongitude: %s\nCountry: %s\n' "$latitude" "$longitude" "$country"

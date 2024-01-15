#!/bin/bash

FILE="./ssh_logs.log"

while inotifywait -qq -e modify "./ssh_logs.log"
do
    echo "Modification made"
    last_line=$(tail -n1 "$FILE")
    echo "Last Line: $last_line"
done

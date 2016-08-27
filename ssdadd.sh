#!/bin/bash

VERSION="0.1"
AUTHOR="Noé Godinho"
EMAIL="noe.godinho.92@gmail.com"
GIT="https://github.com/noegodinho/ssdadd"

echo "SSDAdd $VERSION: Script to add a non included disk in the HDDTemp database"
echo "Copyright (C) 2016: $AUTHOR <$EMAIL>, $GIT"$'\n'

if [ $# -eq 0 ]; then
    echo 'Usage: sudo ./hddtemp.sh disk_path [HDDTemp_database_path]'
    exit 1
fi

if [ $EUID -ne 0 ]; then
    echo 'This script has to be executed as root.'
    exit 1
else
    echo 'Script working as root...'
fi

if [ -e "$1" ]; then
    echo 'Disk path is valid...'
else
    echo 'The disk path provided is not valid'
    exit 1    
fi

WHICH="$(which hddtemp)"

if [ ! -z "$WHICH" ]; then
    echo 'HDDTemp is installed...'
else
    echo 'Please, install HDDTemp first and check if your disk is not in the database'
    exit 1
fi

WHICH="$(which smartctl)"

if [ ! -z "$WHICH" ]; then
    echo 'Smartctl is installed...'
else
    echo 'Please, install Smartctl too'
    exit 1
fi

if [ -z "$2" ]; then
    DATABASE="$(find -O3 / -name 'hddtemp.db'  2>/dev/null)"
else
    DATABASE="$2"
fi

if [ ! -z "$DATABASE" ] && [ -f "$DATABASE" ]; then
    echo 'Database file found...'
else
    echo 'Database file not found, check if HDDTemp is correctly installed or provide the path in the 2 parameter'
    exit 1
fi

MODELINFO="$(smartctl -i $1)"
var=1

while read -r line; do       
    if [ "$var" -eq 6 ]; then
        MODEL="$line"
        break
    fi

    ((var++))
done <<< "$MODELINFO"

var=1
DISK=""

for word in $MODEL; do
    if [ "$var" -ge 3 ]; then
        DISK="$DISK$word "
    fi

    ((var++))
done

DISK=${DISK::-1}
echo "Disk found: $DISK"
read -p "Is that your disk? [y/N] " prompt

if [[ $prompt == "y" || $prompt == "Y" ]]; then
    echo ""
else
    echo "Check if your disk path is correct or contact the creator"
    echo "Exiting program..."
    exit 1
fi

if echo "$DISK" | grep -q "Samsung SSD"; then
    DISK=$'"'"${DISK::-1} B"$'"'
else
    DISK=$'"'"$DISK"$'"'
fi

INFO="$(cat $DATABASE)"

if echo "$INFO" | grep -q "$DISK"; then
    echo "Your disk exists in the database"
    echo "Exiting program..."
    exit 1
else
    echo "Your disk was not found in the database..."
fi

SMARTCTL="$(smartctl -A $1)"
var=1
TEMP_ID=""

while read -r line; do
    if [ "$var" -ge 7 ]; then
        if echo "$line" | grep -q "Airflow_Temperature_Cel"; then
            for word in $line; do
                TEMP_ID=$word
                break
            done

            break        
        fi
    fi

    ((var++))
done <<< "$SMARTCTL"

if [ -z "$TEMP_ID" ]; then
    echo "Could not find the Temperature ID of your disk, please contact the creator"
    echo "Exiting program..."
    exit 1
else
    echo "Temperature ID found..."
fi

APPEND="$DISK"$'\t'"$TEMP_ID"$'\t'"C"$'\t'"$DISK"
INSERT="$(echo $APPEND >> $DATABASE)"

if [ -z "$INSERT" ]; then
    echo "The Temperature ID of your disk was inserted successfully!"
    echo "To test if the temperature is well read, use: sudo hddtemp disk_path"
    echo "Exiting program..."    
else
    echo "The Temperature ID could not be inserted on the file"
    echo "Exiting program..."
    exit 1
fi

exit 0

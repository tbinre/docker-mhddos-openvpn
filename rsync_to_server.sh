#!/bin/bash

# Check if no arguments are provided
if [ "$#" -eq 0 ]; then
    echo "Server address is missing"
    echo "Usage: rsync_to_server.sh 1.1.1.1"
    exit 1
fi

# Sync local directory contents to the server's /home/docker-mhddos-openvpn/
rsync -avh --delete --exclude=".DS_Store" ./ $1:/home/docker-mhddos-openvpn/

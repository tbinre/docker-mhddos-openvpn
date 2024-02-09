#!/bin/bash
set -e

directory="/openvpn"
extension=".ovpn"

# Check if the directory exists
if [ -d "$directory" ]; then
    # Get a list of files with the specified extension
    files=("$directory"/*"$extension")

    # Check if there are any files with the specified extension
    if [ ${#files[@]} -eq 0 ]; then
        echo "No files with the specified extension found in the directory."
        exit 1
    fi

    # Get a random index within the range of the array length
    random_index=$((RANDOM % ${#files[@]}))

    # Get the randomly selected file
    random_file="${files[$random_index]}"

    echo "Randomly selected file: $random_file"
else
    echo "Directory not found: $directory"
    exit 1
fi

# Set Cloudflare DNS
echo "nameserver 1.1.1.1 1.0.0.1" > /etc/resolv.conf

# Start OpenVPN
/usr/sbin/openvpn --config $random_file --auth-user-pass <(echo -e "${VPN_USER}\n${VPN_PASSWORD}") &

open_vpn_pid=$!
sleep 4

if ps -p $open_vpn_pid > /dev/null; then
    echo "Success: OpenVPN is running in the background with PID $open_vpn_pid."
else
    echo "Error: OpenVPN failed to start."
    exit 1
fi

# Run restart script
python /restart.py &

# Run main program (mhddos)
exec ./mhddos_proxy_linux --lang ${MHDDOS_LANG:-en} --copies ${MHDDOS_COPIES:-auto} --t ${MHDDOS_THREADS:-4000} --use-my-ip ${MHDDOS_USE_IP_PERCENTAGE:-5} --user-id $IT_ARMY_USER_ID
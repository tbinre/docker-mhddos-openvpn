#!/bin/bash
set -e

if [ -v VPN_USER ] || [ -v VPN_PASSWORD ]; then
    echo "ERROR: VPN_USER and VPN_PASSWORD variables no more supported"
    echo "ERROR: Please move VPN provider credentials to \"openvpn/provider-name-dir/auth-txt file.\""
    echo "ERROR: \"openvpn/provider-name-dir/auth-txt file.\" should contain two lines, in first - login, second line should contain password"
    exit 1
fi

# Cleanup /tmp
rm -rf /tmp/*

# Set Cloudflare DNS
echo "nameserver 1.1.1.1 1.0.0.1" > /etc/resolv.conf

if [ -z "$DISABLE_VPN" ] || [ "$DISABLE_VPN" = "false" ] || [ "$DISABLE_VPN" = "0" ]; then
    # Get server IP address for futurer checks
    external_ip_without_vpn=$(curl -s --ipv4 ifconfig.me)
    DEFAULT_MHDDOS_USE_IP_PERCENTAGE=5

    # Pick random ovpn file for VPN connection
    directory="/openvpn"
    extension=".ovpn"
    if [ -d "$directory" ]; then
        # Get a list of files with the specified extension
        files=("$directory"/**/*"$extension")

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

        ovpn_file_dir=$(dirname "$random_file")

        # Check is credentials file exists
        if ! [ -e "$ovpn_file_dir/auth.txt" ]; then
            echo "VPN Provider auth file does not exists in directory: $ovpn_file_dir"
            echo "Restarting..."
            exit 1
        fi

        echo "====================================="
        echo "Randomly selected ovpn file: $random_file"
        echo "Credentials file: $ovpn_file_dir/auth.txt"
        echo "====================================="
    else
        echo "Directory not found: $directory"
        echo "Restarting..."
        exit 1
    fi

    # Start OpenVPN
    cd $ovpn_file_dir
    /usr/sbin/openvpn --config $random_file \
        --auth-user-pass $ovpn_file_dir/auth.txt \
        --auth-nocache \
        --pull-filter ignore "ifconfig-ipv6" \
        --pull-filter ignore "route-ipv6" \
        &

    open_vpn_pid=$!
    sleep 10

    # Check is OpenVPN running
    if ps -p $open_vpn_pid > /dev/null; then
        echo "Success: OpenVPN is running in the background with PID $open_vpn_pid."
    else
        echo "Error: OpenVPN failed to start."
        exit 1
    fi

    # Double check is IP address changed
    external_ip_with_vpn=$(curl -s --ipv4 ifconfig.me)
    if [ "$external_ip_without_vpn" == "$external_ip_with_vpn" ]; then
        echo "IP Address has not been changed, something wrong with VPN connection. Restarting..."
        exit 1
    else
        echo "Initial IP $external_ip_without_vpn has changed to $external_ip_with_vpn"
    fi

    # MHDDOS_BIND_IP_ADDRESS=$(ip addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    MHDDOS_BIND_IFACE=tun0

    # Start watchdog to restart container in case if VPN connection stops working and external IP became to original
    python3 /ip_address_watchdog.py $external_ip_without_vpn &
else
    echo "====================================="
    echo "-------------- WARNING --------------"
    echo "VPN IS DISABLED BY DISABLE_VPN OPTION"
    echo "====================================="
    DEFAULT_MHDDOS_USE_IP_PERCENTAGE=0
    # MHDDOS_BIND_IP_ADDRESS=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    MHDDOS_BIND_IFACE=eth0
fi

# Run restart script
python3 /restart.py &

# Run main program (mhddos)
exec /usr/bin/mhworker \
    --ifaces $MHDDOS_BIND_IFACE \
    --lang ${MHDDOS_LANG:-en} \
    --copies ${MHDDOS_COPIES:-auto} \
    --t ${MHDDOS_THREADS:-4000} \
    --use-my-ip ${MHDDOS_USE_IP_PERCENTAGE:-$DEFAULT_MHDDOS_USE_IP_PERCENTAGE} \
    --user-id $IT_ARMY_USER_ID

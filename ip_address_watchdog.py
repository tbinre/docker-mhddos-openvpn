import os
import signal
import sys
import time
import urllib.request
import ipaddress


def validate_ip_address(ip_address):
    try:
        return ipaddress.ip_address(ip_address)
    except ValueError:
        print("Invalid IP Address {ip}".format(ip=ip_address))
        return None
    
    
def get_public_ip():
    try:
        with urllib.request.urlopen("https://ifconfig.me/ip") as response:
            if response.getcode() == 200:
                return response.read().decode("utf-8").strip()
            else:
                print("Error: Unable to fetch IP address. Status code: {response_code}".format(
                    response_code=response.getcode()))
                return None
    except urllib.error.URLError as e:
        print("Error: {e}".format(e=e))
        return None


if __name__ == "__main__":
    server_initial_ip = validate_ip_address(sys.argv[1])
    while True:
        public_ip_address = validate_ip_address(get_public_ip())
        if not server_initial_ip or not public_ip_address or public_ip_address == server_initial_ip:
            os.kill(1, signal.SIGUSR1)
        time.sleep(10)

FROM debian:bullseye-slim

# Install packages
# First line required packages
# Second line optional debugging packages
RUN apt-get update && apt-get install --no-install-recommends --yes \
    openvpn procps execline python3 curl ca-certificates \
    iputils-ping \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download mhddos
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
    x86_64) FILENAME="mhddos_proxy_linux" ;; \
    aarch64) FILENAME=mhddos_proxy_linux_arm64 ;; \
    *) echo "Unsupported architecture ${ARCH}"; exit 1 ;; \
    esac && \
    curl -sL https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/$FILENAME -o /usr/bin/mhworker \
    && chmod +x /usr/bin/mhworker

VOLUME [ "/openvpn" ]
VOLUME [ "/tmp" ]

COPY restart.py /restart.py
COPY ip_address_watchdog.py /ip_address_watchdog.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
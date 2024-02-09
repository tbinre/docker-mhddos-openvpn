FROM ghcr.io/porthole-ascend-cinnamon/mhddos_proxy

# Install packages
# First line required packages
# Second line optional debugging packages
RUN apt-get update && apt-get install --no-install-recommends --yes \
    openvpn procps execline python \
    curl iputils-ping \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

VOLUME [ "/openvpn" ]

COPY restart.py /restart.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
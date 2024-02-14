#!/bin/bash

HOST_HOSTNAME=$(hostname)
ENV_FILE=".env"

if grep -qE '^BASE_HOSTNAME=' "$ENV_FILE"; then
  sed -i.bak "s|^BASE_HOSTNAME=.*$|BASE_HOSTNAME=$HOST_HOSTNAME|" "$ENV_FILE"
  rm $ENV_FILE.bak
else
  echo "BASE_HOSTNAME=$HOST_HOSTNAME" >> "$ENV_FILE"
fi

# Now run your Docker Compose command
docker-compose down && docker-compose up -d --build
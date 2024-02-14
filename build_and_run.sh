#!/bin/bash

HOST_HOSTNAME=$(hostname)

if grep -qxF "BASE_HOSTNAME=$HOST_HOSTNAME" .env; then
  # If the line already exists, update the value
  sed -i '' "s|^BASE_HOSTNAME=.*|BASE_HOSTNAME=$HOST_HOSTNAME|" .env
else
  # If the line does not exist, add it
  echo "BASE_HOSTNAME=$HOST_HOSTNAME" >> .env
fi

# Now run your Docker Compose command
docker-compose down && docker-compose up -d --build
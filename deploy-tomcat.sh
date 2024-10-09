#!/bin/sh
# Bring down existing Docker Compose services
echo "Bringing down existing Docker Compose services..."
docker compose down
echo "Done."

# Bring up Docker Compose services
echo "Bringing up Docker Compose services..."
docker compose up -d
echo "Done."

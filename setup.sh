#!/bin/bash

# Function to create directory if it doesn't exist
create_directory() {
  if [ ! -d "$1" ]; then
    echo "Creating directory $1..."
    sudo mkdir -p "$1"
    echo "Directory $1 created."
  else
    echo "Directory $1 already exists."
  fi
}

# Check if Docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker not installed. Starting installation..."
  sudo apt-get update
  if ! sudo -n true 2>/dev/null; then
    echo "Setup cancelled."
    exit 1
  fi
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  echo "Docker installed."
  if ! [ $(getent group docker) ]; then
    sudo groupadd docker
  fi
  echo "Adding current user to docker group..."
  sudo usermod -aG docker $USER
  echo "Done."
  echo "Please restart your machine for the changes to take effect. After restart, run setup.sh again to continue the setup."
  exit 0
else
  sleep 0.2
  echo "$(docker --version) is installed."
fi


# Create bridge network
networks=("smb_net")
for network in "${networks[@]}"; do
  if [[ "$(docker network ls | grep "${network}")" == "" ]]; then
    echo "Creating network ${network}..."
    docker network create -d bridge $network > /dev/null
    sleep 0.2
    echo "Done."
  else
    sleep 0.2
    echo "Network ${network} already exists."
  fi
done


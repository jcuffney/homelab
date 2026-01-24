#!/bin/bash
set -e

# 1️⃣ Update OS
apt update && apt upgrade -y

# 2️⃣ Install NVIDIA drivers
# Adjust for your GPU
echo "Installing NVIDIA drivers..."
ubuntu-drivers autoinstall

# 3️⃣ Add NVIDIA Docker runtime
echo "Setting up NVIDIA Docker runtime..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
apt update
apt install -y nvidia-docker2
systemctl restart docker

# 4️⃣ Verify GPU is detected
echo "Verifying GPU detection..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi
    echo "✓ GPU detected successfully"
else
    echo "⚠ Warning: nvidia-smi not found. GPU drivers may need a reboot to be fully functional."
fi

# 5️⃣ Create persistent directories
echo "Creating persistent directories..."
mkdir -p /srv/plex/config
mkdir -p /srv/ollama/models
mkdir -p /srv/docker
chown -R root:root /srv
chown -R jcuffney:jcuffney /srv/plex /srv/ollama /srv/docker

# 6️⃣ Verify docker-compose.yml exists (copied by cloud-init)
if [ ! -f /srv/docker/docker-compose.yml ]; then
    echo "✗ Error: /srv/docker/docker-compose.yml not found!"
    echo "Cloud-init should have copied this file. Check cloud-init logs."
    exit 1
fi
echo "✓ Found docker-compose.yml at /srv/docker/docker-compose.yml"

# 7️⃣ Start containers
echo "Starting Docker containers..."
cd /srv/docker
docker-compose up -d

echo "✓ Bootstrap complete!"
echo "Containers should be running. Check with: docker ps"

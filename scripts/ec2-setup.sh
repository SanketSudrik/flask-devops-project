#!/bin/bash
# ============================================================
# EC2 Setup Script — Ubuntu 22.04
# Run once on a fresh EC2 instance to prepare the environment
# ============================================================

set -e

echo "==> [1/6] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "==> [2/6] Installing Docker..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release git

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> [3/6] Configuring Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
newgrp docker

echo "==> [4/6] Installing Docker Compose (standalone)..."
sudo curl -SL "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo "==> [5/6] Cloning project repository..."
# Replace with your actual GitHub repo URL
git clone https://github.com/YOUR_USERNAME/flask-devops-project.git ~/flask-devops-project

echo "==> [6/6] Starting the application..."
cd ~/flask-devops-project
docker-compose up -d

echo ""
echo "=============================="
echo " EC2 Setup Complete!"
echo " App running at: http://$(curl -s ifconfig.me)"
echo "=============================="

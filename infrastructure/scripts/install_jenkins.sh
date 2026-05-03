#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting Installation..."

set -e  # Exit on error

echo "------------------------------------------------"
echo "🚀 Starting Jenkins & Docker Installation..."
echo "------------------------------------------------"

# 1. Update System
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl gnupg software-properties-common apt-transport-https ca-certificates lsb-release

# 2. Install Java (Jenkins Requirement)
echo "☕ Installing OpenJDK 21..."
sudo apt-get install -y openjdk-21-jdk

# 3. Install Jenkins
echo "🏗️ Installing Jenkins..."

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install -y jenkins

# 4. Install Docker
echo "🐳 Installing Docker Engine..."
# Add Docker GPG Key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker Repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Post-Installation: Configuration & Permissions
echo "⚙️ Configuring Permissions..."

# Enable services to start on boot
sudo systemctl enable docker
sudo systemctl enable jenkins

# Start Docker first so the group is active
sudo systemctl start docker

# Add Jenkins and standard Ubuntu user to Docker group
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

sudo systemctl restart jenkins

echo "------------------------------------------------"
echo "⏳ Waiting for Jenkins to generate initial password..."

while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
  sleep 2
done

echo "✅ Installation Complete!"
echo "Jenkins is running on port 8080"
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "------------------------------------------------"

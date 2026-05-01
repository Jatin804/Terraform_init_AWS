#!/bin/bash
# Description: Automated Installation of Jenkins and Docker
# Target OS: Ubuntu 24.04 / 26.04
# Date: April 2026

set -e  # Exit on error

echo "------------------------------------------------"
echo "🚀 Starting Jenkins & Docker Installation..."
echo "------------------------------------------------"

# 1. Update System
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release

# 2. Install Java (Jenkins Requirement)
echo "☕ Installing OpenJDK 21..."
sudo apt install -y openjdk-21-jdk

# 3. Install Jenkins
echo "🏗️ Installing Jenkins..."
# Add Jenkins GPG Key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins Repo
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

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

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Post-Installation: Configuration & Permissions
echo "⚙️ Configuring Permissions..."

# Enable services to start on boot
sudo systemctl enable jenkins
sudo systemctl enable docker

# Add Jenkins user to Docker group
# This allows Jenkins to run Docker commands without sudo
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER

# Start services
sudo systemctl start jenkins
sudo systemctl start docker

echo "------------------------------------------------"
echo "✅ Installation Complete!"
echo "Jenkins is running on: http://$(curl -s ifconfig.me):8080"
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "------------------------------------------------"
echo "NOTE: Please restart the server or re-login for group changes to take effect."

sudo chmod 666 /var/run/docker.sock
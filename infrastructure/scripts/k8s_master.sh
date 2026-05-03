#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting Installation..."

set -e # Exit on error

sudo apt-get update -y

# Updating /etc/hosts for connection
if ! grep -q "ANSIBLE MANAGED HOSTS" /etc/hosts; then
  echo -e "\n# BEGIN ANSIBLE MANAGED HOSTS\n$(hostname -I | awk '{print $1}') $(hostname).example.com $(hostname)\n# END ANSIBLE MANAGED HOSTS" | sudo tee -a /etc/hosts > /dev/null
fi

# Disabling swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Adding kernel modules 
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF

# Setting up sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Installing necessary dependencies (Removed firewalld)
sudo apt-get install -y curl gnupg software-properties-common ca-certificates lsb-release conntrack socat ipset

# Adding Docker and installing containerd
sudo mkdir -p /etc/apt/keyrings
sudo chmod 0755 /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod 0644 /etc/apt/keyrings/docker.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y containerd.io

# Generating clean containerd config
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Force restart containerd to apply CRI changes
sudo systemctl daemon-reload
sudo systemctl restart containerd
sudo systemctl enable containerd

# Kubernetes Setup 
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.asc

# Downloading K8s GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc > /dev/null
sudo chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.asc

# Adding Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# Installing K8s components
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

# Initializing kubernetes (Added ignore preflight for micro instances)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=NumCPU,Mem

# Configuring kubectl for the default 'ubuntu' user
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Also configuring for root
sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config

# Temporarily export kubeconfig for the root user to run Calico install
export KUBECONFIG=/etc/kubernetes/admin.conf

# Calico Setup
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

# Key for connection
echo ""
echo "========================================================================="
echo "Save the below join command to run on your worker nodes:"
echo "View this at any time by running: cat /var/log/cloud-init-output.log"
echo "========================================================================="
sudo kubeadm token create --print-join-command
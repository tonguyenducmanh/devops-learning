#!/bin/bash
# Install containerd

apt update && apt upgrade -y	
apt install containerd -y
mkdir -p  /etc/containerd/

containerd config default|sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

##########
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
#Dissable swapoff
sudo swapoff -a
sudo sed -i 's/\/swap/#\/swap/g' /etc/fstab
###########
sudo modprobe overlay
sudo modprobe br_netfilter
# Setup required sysctl params, these persist across reboots.

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# Apply sysctl params without reboot
sudo sysctl --system


# Cài d?t kubenertes:
apt-get install -y apt-transport-https ca-certificates curl gnupg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
apt install kubeadm=1.31.12-1.1 kubelet=1.31.12-1.1 kubectl=1.31.12-1.1 -y
sudo apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

mkdir /etc/systemd/system/kubelet.service.d
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/containerd.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--runtime-request-timeout=15m --image-service-endpoint=unix:///run/containerd/containerd.sock  --cgroup-driver=systemd"
EOF

echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml

cat <<EOF | sudo tee /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.4.1"
EOF

systemctl daemon-reload

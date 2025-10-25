Hello ae, chiều này chúng ta có buổi đào tạo về Docker/Container.
Để thuận tiện cho việc làm lab và để tránh mất thời gian setup thì nhờ ae cài sẵn docker và docker-compose trên VM app nhé (không cài trên VM mt và wk).
Tks ae !!!

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

sudo usermod -aG docker ubuntu


# add unzip file
sudo apt install unzip

custom lai UI cua NGinx trong docker image
(tao file index.html)

=> build image from docker

dung docker load de load image


=> run from docker compose

docker exec -t <ten-container> mongosh

=> go to var/lib/docker/volume for check

docker volumne ls

=> run k8s

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
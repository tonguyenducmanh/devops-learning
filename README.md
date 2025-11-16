tổng hợp các nội dung học devops, file README.md này sẽ tập trung vào các câu lệnh cô đọng nhất:

# Cài static ip cho máy ảo vmware ubuntu-server

## cài Vmware + cài ubuntu-server

Lấy link ubuntu server ở đây, tìm đúng bản ubuntu phù hợp với kiến trúc cần ảo hóa

```
https://ubuntu.com/download/server
```

Cài trên vmware, chọn mạng cấu hình mạng là bridge, sau đó làm từng bước theo hướng dẫn để cài ubuntu

login vào ubuntu

## chuyển config mạng ubuntu sang static ip

dùng command sau để kiểm tra xem ubuntu này có ip là gì

```
hostname -I
```

kiểm tra loại mạng bằng

```
ip a
```

chạy lệnh trong file disable_network.txt để tắt việc vmware cloud-init k ghi dè nữa

```
sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg <<EOF

network: {config: disabled}
EOF
```

sửa lại cấu hình mạng để có ip static

```
sudo vim /etc/netplan/00-installer-config.yaml
```

copy nội dung dưới vào file đang tạo

```
network:
  version: 2
  ethernets:
    enp2s0:    # đổi theo interface vừa tìm bằng lệnh ip a bên trên
      dhcp4: no
      addresses: [192.168.0.169/24] # thay bằng địa chỉ ip static muốn tạo
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

apply config mạng bằng lệnh dưới

```
sudo netplan apply
sudo systemctl restart systemd-networkd
```

## cài đặt docker

cách cài đặt docker tham khảo từ trang chủ sau:

https://docs.docker.com/engine/install/ubuntu/

login vào ubuntu bằng quyền root

```
sudo -i
```

cd vào thư mục user (vd là ubuntu)

```
cd /home/ubuntu/
```

tạo file cài đặt docker

```
vim install-docker.sh
```

paste nội dung sau vào file cài

```
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
```

cấp quyền cho file cài

```
chmod 777 install-docker.sh
```

chạy file vừa tạo để cài docker

```
./install-docker.sh
```

# Cài đặt containerd

```
#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

# 2. CÀI containerd
# Docs: https://github.com/containerd/containerd/blob/main/docs/getting-started.md
sudo apt install -y containerd


# 3. TẠO CONFIG FOLDER
# Docs: https://github.com/containerd/containerd/blob/main/docs/getting-started.md
sudo mkdir -p /etc/containerd


# 4. TẠO FILE CONFIG MẶC ĐỊNH
# containerd config default → lệnh chính thức
# Docs: https://github.com/containerd/containerd/blob/main/docs/getting-started.md
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null


# 5. BẬT SystemdCgroup CHO KUBERNETES
# Lý do: Kubernetes yêu cầu systemd cgroup driver
# Docs: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml


# 6. BẬT MODULE overlay & br_netfilter
# Required cho container networking
# Docs: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#loading-kernel-modules
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter


# 7. BẬT SYSCTL CHO KUBERNETES / NETWORK
# Docs: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#sysctl
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system


# 8. RESTART containerd + ENABLE
# Docs: https://www.freedesktop.org/software/systemd/man/systemctl.html
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "=== DONE! containerd đã được cài đầy đủ ==="
```

# Cài đặt k8s

Tham khảo tài liệu từ trang:

https://v1-33.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

```
sudo swapoff -a
sudo sed -i 's/\/swap/#\/swap/g' /etc/fstab
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

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

```

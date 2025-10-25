#!/bin/bash

# ================================================================

# 🐳 HƯỚNG DẪN CÀI ĐẶT DOCKER + CONTAINERD CHUẨN BỊ CHO K8S

# Môi trường: Ubuntu (trên VM app, KHÔNG cài trên VM mt hoặc wk)

# ================================================================

echo "=== CẬP NHẬT HỆ THỐNG & CÀI ĐẶT GPG KEY CỦA DOCKER ==="

# Cập nhật danh sách package

sudo apt-get update

# Cài đặt các công cụ cần thiết để lấy key và chứng chỉ HTTPS

sudo apt-get install -y ca-certificates curl

# Tạo thư mục chứa keyrings cho apt (nếu chưa có)

sudo install -m 0755 -d /etc/apt/keyrings

# Tải GPG key chính thức của Docker

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Cấp quyền đọc key cho tất cả người dùng

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "=== THÊM REPO DOCKER VÀO NGUỒN APT ==="

# Thêm repository chính thức của Docker vào danh sách nguồn

echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cập nhật danh sách gói sau khi thêm repo Docker

sudo apt-get update

echo "=== CÀI ĐẶT DOCKER VÀ CÁC THÀNH PHẦN LIÊN QUAN ==="

# Cài Docker Engine, CLI, containerd và plugin Compose

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Kiểm tra Docker hoạt động

sudo docker run hello-world

# Thêm user "ubuntu" vào group docker để không cần sudo khi chạy docker

sudo usermod -aG docker ubuntu

echo "=== CÀI ĐẶT THÊM CÔNG CỤ unzip ==="
sudo apt install -y unzip

# ---------------------------------------------------------------

# 🧩 TÙY CHỈNH GIAO DIỆN NGinx TRONG DOCKER IMAGE

# ---------------------------------------------------------------

# 1. Tạo file index.html tuỳ chỉnh (ví dụ: echo 'Hello Docker!' > index.html)

# 2. Build image mới từ Dockerfile có sẵn (docker build -t custom-nginx .)

# 3. Dùng `docker load` nếu bạn có file image .tar cần import (vd: docker load < myimage.tar)

# 4. Chạy image bằng docker-compose (docker compose up -d)

# 5. Truy cập container để quản lý database (vd: docker exec -it <tên-container> mongosh)

# 6. Kiểm tra volume đang tồn tại (docker volume ls)

# 7. Truy cập thư mục lưu trữ volume trên host (/var/lib/docker/volumes)

# ---------------------------------------------------------------

# ⚙️ CÀI ĐẶT CONTAINERD (BẮT BUỘC CHO KUBERNETES)

# ---------------------------------------------------------------

echo "=== CÀI ĐẶT CONTAINERD VÀ CẤU HÌNH CHO K8S ==="

# Cập nhật & nâng cấp hệ thống

sudo apt update && sudo apt upgrade -y

# Cài đặt containerd

sudo apt install -y containerd

# Tạo thư mục cấu hình containerd (nếu chưa có)

sudo mkdir -p /etc/containerd/

# Tạo file config mặc định cho containerd

containerd config default | sudo tee /etc/containerd/config.toml

# Sửa cấu hình: bật SystemdCgroup để tương thích với Kubernetes

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

echo "=== NẠP CÁC MODULE CẦN THIẾT CHO NETWORKING ==="

# Ghi các module cần load khi khởi động

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Tắt swap để K8s hoạt động ổn định

sudo swapoff -a
sudo sed -i 's/\/swap/#\/swap/g' /etc/fstab

# Kích hoạt các module ngay lập tức

sudo modprobe overlay
sudo modprobe br_netfilter

echo "=== CẤU HÌNH THÔNG SỐ HỆ THỐNG CHO K8S ==="

# Ghi các tham số sysctl để kernel cho phép forwarding và xử lý network bridge

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Áp dụng các thay đổi sysctl ngay mà không cần reboot

sudo sysctl --system

echo "✅ HOÀN TẤT CÀI ĐẶT DOCKER + CONTAINERD CHO K8S"
echo "=> Khởi động lại máy (sudo reboot) nếu cần để hoàn tất."

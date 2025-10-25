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

# nén 2 folder adv-demo và nginx-demo vào thành file docker.zip

# copy vào trong ubuntu ở folder /home/ubuntu/code/docker.zip

# giải nén bằng lệnh sau

cd /home/ubuntu/code/

unzip docker.zip

# xóa file zip đã giải nén

rm docker.zip

# ---------------------------------------------------------------

# 🧩 TÙY CHỈNH GIAO DIỆN NGinx TRONG DOCKER IMAGE

cd vào thư mục nginx-demo

# ---------------------------------------------------------------

# 1. Tạo file index.html tuỳ chỉnh (ví dụ: echo 'Hello Docker!' > index.html)

# 2. Build image mới từ Dockerfile có sẵn (docker build -t custom-nginx .)

(đảm bảo khi chạy lệnh sau phải đứng ở thư mục có Dockerfile)

docker build -t custom-nginx .

# dùng lệnh sau để run

docker run -d --name test-nginx -p 8080:80 custom-nginx

# dùng lệnh sau để check xem có chưa

docker ps

# check cả container đã dừng

docker ps -a

# dừng container

docker stop <tên hoặc id container>

# xóa container

docker rm <tên hoặc id container>

# xóa image

docker rmi <tên image>

# 3. Dùng `docker load` nếu bạn có file image .tar cần import (vd: docker load < myimage.tar)

# chuyển sang adv-demo

cd vào thư mục adv-demo

đọc nội dung trong file readme.txt

# 4. Chạy image bằng docker-compose (docker compose up -d)

# 5. Truy cập container để quản lý database (vd: docker exec -it <tên-container> mongosh)

# 6. Kiểm tra volume đang tồn tại (docker volume ls)

# 7. Truy cập thư mục lưu trữ volume trên host (/var/lib/docker/volumes)

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

# Cài đặt kubenertes trước:

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
Environment="KUBELET_EXTRA_ARGS=--runtime-request-timeout=15m --image-service-endpoint=unix:///run/containerd/containerd.sock --cgroup-driver=systemd"
EOF

echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml

cat <<EOF | sudo tee /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.4.1"
EOF

systemctl daemon-reload

kubeadm init

# Hướng dẫn trong buổi học

copy folder k8s_lab ve may

copy folder k8s_lab vao 2 may ubuntu ipmaster va ipworker

run tung file trong folder k8s_lab (6buoc)

Nội dung buôi lab:

Triển khai K8S

B1: Cấu hình firewall

B2: Cấu hình file system

sudo vim /etc/sysctl.conf (qua vim)

sudo sysctl -p (apply config)

B3: Chạy Script install package của k8s

B4: Cài đặt Helm (chi chay tren ipmaster)

shutdown ubuntu và khởi chạy lại (thì bước 5 mới không báo lỗi)

B5: Tạo file khởi tạo cụm (chi chay tren ipmaster)

cd /home/ubuntu/

vim init-config.yaml

copy nội dung file init-fonfig.yaml vào, sửa lại ip của ubuntu master đang dùng

sau đó chạy

kubeadm init --config init-config.yaml

kiểm tra bằng command

sudo crictl ps

kubectl get pods -A
kubectl get nodes

Lưu ý, việc các node từ not ready sang ready cần thời gian vài phút

nếu như chạy lệnh recommend để kết nối từ máy ubuntu worker vào máy ubuntu master không được,

vui lòng kiểm tra xem tường lửa có chặn port k8s đang kết nối không

trường hợp máy worker và máy master trùng tên, chạy lệnh sau để đổi host name ở máy worker

sudo hostnamectl set-hostname worker1
exec bash

sau đó chạy lại lệnh join có cấu trúc như sau

sudo kubeadm reset -f
sudo systemctl restart containerd

sudo kubeadm join 192.168.0.100:6443 --token ... \
 --discovery-token-ca-cert-hash sha256:....

B6: Dowwnload và install CNI vào cụm

tham khảo file download cni, lưu ý sửa lại cấu hình ip máy master

sau đó kiểm tra bằng kubectl get nodes => nếu có control plane và worker là oke

sau đó kiểm tra kubectl get pods -A, nếu có kube và cilium là oke

https://runbook.misa.vn/2024/06/11/sre-check-list-khi-cai-dat-docker-swarm/


sau này, nếu từng shutdown máy master và máy worker, nếu khởi động lại chạy kubectl get nodes thấy báo lỗi

kiểm tra xem đã có config chưa

ls ~/.kube/config

nếu không có, dùng lệnh sau để tạo lại

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

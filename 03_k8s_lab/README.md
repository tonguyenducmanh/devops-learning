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
B5: Tạo file khởi tạo cụm (chi chay tren ipmaster) => tao file config de o thu muc home (init-config.yaml)
sau do chay lenh de run file
sau do enter cac lenh duoc recommend cua k8s

=> check bang command sudo crictl ps
B6: Dowwnload và install CNI vào cụm

https://runbook.misa.vn/2024/06/11/sre-check-list-khi-cai-dat-docker-swarm/

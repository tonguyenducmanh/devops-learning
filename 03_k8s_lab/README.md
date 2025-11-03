# cấu hình netplan (quan trọng nhất nếu xài vmware)

kiểm tra loại mạng bằng

ip a (hoặc ip link)

vào file netplan.txt, sửa lại ip mong muốn, thay thế loại mạng vào nếu khác ( chỗ ens160)

sudo vim /etc/netplan/00-installer-config.yaml

copy nội dung netplan.txt vào đây

sau đó chạy

sudo netplan apply
sudo systemctl restart systemd-networkd

kiểm tra xem còn bao nhiêu ip đang hoạt động

hostname -I

thực hiện xóa ip cũ nếu vẫn còn ( chú ý interface enp2s0 phải thay đổi theo interface của máy)

sudo ip addr del 192.168.0.104/24 dev enp2s0

lưu ý: kể cả khi đã cài đặt thành công, lúc start máy vui lòng kiểm tra xem (lệnh ip a, hostname -I)

có các ip lạ nào khác sinh ra bởi vmware không, có thì bỏ đi cũng bằng lệnh trên

sau đó chạy 2 lệnh dưới để xóa pod đi cho init lại

kubectl -n cilium delete pod --all
kubectl -n kube-system delete pod --all

sau đó chạy 2 lệnh dưới kiểm tra trạng thái

kubectl get nodes
kubectl get pods -A

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

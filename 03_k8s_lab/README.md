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

# cấu hình netplan (quan trọng nhất nếu xài vmware)

kiểm tra loại mạng bằng

ip a (hoặc ip link)

vào file netplan.txt, sửa lại ip mong muốn, thay thế loại mạng vào nếu khác ( chỗ ens160)

```
sudo vim /etc/netplan/00-installer-config.yaml
```

copy nội dung netplan.txt vào đây

```
network:
  version: 2
  ethernets:
    enp2s0:    # đổi theo interface của bạn
      dhcp4: no
      addresses: [192.168.0.169/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

sau đó chạy

```
sudo netplan apply
sudo systemctl restart systemd-networkd
```

chạy lệnh trong file disable_network.txt để tắt việc vmware cloud-init k ghi dè nữa

```
sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg <<EOF

network: {config: disabled}
EOF
```

kiểm tra xem còn bao nhiêu ip đang hoạt động

hostname -I

thực hiện xóa ip cũ nếu vẫn còn ( chú ý interface enp2s0 phải thay đổi theo interface của máy)

sudo ip addr del 192.168.0.104/24 dev enp2s0

lưu ý: kể cả khi đã cài đặt thành công, lúc start máy vui lòng kiểm tra xem (lệnh ip a, hostname -I)

nếu đã cài thêm k8s và cilium thì chạy các lệnh sau

sau đó chạy 2 lệnh dưới để xóa pod đi cho init lại

kubectl -n cilium delete pod --all
kubectl -n kube-system delete pod --all

sau đó chạy 2 lệnh dưới kiểm tra trạng thái

kubectl get nodes
kubectl get pods -A

Khi restart vm, check lại nội dung file netplan xem có bị thay đổi không

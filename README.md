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

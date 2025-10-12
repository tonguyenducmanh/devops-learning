Yêu cầu:

Dựng 1 dịch vụ đơn giản: sử dụng python và redis (40 phút)
- Tạo 1 user theo dự án: voteapp
- Tạo 1 folder cho dự án:
- Cài đặt redis và kiểm nghiệm dịch vụ redis
+ sudo apt update -y && sudo apt upgrade -y
+ sudo apt install redis-server -y
+ sudo systemctl status redis
+ cat /etc/systemd/system/redis.service
+ bind 0.0.0.0 nếu cần
+ redis-cli ping
+ ss -tuln | grep 6379
+ journalctl -xeu 6379



- Dựng tiếp app python
+ 
mkdir source_code
cd source_code
git clone https://github.com/dockersamples/example-voting-app.git
cd ~/source_code/example-voting-app/vote
sudo apt update
sudo apt install -y python3.12 python3.12-venv python3.12-dev curl
python3.12 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# edit file app.py để sửa host redis thành 127.0.0.1 --> viết thành script cho nhanh/ vẫn hướng dẫn dùng vim
sed -i 's/redis_host = .*/redis_host = "127.0.0.1"/' app.py
./venv/bin/gunicorn app:app -b 0.0.0.0:8000 --workers 4
    + using systemd để quản lý app
sudo tee /etc/systemd/system/vote.service <<'EOF'
[Unit]
Description=Flask Voting App (Gunicorn)
After=network.target



[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/source_code/example-voting-app/vote
Environment="PATH=/home/ubuntu/source_code/example-voting-app/vote/venv/bin"
ExecStart=/home/ubuntu/source_code/example-voting-app/vote/venv/bin/gunicorn app:app -b 0.0.0.0:8000 --workers 4 --keep-alive 0



Restart=on-failure
RestartSec=5
KillSignal=SIGQUIT
TimeoutStopSec=10



[Install]
WantedBy=multi-user.target
EOF



sudo systemctl daemon-reload
sudo systemctl start vote
sudo systemctl enable vote
sudo systemctl status vote
    + Kiểm tra app
curl http://127.0.0.1:8000


Trong bài lab này mn sẽ sử dụng/đào tạo các kỹ năng sau:

Kỹ năng cần sử dụng trong buổi lab
Quản trị user/group cơ bản:
adduser/useradd, usermod, tạo user hệ thống, home, shell, group.
Phân quyền thư mục: chown, chmod, umask.
Làm việc với gói và môi trường:
apt update/upgrade/install, xác định package name đúng theo distro.
Python venv, pip, quản lý dependency, build-essential cho build wheel.
Hệ thống dịch vụ với systemd:
Viết unit file [Unit]/[Service]/[Install].
ExecStart, WorkingDirectory, Environment, Restart policy.
systemctl daemon-reload/start/enable/status, journalctl -xeu, log follow.
Đặt User/Group để tối thiểu quyền, tách biệt runtime.
Cấu hình và vận hành Redis:
Sửa redis.conf: bind, protected-mode.
Kiểm tra cổng với ss/netstat, ping với redis-cli.
Bảo mật cơ bản khi mở bind (firewall, protected-mode, ACL nếu nâng cao).
Debug Network/Process:
ss -tuln, curl, kiểm tra port conflict, log service.
Xử lý lỗi typical: permission, PATH venv, sai WorkingDirectory, thiếu package dev.
Git và quản lý source:
git clone repo, bố trí thư mục dự án theo user.
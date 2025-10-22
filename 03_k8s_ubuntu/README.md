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
B5: Tạo file khởi tạo cụm (chi chay tren ipmaster) => tao file config de o thu muc home (init-config.yaml)
sau do chay lenh de run file
sau do enter cac lenh duoc recommend cua k8s
=> check bang command sudo crictl ps
B6: Dowwnload và install CNI vào cụm

https://runbook.misa.vn/2024/06/11/sre-check-list-khi-cai-dat-docker-swarm/

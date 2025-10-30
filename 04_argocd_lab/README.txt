copy thư mục argocd-application vào trong ubuntu master

cd vào thư mục argocd-application

tạo 1 namespace mới để deploy argocd vào

kubectl create namespace argocd

để kiểm tra namespace thì dùng câu lệnh

kubectl get ns

deploy ứng dụng lên k8s bằng helm

helm install argocd -f values-test.yaml . -n argocd

kiểm tra xem dựng xong chưa

kubectl get pod -n argocd

double check lại xem ở ubuntu worker đã lên được cilium chưa

kubectl get nodes

kubectl get pod -A

nếu chưa cần sửa lại cấu hình yaml giống bên master

vim /etc/containerd/config.yaml

thêm cái đoạn

```
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."172.16.204.150"]
          endpoint = ["http://172.16.204.150"]
```

sau đó chạy đoạn sau restart containerd

service containerd restart

service kubelet restart

kiểm tra argocd đang chạy ở pod nào

kubectl get svc -n argocd

tìm dòng argocd-argocd-application-server tìm port của nó để chạy vào

nhập vào trình duyệt địa chỉ ví dụ

10.100.19.74:32039

user là admin, pass là 12345678@Abc

vào setting, vào project, tạo project mới

tên project để theo tên project tfs

xuống phần source repository

nếu để * sẽ mapping tất cả repository

tiếp theo là destination

namespace sẽ mapping với namespace ở k8s

ví dụ kubectl create namespace sre-test

thì namespace để là sre-test sẽ mapping với sre-test, nếu để là "sre*" sẽ mapping hết tất cả sre

tiếp theo vào repository để cấu hình repo, tương ứng với helm chart ở trên habo

ấn vào connect repo

phần choose your connection method chọn https

phần connect repo using https chọn helm

name để là sre

project chọn project vừa tạo

url repo để tới đường dẫn helm repo trên habo

tìm đường dẫn bằng command helm repo ls

sau đó ấn connect

phần connection status successful là oke
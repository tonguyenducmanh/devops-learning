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

nếu chưa cần sửa lại cấu hình toml giống bên master

vim /etc/containerd/config.toml

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

tiếp theo kéo xuống phần cluster resource allow list edit chọn *

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

tạo app bằng argocd

vào application ấn new app

đặt tên, chọn project

kéo xuống dưới chọn repo url

chọn chart, chọn version (chọn chart nào nhẹ nhẹ thôi)

phần destination chọn cluster url

phần helm chọn values file

sau đó bấm create

vào app vừa tạo

bấm vào sync

bấm vào synchronize

nếu có lỗi không có quyền deploy lên namespace thì quay lại bước project sre

kiểm tra xem đã có cấu hình namespace ở phần destination chưa

khi synchronize lại tích prune + force (có thể tích cả prune last)

sau đó quay lại kube kiểm tra pod

kubectl get pod -n tên namespace

kubectl get svc -n tên namespace

tìm cái nodeport xem ports là bao nhiêu

ví dụ là 32098

nhập vào địa chỉ ip ubuntu + :32098 (vd 10.10.132.14:32098)


sau đó tìm cách vào được cái kubeneties dashboard bằng bearer token

nhập lệnh 

kubectl get secret -n tên namespace

copy name

tạo token bằng

kubectl describle secret tên user -n tên namespace
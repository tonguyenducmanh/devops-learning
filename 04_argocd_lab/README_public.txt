tạo namespace mới

kubectl create namespace argocd

thêm helm repo argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

cài đặt với cấu hình mặc định

helm install argocd argo/argo-cd -n argocd

kiểm tra trạng thái pod

kubectl get pods -n argocd

Port-forward server

kubectl port-forward svc/argocd-server -n argocd 8080:443

Sau đó truy cập trên máy local: https://localhost:8080

Lấy mật khẩu admin

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo

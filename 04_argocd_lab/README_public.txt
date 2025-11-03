tạo namespace mới

kubectl create namespace argocd

thêm helm repo argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

cài đặt với cấu hình mặc định

helm install argocd argo/argo-cd -n argocd

kiểm tra trạng thái pod

kubectl get pods -n argocd

dùng lệnh dưới để mở port truy cập được từ máy ngoài

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'}'


sau đó chạy lệnh dưới để xem port của argocd-server (NodePort)

kubectl get svc -n argocd

sau đó, ngoài trình duyệt truy cập theo ip ubuntu + port ví dụ

192.168.0.169:31767

Lấy mật khẩu admin

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo

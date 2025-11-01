Trong file này có file install_k8s_stack.sh, có chú thích rõ ràng từng bước

Chạy trên ubuntu để tự động hóa quy trình cài đặt

sao chép nội dung vào file

```
nano install_k8s_stack.sh
```

cấp quyền chạy

```
chmod +x install_k8s_stack.sh
```

chạy script

```
sudo ./install_k8s_stack.sh
```

kiểm tra node

```
kubectl get nodes
```

kiểm tra các pod hệ thống

```
kubectl get pods -A
```

kiểm tra port argoCD

```
kubectl get svc -n argocd
```

→ Dùng IP master + NodePort để mở UI ArgoCD

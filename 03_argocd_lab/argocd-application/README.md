# Hướng dân cài đặt dịch vụ ArgoCD

- Đảm bảo cài đặt helm và có repo helm của sre
- install command: helm install argocd . -f values.yaml -n argocd 

## Hướng dẫn khác

HƯỚNG DẪN CÀI ĐẶT 

1. Lấy password default cho tài khoản admin bằng lệnh: 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


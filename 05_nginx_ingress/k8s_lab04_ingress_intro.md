# 💡 Điều hướng traffic với Nginx Ingress

Khi bạn chạy các ứng dụng (services) bên trong Kubernetes (K8s), chúng được bảo vệ rất kỹ. **Nginx Ingress** chính là giải pháp giúp mở cửa một cách có tổ chức, cho phép người dùng bên ngoài (Client) truy cập vào các dịch vụ đó.

---

# 🗺️ Mô Hình Điều Hướng Tổng Thể

Hãy hình dung quá trình truy cập như một hành trình từ Client đến ứng dụng của bạn:

1. Client (Trình duyệt) 🌐: Yêu cầu truy cập (ví dụ: gõ demoapp.misa.vn).

2. DNS: Dịch tên miền thành IP của K8s Node (và kèm theo số NodePort).

3. K8s Node/NodePort 🚪: Traffic đến một cổng cố định trên Node (ví dụ: 31228).

4. Nginx Ingress Controller 💂: Là một Pod chạy trong K8s, nhận traffic từ NodePort.

5. Luật Routing (VirtualServer) 🚦: Nginx Ingress kiểm tra tên miền và đường dẫn (path) trong yêu cầu.

6. Service/Deployment 🚀: Nginx Ingress chuyển yêu cầu đến đúng Service/Deployment đích bên trong cluster.

---

# 🔑 Các Khái Niệm Chính

Để thực hiện việc điều hướng này, Nginx Ingress sử dụng ba đối tượng K8s tùy chỉnh (Custom Resources) quan trọng:

## 1. Nginx Ingress Controller

Đây là ứng dụng thực tế (Pod) chạy Nginx.

- Nó hoạt động như người gác cổng chính, lắng nghe NodePort và liên tục theo dõi các cấu hình routing mới trong cluster.

- Nó được cấu hình với đối tượng Service kiểu NodePort để có thể truy cập được từ bên ngoài K8s Cluster.

  - NodePort: Là một cổng cố định (ví dụ: 31228) trên tất cả các máy chủ K8s Node. Bất kỳ traffic nào đến cổng này sẽ được chuyển hướng thẳng tới Nginx Ingress Controller.

## 2. VirtualServer (Tấm biển chỉ đường)

- Đây là đối tượng chính để khai báo các quy tắc routing.
- Nó chỉ định:
  - Tên miền (Host): Yêu cầu này dành cho ai? (ví dụ: demoapp.misa.vn).
  - Upstreams: Danh sách các dịch vụ (Services) đích mà Ingress sẽ gửi traffic tới.

## 3. VirtualServerRoute (Chỉ dẫn chi tiết)

- Đây là phần chi tiết hóa đường đi bên trong một VirtualServer.
- Nó chỉ định:
  - Path: Yêu cầu đến đường dẫn nào? (ví dụ: / cho trang chủ, hoặc /api/).
  - Action (Proxy): Traffic sẽ được chuyển hướng tới Upstream nào.

# 📝 Tóm Lược Về Quy Trình

1. Bạn cài đặt Nginx Ingress Controller và mở cổng NodePort (ví dụ: 31228).
2. Bạn tạo đối tượng VirtualServer khai báo rằng tất cả traffic đến demoapp.misa.vn phải được xử lý bởi Controller này.
3. Bạn tạo VirtualServerRoute chỉ định: "Nếu đường dẫn là /, hãy chuyển nó tới mcp-debezium-tool-svc (đã khai báo trong Upstream)."
4. Khi Client truy cập demoapp.misa.vn:31228, Nginx Ingress Controller đọc các quy tắc này và chuyển yêu cầu tới ứng dụng đích.

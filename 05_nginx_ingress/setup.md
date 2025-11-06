Chào mừng các bạn quay trở lại!

Buổi trước, chúng ta đã cùng nhau đưa thành công các dịch vụ lên Kubernetes bằng **ArgoCD**. Hiện tại, các ứng dụng đó đang chạy ổn định bên trong cluster.

Vậy câu hỏi tiếp theo là: **Làm thế nào để người dùng bên ngoài có thể truy cập vào chúng một cách an toàn và có tổ chức?**

Đây chính là lúc **Nginx Ingress**, 'người gác cổng' của cluster, phát huy tác dụng. Trong buổi hôm nay, chúng ta sẽ thực hành triển khai và cấu hình Ingress Controller, tích hợp nó vào luồng **GitOps với ArgoCD** để quản lý việc điều hướng traffic một cách **an toàn và tự động**.

Giờ hãy cùng bắt đầu nhé!

---

# Workshop: Cấu Hình Điều Hướng Dịch Vụ với Nginx Ingress

## 1. Tài nguyên hiện có

Để bắt đầu, chúng ta cần đảm bảo môi trường đã có sẵn các thành phần từ buổi workshop trước:

- **K8s Cluster:**

  - Namespace: `sre`
  - Helm Repo: `sre`
  - Deployment: `argocd` đã được cài đặt và hoạt động.

- **ArgoCD:**
  - Repo: `sre`
  - Project: `sre`
  - Applications: Đang quản lý `k8s-dashboard` và `goldpinger`.

---

## 2. Mục tiêu bài thực hành

- **Triển khai** ứng dụng **Nginx Ingress Controller** thông qua ArgoCD.
- **Cấu hình điều hướng (Routing)** cho các kịch bản thực tế.

---

## 3. Các bước thực hiện chi tiết

**(Tất cả các lệnh `helm` và `kubectl` sẽ được thực hiện trên K8s Master Node)**

### 3.0. Tài nguyên cho bài lab

- File share: `\\10.100.17.107\Share\lab04\charts`
- Copy các chart có trong thư mục `charts` lên máy k8s master `/home/ubuntu/lab04/`

### 3.1. Kết nối helm repo `k8s-lab`

```bash
# Thêm repo mới chứa chart tùy chỉnh
helm repo add k8s-lab http://172.16.204.150/chartrepo/k8s-lab --username robot@k8s-lab --password '12345678@Abc'
helm repo update
```

### 3.2. Cài đặt plugin helm `cm-push`

```bash
helm plugin install https://github.com/chartmuseum/helm-push
```

### 3.3. Đẩy Chart nginx-ingress lên helm repo

```bash
cd /home/ubuntu/lab04/
CP -r demo-app-nginx-ingress nvson-demo-app-nginx-ingress
cd nvson-demo-app-nginx-ingress
nano Chart.yaml
# sửa name: nvson-demo-app-nginx-ingress

# kiểm tra helm hợp lệ
helm template .

# đóng gói helm
helm package .

# đẩy helm lên repo
helm cm-push nvson-demo-app-nginx-ingress-0.0.4.tgz k8s-lab
```

Truy cập harbo để kểm tra chart đã được đẩy lên repo: `http://172.16.204.150/harbor/projects/187/helm-charts`

### 3.4. Tạo Namespace cho dự án

```bash
kubectl create ns demoapp
```

### 3.5. Tùy chỉnh chart nginx-ingress

Mở file `values.yaml` của chart và tùy chỉnh các tham số sau:

```yaml
# values.yaml
controller:
  # image nginx
  image:
    repository: 172.16.204.150/library/nginx/nginx-ingress
    tag: "2.3.0"
  ingressClass: demoapp-nginx-ingress
  # thiết lập limit cpu/ram cho dịch vụ
  resources:
    requests:
      cpu: 16m
      memory: 64Mi
    limits:
      cpu: 512m
      memory: 2Gi
  # cấu hình dịch vụ
  service:
    type: NodePort # cho phép bên ngoài truy cập được
    externalTrafficPolicy: Cluster # phân phối tải đồng đều giữa tất cả các Pod Nginx
    httpPort:
      # Port cố định để truy cập từ bên ngoài, để trống nếu chưa xác định được port.
      nodePort: "31228"
    httpsPort:
      enable: false # tắt port https
```

### 3.6. Cấu hình ArgoCD

- **Kết nối ArgoCD tới helm repo `k8s-lab`**:

  - Truy cập giao diện ArgoCD: http://10.100.19.9:32039
  - Vào Settings > Repositories > Connect repo using HTTPS.
  - Điền thông tin:
    - Type: helm
    - Project: sre
    - Repository URL: http://172.16.204.150/chartrepo/k8s-lab
    - Username: robot@k8s-lab
    - Password: 12345678@Abc

- **Tạo Application nginx-ingress trên ArgoCD**:

  - Application Name: demoapp-nginx-ingress
  - Project: sre
  - Sync Policy: Automatic
  - Repository URL: Chọn repo k8s-lab đã thêm.
  - Chart: nvson-demo-app-nginx-ingress
  - Destination Namespace: demoapp

- **Kiểm tra kết quả**:
  Trên máy windows, sửa file `C:\Windows\System32\drivers\etc\hosts` với quyền Admin.
  _ `{ip_k8s_master} demoapp.misa.vn`
  _ VD: `10.100.19.9 demoapp.misa.vn` \* Truy cập url: `http://demoapp.misa.vn:31228/healthz/`, ra kết quả `app healthy` là đạt.

### 4. Cấu hình điều hướng (Routing)

Sử dụng tài nguyên **VirtualServer** để định nghĩa các quy tắc routing.

```yaml
# virtual-server.yaml
virtualServers:
  app1:
    host: demoapp.misa.vn
    upstreams:
    routes:
      # Route cho health check
      - path: /healthz/
        action:
          return:
            code: 200
            type: text/plain
            body: "app healthy"
```

#### 4.1. Điều hướng đến dịch vụ cùng Namespace (Dùng VirtualServer)

Chúng ta sẽ điều hướng traffic từ `demoapp.misa.vn/debezium-ui` tới ứng dụng `debezium-ui` chạy trong namespace `demoapp`.

#### 4.1.0. Triển khai ứng dụng debezium-ui

- helm repo: k8s-lab
- chart: debezium-ui
- namespace: demoapp

#### 4.1.1. Cấu hình Upstream và Route

Bạn cần cập nhật file cấu hình `values.yaml` để khai báo dịch vụ đích (`debezium-ui`) là một **Upstream** và định nghĩa một \*_Route_ mới.

**Bước 1: Cập nhật `values.yaml`**

Thêm `debezium-ui-upstream` vào danh sách upstreams và thêm một route mới cho đường dẫn `/debezium-ui/`.

```yaml
# values.yaml
virtualServers:
  app1:
    host: demoapp.misa.vn
    upstreams:
      - name: mcp-debezium-ui-upstream
        service: mcp-debezium-ui-svc
        port: 8080
    routes:
      - path: /healthz/
        action:
          return:
            code: 200
            type: text/plain
            body: "app healthy"
      - path: /debezium-ui/
        action:
          proxy:
            upstream: mcp-debezium-ui-upstream
            rewritePath: /
```

**Bước 2: Cập nhật đẩy helm lên harbo**:

```bash
helm package .
helm cm-push {chart_name}-{version}.tgz k8s-lab
```

#### 4.2. Điều hướng đến dịch vụ khác Namespace (Dùng VirtualServerRoute)

Đây là kịch bản thực tế nhất: Ingress Controller chạy trong `demoapp` nhưng Service đích (`debezium-tool`) chạy trong `sre`. Chúng ta sẽ sử dụng tài nguyên VirtualServerRoute (VSR) để vượt qua rào cản Namespace.

#### **4.2.1. Triển khai ứng dụng `debezium-tool`**

- helm repo: k8s-lab
- chart: debezium-tool
- namespace: sre

#### **4.2.2. Triển khai ứng dụng `debezium-nginx-ingress`**

- Tạo chart để triển khai `debezium-nginx-ingress`:

```bash
# Thực hiện trên máy k8s master
cd /home/ubuntu/lab04/
cp -r debezium-nginx-ingress nvson-debezium-nginx-ingress

# Cập nhật tên chart
nano values.yaml
# sửa name: nvson-debezium-nginx-ingress

# đóng gói helm
helm package .

# đẩy helm lên repo
helm cm-push {chart_name}-{version}.tgz k8s-lab

```

- Một số cấu hình thay đổi trong `values.yaml`:

Chỉ tạo VirtualServerRoute

```yaml
controller:
  kind: deployment_off # không triển khai pod nginx
  service:
    create: false # không tạo service

virtualServerRoutes:
  debezium:
    host: demoapp.misa.vn
    ingressClass: demoapp-nginx-ingress # cùng với ingressClass ở chart demoapp-nginx-ingress
    upstreams:
      - name: mcp-debezium-tool-upstream
        service: mcp-debezium-tool-svc
        port: 80
        client-max-body-size: 30m
    routes:
      - path: /debezium-tool/
        action:
          proxy:
            upstream: mcp-debezium-tool-upstream
            rewritePath: /
      - path: /debezium-tool/healthz/
        action:
          return:
            code: 200
            type: text/plain
            body: debezium healthy
```

- Tạo ứng dụng trên argocd:

  - helm repo: k8s-lab
  - chart: nvson-debezium-nginx-ingress
  - namespace: sre

- Kiểm tra kết quả:
  - Mở VSR `debezium-vsr`, xem tab Events, thấy message `Configuration for sre/debezium-vsr was added or updated`
  - Truy cập url: `http://demoapp.misa.vn:31228/debezium-tool/`

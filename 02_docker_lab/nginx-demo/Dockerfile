# Sử dụng image Nginx chính thức từ Docker Hub
FROM nginx:latest

RUN rm /etc/nginx/conf.d/default.conf
# Sao chép file cấu hình Nginx của bạn vào container
COPY default.conf /etc/nginx/conf.d/default.conf

# Sao chép nội dung trang web (HTML) vào thư mục phục vụ của Nginx
COPY index.html /usr/share/nginx/html

# Mở cổng 80 để cho phép truy cập từ bên ngoài
EXPOSE 80

# Lệnh để khởi chạy Nginx khi container bắt đầu
CMD ["nginx", "-g", "daemon off;"]

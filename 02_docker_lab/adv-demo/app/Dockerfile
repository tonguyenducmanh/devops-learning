# 1. Chọn một image Node.js làm nền tảng
# Sử dụng phiên bản Alpine để image nhẹ hơn
FROM node:18-alpine

# 2. Tạo thư mục làm việc bên trong container
WORKDIR /usr/src/app

# 3. Sao chép file package.json và package-lock.json
# Dấu * để khớp với cả hai file
COPY package*.json ./

# 4. Cài đặt các dependencies của ứng dụng
RUN npm install

# 5. Sao chép toàn bộ mã nguồn của ứng dụng vào thư mục làm việc
COPY . .

# 6. Mở cổng 3000 để bên ngoài có thể truy cập vào ứng dụng
EXPOSE 3000

# 7. Lệnh để chạy ứng dụng khi container khởi động
CMD [ "node", "server.js" ]

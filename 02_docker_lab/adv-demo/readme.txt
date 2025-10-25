#Kiem tra data MongoDB
- docker exec -it <ten-conainer> mongosh
- show dbs //list danh sach db trong mongo
- use webapp //su dung bang webapp
- show collections //hien thi collections
- db.visitors.find() //xem tat ca data trong collection

#Kiem tra volume docker
- docker volume ls //Hien thi danh sach volume
- cd /var/lib/docker/volumes/<ten-volume>/_data //duong dan data duoc luu

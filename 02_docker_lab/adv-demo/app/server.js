const express = require('express');
const mongoose = require('mongoose');

// Cấu hình ứng dụng
const PORT = 3000;
const HOST = '0.0.0.0';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/webapp';

const app = express();

// Kết nối tới MongoDB
mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

// Định nghĩa Schema và Model cho lượt truy cập
const visitorSchema = new mongoose.Schema({
    name: { type: String, default: 'visitor_counter' },
    count: { type: Number, default: 0 }
});
const Visitor = mongoose.model('Visitor', visitorSchema);

// Route chính
app.get('/', async (req, res) => {
    try {
        let visitor = await Visitor.findOne({ name: 'visitor_counter' });

        if (!visitor) {
            visitor = new Visitor();
        }

        visitor.count += 1;
        await visitor.save();

        res.send(`<h1>Chào mừng đến với Docker!</h1><p>Bạn là người truy cập thứ: ${visitor.count}</p>`);
    } catch (err) {
        res.status(500).send('Lỗi kết nối đến cơ sở dữ liệu.');
    }
});

app.listen(PORT, HOST, () => {
    console.log(`Ứng dụng đang chạy trên http://${HOST}:${PORT}`);
});

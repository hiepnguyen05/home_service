# Hướng Dẫn Deploy Backend Payment lên Render.com

## 1. Chuẩn bị
Đảm bảo bạn đã có tài khoản [Render.com](https://render.com).

## 2. Tạo Web Service mới
1. Đăng nhập Render Dashboard.
2. Chọn **New +** -> **Web Service**.
3. Kết nối với repository GitHub của bạn (`home_service`).
4. Chọn branch `dev` (hoặc `main` nếu bạn đã merge).
5. **Root Directory**: `backend_payment` (QUAN TRỌNG: vì code nằm trong thư mục này).

## 3. Cấu hình
Điền các thông tin sau:
- **Name**: `home-service-payment` (hoặc tên tùy ý)
- **Region**: Singapore (cho gần Việt Nam)
- **Runtime**: Node
- **Build Command**: `npm install`
- **Start Command**: `node src/index.js`

## 4. Environment Variables (Biến môi trường)
Bấm vào nút **Advanced** hoặc kéo xuống phần **Environment Variables** và thêm các biến sau (Lấy giá trị từ file `.env` và `serviceAccountKey.json` ở máy bạn):

| Key | Value (Cách lấy) |
| --- | --- |
| `NODE_ENV` | `production` |
| `PORT` | `3000` (hoặc để trống Render tự cấp) |
| `MOMO_PARTNER_CODE` | Lấy trong file `.env` |
| `MOMO_ACCESS_KEY` | Lấy trong file `.env` |
| `MOMO_SECRET_KEY` | Lấy trong file `.env` |
| `MOMO_ENDPOINT` | Lấy trong file `.env` (`https://test-payment.momo.vn/v2/gateway/api/create`) |
| `IPN_URL` | `https://<TEN-APP-CUA-BAN>.onrender.com/api/payment/callback` |
| `REDIRECT_URL` | `homeservice://payment-callback` (Deep link về app) |
| `SERVICE_ACCOUNT_KEY` | **QUAN TRỌNG**: Mở file `backend_payment/serviceAccountKey.json`, copy **toàn bộ nội dung** và dán vào đây. |

## 5. Hoàn tất
Bấm **Create Web Service**. Chờ khoảng 1-2 phút để Render build và deploy.

Khi deploy thành công, bạn sẽ thấy trạng thái **Live** và URL của Service (ví dụ: `https://home-service-payment.onrender.com`).
Dùng URL này để cập nhật lại trong code Mobile (file `payment_api_service.dart` hoặc `.env` của Mobile).

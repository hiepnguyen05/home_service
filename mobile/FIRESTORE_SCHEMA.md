# Thiết kế Firestore Schema (Cập nhật)

Dưới đây là cấu trúc chi tiết cho 2 collection `categories` và `services`, sử dụng mô hình tham chiếu (Services trỏ về Category).

## 1. Collection: `categories`
Dùng để hiển thị các mục trên màn hình Trang chủ (Home Screen) để người dùng lọc dịch vụ.

| Field | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `id` | String | Document ID (Key định danh) | `cleaning` |
| `name` | String | Tên hiển thị danh mục | "Dọn dẹp" |
| `iconName` | String | Tên icon (Material Icon) | "cleaning_services" |
| `order` | Number | Thứ tự hiển thị | 1 |
| `isActive` | Boolean | Trạng thái bật/tắt | `true` |

---

## 2. Collection: `services`
Lưu trữ thông tin chi tiết các loại dịch vụ. **Liên kết với bảng `categories` thông qua trường `categoryId`.**

### Fields chính (Document Root)
| Field | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `id` | String | Document ID | `hourly_cleaning` |
| `categoryId` | String | **Reference ID** (Trỏ về categories) | `cleaning` |
| `name` | String | Tên dịch vụ | "Dọn dẹp nhà theo giờ" |
| `description` | String | Mô tả ngắn (hiển thị ở list) | "Vệ sinh phòng khách, ngủ..." |
| `imageUrl` | String | URL ảnh bìa (hiển thị trang chi tiết) | "https://firebasestorage..." |
| `iconName` | String | Tên icon (hiển thị ở list) | "cleaning_services" |
| `rating` | Number | Điểm đánh giá trung bình | 4.8 |
| `reviewCount` | Number | Tổng số lượt đánh giá | 1200 |
| `minPrice` | Number | Giá khởi điểm (để hiển thị "Từ...") | 250000 |
| `isActive` | Boolean | Trạng thái hiển thị | `true` |

### 2.1 Sub-collection: `services/{serviceId}/packages`
Các gói giá cho dịch vụ này.

| Field | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `name` | String | Tên gói | "Gói Cơ bản" |
| `description` | String | Mô tả gói | "Lau sàn, hút bụi..." |
| `price` | Number | Giá tiền | 250000 |
| `duration` | Number | Thời gian ước tính (phút) | 60 |
| `order` | Number | Thứ tự hiển thị gói | 1 |

### 2.2 Sub-collection: `services/{serviceId}/faqs`
Câu hỏi thường gặp.

| Field | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `question` | String | Câu hỏi | "Có cần chuẩn bị..." |
| `answer` | String | Câu trả lời | "Không cần..." |
| `order` | Number | Thứ tự | 1 |

---

## 3. Các Collection khác (Như cũ)
- **`technicians`**: Danh sách thợ, có field `serviceIds: ['hourly_cleaning', ...]`
- **`bookings`**: Đơn đặt hàng.
- **`users`**: Người dùng.

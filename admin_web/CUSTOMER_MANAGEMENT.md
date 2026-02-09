# Trang Quản Lý Khách Hàng - Hướng Dẫn Sử Dụng

## 🎯 Tổng Quan

Trang quản lý khách hàng đã được cập nhật để lấy dữ liệu thực từ Firebase Firestore, hiển thị tất cả người dùng có `role = "customer"`.

## 📋 Các Tính Năng

### ✅ Đã Hoàn Thành

1. **Hiển thị danh sách khách hàng**
   - Lấy dữ liệu từ Firebase collection `users` với `role = "customer"`
   - Hiển thị avatar hoặc initials nếu không có avatar
   - Hiển thị thông tin: Tên, Email, Số điện thoại, Số đơn hàng, Trạng thái

2. **Tìm kiếm**
   - Tìm kiếm theo tên khách hàng
   - Tìm kiếm theo email
   - Tìm kiếm theo số điện thoại

3. **Lọc dữ liệu**
   - Lọc theo trạng thái: Tất cả / Đang hoạt động / Ngừng hoạt động / Đang chờ
   - Lọc theo khu vực (UI sẵn sàng, cần thêm field `region` vào database)

4. **Phân trang**
   - Hiển thị 10 khách hàng mỗi trang
   - Điều hướng trang với nút Previous/Next
   - Hiển thị số trang động

5. **Thao tác**
   - Xem chi tiết (UI sẵn sàng)
   - Sửa thông tin (UI sẵn sàng)
   - Xóa khách hàng (soft delete - set `isActive = false`)

6. **Đếm số đơn hàng**
   - Tự động đếm số document trong collection `bookings` có `customerId` khớp

## 🔧 Cấu Trúc Dữ Liệu Firebase

### Collection: `users`

```javascript
{
  // Document ID (auto-generated)
  id: "abc123xyz",
  
  // Thông tin cơ bản
  name: "Nguyễn Văn An",           // hoặc displayName
  email: "an.nguyen@email.com",
  phoneNumber: "0901234567",        // hoặc phone
  
  // Phân quyền
  role: "customer",                 // QUAN TRỌNG: Phải là "customer"
  
  // Trạng thái
  isActive: true,                   // false = Ngừng hoạt động
  isVerified: true,                 // false = Đang chờ xác thực
  
  // Avatar
  avatarUrl: "https://...",         // hoặc photoURL
  
  // Timestamps
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Collection: `bookings`

```javascript
{
  customerId: "abc123xyz",  // Trỏ đến user.id
  // ... các field khác của booking
}
```

## 🎨 Trạng Thái Hiển Thị

| Điều kiện | Trạng thái | Màu sắc |
|-----------|-----------|---------|
| `isActive === false` | Ngừng hoạt động | Xám |
| `isVerified === false` | Đang chờ | Vàng |
| Còn lại | Đang hoạt động | Xanh |

## 🚀 Cách Sử Dụng

### 1. Chạy ứng dụng

```bash
cd admin_web
npm install
npm run dev
```

### 2. Truy cập trang

Mở trình duyệt tại: `http://localhost:5173/customers`

### 3. Test Firebase Connection

Uncomment các dòng sau trong `src/App.jsx`:

```javascript
import { testFirebaseConnection } from './utils/testFirebase';
testFirebaseConnection();
```

Sau đó mở Console trong DevTools để xem kết quả test.

## 📝 Files Đã Tạo/Cập Nhật

1. **`src/services/customerService.js`** - Service để tương tác với Firebase
   - `getAllCustomers()` - Lấy tất cả khách hàng
   - `getCustomerById()` - Lấy thông tin 1 khách hàng
   - `updateCustomer()` - Cập nhật thông tin
   - `deleteCustomer()` - Xóa khách hàng (soft delete)
   - `searchCustomers()` - Tìm kiếm khách hàng

2. **`src/pages/Customers/CustomerManager.jsx`** - Component chính
   - Hiển thị danh sách khách hàng
   - Tìm kiếm và lọc
   - Phân trang
   - Xử lý các thao tác

3. **`src/utils/testFirebase.js`** - Utility để test Firebase
   - Test kết nối
   - Kiểm tra dữ liệu
   - Hiển thị thông tin debug

## 🐛 Xử Lý Lỗi

### Không có khách hàng nào hiển thị?

1. Kiểm tra Firebase config trong `src/firebase/config.js`
2. Đảm bảo có users với `role: "customer"` trong Firestore
3. Chạy test Firebase để debug: uncomment code trong `App.jsx`

### Lỗi kết nối Firebase?

1. Kiểm tra internet connection
2. Kiểm tra Firebase credentials
3. Kiểm tra Firestore rules (phải cho phép read)

### Số đơn hàng không chính xác?

1. Kiểm tra collection `bookings` có tồn tại không
2. Kiểm tra field `customerId` trong bookings có khớp với user.id không

## 🔜 Tính Năng Sắp Tới

- [ ] Modal xem chi tiết khách hàng
- [ ] Modal sửa thông tin khách hàng
- [ ] Modal thêm khách hàng mới
- [ ] Export danh sách khách hàng (CSV/Excel)
- [ ] Lọc theo khu vực (cần thêm field `region` vào database)
- [ ] Lọc theo ngày đăng ký
- [ ] Thống kê chi tiết về khách hàng

## 📞 Hỗ Trợ

Nếu gặp vấn đề, hãy:
1. Kiểm tra Console trong DevTools
2. Chạy test Firebase
3. Kiểm tra cấu trúc dữ liệu trong Firestore Console

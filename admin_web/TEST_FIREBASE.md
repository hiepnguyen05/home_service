# Hướng dẫn Test Firebase Connection

## Cấu trúc dữ liệu Users trong Firebase

Trang quản lý khách hàng sẽ lấy dữ liệu từ collection `users` với điều kiện `role === 'customer'`.

### Cấu trúc document trong collection `users`:

```javascript
{
  id: "auto-generated-id",
  name: "Tên khách hàng",
  email: "email@example.com",
  phoneNumber: "0901234567",
  role: "customer",  // QUAN TRỌNG: Phải là "customer"
  isActive: true,    // true = active, false = inactive
  isVerified: true,  // false = pending, true = active
  avatarUrl: "https://...",  // hoặc photoURL
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

## Các trường hợp hiển thị trạng thái:

1. **Đang hoạt động** (màu xanh): `isActive !== false && isVerified !== false`
2. **Ngừng hoạt động** (màu xám): `isActive === false`
3. **Đang chờ** (màu vàng): `isVerified === false`

## Số đơn hàng:

Hệ thống sẽ tự động đếm số document trong collection `bookings` có `customerId` trùng với `id` của khách hàng.

## Chức năng đã implement:

- ✅ Lấy danh sách khách hàng từ Firebase
- ✅ Tìm kiếm theo tên, email, số điện thoại
- ✅ Lọc theo trạng thái (active/inactive/pending)
- ✅ Phân trang (10 khách hàng/trang)
- ✅ Đếm số đơn hàng của mỗi khách hàng
- ✅ Xóa khách hàng (soft delete - set isActive = false)
- ✅ Hiển thị avatar hoặc initials
- ✅ Loading state và error handling

## Để test:

1. Đảm bảo Firebase đã được cấu hình đúng trong `src/firebase/config.js`
2. Tạo một số document test trong collection `users` với `role: "customer"`
3. Chạy ứng dụng: `npm run dev`
4. Truy cập: http://localhost:5173/customers

## Lưu ý:

- Nếu không có khách hàng nào, trang sẽ hiển thị "Chưa có khách hàng nào trong hệ thống"
- Nếu có lỗi kết nối Firebase, sẽ hiển thị thông báo lỗi với nút "Thử lại"
- Pagination sẽ tự động điều chỉnh theo số lượng khách hàng thực tế

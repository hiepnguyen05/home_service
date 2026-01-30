# 📱 Home Service Mobile App

Ứng dụng di động dành cho dịch vụ gia đình, kết nối Khách hàng có nhu cầu với Thợ (Đối tác) cung cấp dịch vụ. Ứng dụng được xây dựng bằng **Flutter** và sử dụng **Firebase** làm backend.

---

## 🔥 Tính năng Chính

### 👤 Dành cho Khách hàng (Customer)

1.  **Xác thực (Auth)**
    *   Đăng ký / Đăng nhập / Quên mật khẩu.
    *   Quản lý hồ sơ cá nhân, ảnh đại diện.
    *   Quản lý danh sách địa chỉ.
2.  **Dịch vụ (Services)**
    *   Xem danh sách các dịch vụ (Sửa điện, Điện lạnh, Dọn dẹp...).
    *   Tìm kiếm và lọc dịch vụ.
    *   Xem chi tiết, giá cả và đánh giá dịch vụ.
3.  **Đặt lịch (Booking)**
    *   Tìm thợ gần nhất dựa trên vị trí.
    *   Đặt lịch hẹn (chọn dịch vụ, ngày giờ, địa chỉ).
    *   Theo dõi trạng thái đơn hàng (Đợi xác nhận, Đang đến, Đang làm, Hoàn thành).
4.  **Tương tác**
    *   Chat trực tiếp với thợ.
    *   Đánh giá và bình luận sau khi hoàn thành.
    *   Thanh toán qua ví hoặc tiền mặt.

### 🔧 Dành cho Thợ (Provider)

1.  **Đăng ký Đối tác**
    *   Nộp hồ sơ xét duyệt (KYC, Chứng chỉ nghề).
    *   Thiết lập bảng giá dịch vụ.
2.  **Quản lý Công việc**
    *   **Dashboard**: Thống kê thu nhập, công việc hôm nay.
    *   **Việc mới**: Nhận thông báo đơn hàng mới, Chấp nhận/Từ chối.
    *   **Lịch làm việc**: Quản lý lịch hẹn sắp tới.
3.  **Thực hiện đơn hàng**
    *   Cập nhật trạng thái (Đang đến, Đang làm, Hoàn thành).
    *   Liên hệ khách hàng.
4.  **Thu nhập**
    *   Xem báo cáo thu nhập.
    *   Yêu cầu rút tiền.

---

## 🛠 Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Provider
*   **Backend**: Firebase (Auth, Firestore, Storage)
*   **Maps**: Google Maps Flutter / Mapbox (Dự kiến)
*   **Architecture**: MVVM (Model - View - ViewModel)
*   **Structure**: Feature-first (theo tính năng)

---

## 📂 Cấu trúc Dự án

Dự án được tổ chức theo cấu trúc **Feature-first**:

```
lib/
├── core/                   # Các thành phần dùng chung (constants, utils, widgets)
├── features/               # Các module tính năng
│   ├── auth/               # Đăng nhập, Đăng ký
│   ├── profile/            # Hồ sơ người dùng
│   ├── address/            # Quản lý địa chỉ
│   ├── services/           # Danh sách dịch vụ
│   ├── booking/            # Đặt lịch (Đang phát triển)
│   ├── partner/            # Đăng ký đối tác
│   ├── provider/           # Giao diện dành cho Thợ
│   └── ...
├── routes/                 # Định nghĩa luồng điều hướng (AppRouter)
└── main.dart               # Entry point
```

---

## 🚀 Hướng dẫn Cài đặt

### Yêu cầu
*   Flutter SDK (mới nhất)
*   Android Studio / VS Code
*   Thiết bị giả lập hoặc máy thật (Android/iOS)

### Chạy ứng dụng

1.  **Cài đặt dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```

---


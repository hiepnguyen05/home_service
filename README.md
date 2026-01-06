# Home Service Application

Ứng dụng dịch vụ gia đình với 3 thành phần chính: Backend API, Admin Web Interface và Mobile App.

## Tình trạng hiện tại
✅ **Backend**: Chạy thành công trên http://localhost:5000  
✅ **Admin Web**: Chạy thành công trên http://localhost:5173  
✅ **Mobile**: Build APK thành công, có thể chạy trên device/emulator

## Cách chạy nhanh

### Backend + Admin Web
```bash
start-all.bat
```

### Mobile App
```bash
start-mobile.bat
```

## Chạy từng phần riêng biệt

### Backend (Node.js)
```bash
cd back_end
node server.js
```

### Admin Web (React + Vite)
```bash
cd admin_web
npm run dev
```

### Mobile (Flutter)
```bash
cd mobile
flutter run              # Chạy trên device/emulator
flutter run -d chrome    # Chạy trên web browser
```

## Cấu hình đã sửa

### Database
- ✅ Sửa mật khẩu trong `ormconfig.json` khớp với `.env`
- ✅ Thêm tên database `home_service`
- ✅ Kết nối database thành công

### Flutter
- ✅ Thêm dependencies: `http_parser`, `permission_handler`
- ✅ Sửa import errors theo cấu trúc MVVM
- ✅ Tách `AuthResponse` và `ProfileResponse` thành file riêng
- ✅ Build APK thành công

## Cấu trúc dự án

```
├── back_end/           # Node.js API Server
├── admin_web/          # React Admin Interface  
├── mobile/             # Flutter Mobile App
├── start-all.bat       # Script chạy Backend + Web
└── start-mobile.bat    # Script build Mobile App
```

## Ports
- Backend: 5000
- Admin Web: 5173
- Mobile: Tùy thiết bị

## Lưu ý
- Mobile APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`
- Để chạy mobile trên web: `flutter run -d chrome`
- Backend cần MySQL đang chạy với database `home_service`
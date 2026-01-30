/// Cấu hình Cloudinary - Cập nhật thông tin của bạn ở đây
class CloudinaryConfig {
  // TODO: Cập nhật Cloud name từ Cloudinary Dashboard
  // Truy cập: https://cloudinary.com/console
  // Copy "Cloud name" từ phần Account Details

  /// Cloud name từ Cloudinary Dashboard
  /// VÍ DỤ: Thay 'your-cloud-name' bằng cloud name thực của bạn
  /// Ví dụ: 'dxyz123abc' hoặc 'my-company-name'
  static const String cloudName = 'dvy0jonby';

  /// Upload preset name (đã cấu hình: home_service)
  static const String uploadPreset = 'home_service';

  /// Kiểm tra xem đã cấu hình chưa
  static bool get isConfigured {
    return cloudName != 'your-cloud-name' &&
        cloudName.isNotEmpty &&
        uploadPreset.isNotEmpty;
  }

  /// Thông báo hướng dẫn cấu hình
  static String get configurationMessage {
    if (!isConfigured) {
      return '''
🔧 CLOUDINARY CHƯA ĐƯỢC CẤU HÌNH!

Bước 1: Truy cập https://cloudinary.com/console
Bước 2: Đăng nhập vào tài khoản của bạn  
Bước 3: Copy "Cloud name" từ Dashboard
Bước 4: Mở file: lib/core/services/cloudinary_config.dart
Bước 5: Thay 'your-cloud-name' bằng Cloud name thực của bạn

Upload preset đã được cấu hình: home_service ✅
Chỉ cần Cloud name nữa thôi!

Ví dụ:
static const String cloudName = 'dxyz123abc'; // Thay bằng của bạn
''';
    }
    return ' Cloudinary đã được cấu hình thành công!\nCloud: $cloudName\nPreset: $uploadPreset';
  }

  /// Hướng dẫn nhanh cập nhật Cloud name
  static void printSetupInstructions() {
    print('');
    print('🔧 HƯỚNG DẪN CẬP NHẬT CLOUDINARY:');
    print('1. Mở file: lib/core/services/cloudinary_config.dart');
    print('2. Tìm dòng: static const String cloudName = \'your-cloud-name\';');
    print(
        '3. Thay \'your-cloud-name\' bằng Cloud name từ Cloudinary Dashboard');
    print('4. Lưu file và chạy lại app');
    print('');
    print('Cloud name có thể tìm tại: https://cloudinary.com/console');
    print('Upload preset đã OK: home_service ✅');
    print('');
  }
}

/// Các hàm kiểm tra tính hợp lệ của dữ liệu
class Validators {
  /// Kiểm tra email hợp lệ
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }

  /// Kiểm tra số điện thoại Việt Nam hợp lệ
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    
    // Loại bỏ tất cả ký tự không phải số
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Kiểm tra độ dài số điện thoại Việt Nam
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Số điện thoại không hợp lệ';
    }
    
    // Kiểm tra đầu số hợp lệ
    if (!cleanPhone.startsWith('0') && !cleanPhone.startsWith('84')) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }

  /// Kiểm tra mật khẩu hợp lệ
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    
    if (value.length < 8) {
      return 'Mật khẩu tối thiểu 8 ký tự';
    }
    
    return null;
  }

  /// Kiểm tra họ và tên hợp lệ
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Họ và tên không được để trống';
    }
    
    if (value.trim().length < 2) {
      return 'Họ và tên tối thiểu 2 ký tự';
    }
    
    return null;
  }

  /// Kiểm tra email hoặc số điện thoại hợp lệ
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email hoặc số điện thoại không được để trống';
    }
    
    // Kiểm tra xem có phải email không
    if (value.contains('@')) {
      return validateEmail(value);
    } else {
      return validatePhone(value);
    }
  }

  /// Kiểm tra trường bắt buộc
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
}
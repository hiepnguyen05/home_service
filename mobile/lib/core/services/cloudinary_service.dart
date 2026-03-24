import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../network/app_exceptions.dart';
import '../network/network_constants.dart';
import 'cloudinary_config.dart';

/// Service xử lý upload ảnh lên Cloudinary
class CloudinaryService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cloudinary configuration - Cập nhật trong cloudinary_config.dart
  static String get _cloudName => CloudinaryConfig.cloudName;
  static String get _uploadPreset => CloudinaryConfig.uploadPreset;
  
  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Helper kiểm tra định dạng ảnh
  static bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || 
           lower.endsWith('.jpeg') || 
           lower.endsWith('.png') || 
           lower.endsWith('.webp');
  }

  /// Nén ảnh để tối ưu tốc độ upload
  static Future<File> _compressImage(File file) async {
    try {
      if (!_isImageFile(file.path)) return file;
      
      final filePath = file.absolute.path;
      final outPath = "${filePath}_compressed.jpg";
      
      final result = await FlutterImageCompress.compressAndGetFile(
        filePath, 
        outPath,
        quality: 70, 
        minWidth: 1024, 
        minHeight: 1024,
      );
      
      return result == null ? file : File(result.path);
    } catch (e) {
      print('[CLOUDINARY] Compression failed: $e');
      return file; 
    }
  }

  /// Upload ảnh avatar lên Cloudinary
  static Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('Người dùng chưa đăng nhập');
      }

      print('[CLOUDINARY] Current user UID: ${user.uid}');
      print('[CLOUDINARY] User email: ${user.email}');

      // Kiểm tra file có tồn tại không
      if (!await imageFile.exists()) {
        throw const ValidationException('File ảnh không tồn tại');
      }

      // Kiểm tra kích thước file
      final fileSize = await imageFile.length();
      if (fileSize > NetworkConstants.maxImageSize) {
        throw const ValidationException('Kích thước ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 2MB.');
      }

      print('[CLOUDINARY] File size: $fileSize bytes');

      // Tạo tên file với timestamp để tránh trùng lặp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_${user.uid}_$timestamp';

      print('[CLOUDINARY] Bắt đầu upload ảnh: $fileName');

      // Nén ảnh để gia tăng tốc độ upload
      final compressedFile = await _compressImage(imageFile);

      // Upload ảnh lên Cloudinary
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          compressedFile.path,
          publicId: fileName,
          folder: 'avatars', // Tạo folder avatars trên Cloudinary
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final imageUrl = response.secureUrl;
      print('[CLOUDINARY] Upload avatar thành công: $imageUrl');
      
      return imageUrl;
      
    } on CloudinaryException catch (e) {
      print('[CLOUDINARY] Cloudinary Error: ${e.message}');
      throw _handleCloudinaryError(e);
    } catch (e) {
      print('[CLOUDINARY] General upload error: $e');
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException('Lỗi upload ảnh: $e');
    }
  }

  /// Upload file tổng quát lên Cloudinary
  static Future<String?> uploadFile({
    required File file,
    required String folder,
    String? fileName,
    CloudinaryResourceType resourceType = CloudinaryResourceType.Auto,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('Người dùng chưa đăng nhập');
      }

      // Kiểm tra kích thước file
      final fileSize = await file.length();
      if (fileSize > NetworkConstants.maxFileSize) {
        throw const ValidationException('File quá lớn. Vui lòng chọn file nhỏ hơn 5MB.');
      }

      // Tạo tên file nếu không có
      fileName ??= '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      print('[CLOUDINARY] Uploading file: $fileName to folder: $folder');

      // Tối ưu tốc độ: thử nén nếu đó là định dạng ảnh
      final compressedFile = await _compressImage(file);

      // Upload file lên Cloudinary
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          compressedFile.path,
          publicId: fileName,
          folder: folder,
          resourceType: resourceType,
        ),
      );

      final fileUrl = response.secureUrl;
      print('[CLOUDINARY] Upload file thành công: $fileUrl');
      
      return fileUrl;
      
    } on CloudinaryException catch (e) {
      print('[CLOUDINARY] Cloudinary Error: ${e.message}');
      throw _handleCloudinaryError(e);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException('Lỗi upload file: $e');
    }
  }

  /// Xóa ảnh từ Cloudinary (optional)
  static Future<void> deleteImage(String publicId) async {
    try {
      // Note: Xóa ảnh từ Cloudinary cần Admin API key
      // Với gói miễn phí, bạn có thể xóa thủ công từ dashboard
      print('[CLOUDINARY] Delete image: $publicId (manual deletion required)');
    } catch (e) {
      print('[CLOUDINARY] Không thể xóa ảnh: $e');
      // Không throw error vì việc xóa ảnh cũ không quan trọng
    }
  }

  /// Kiểm tra kết nối Cloudinary
  static Future<bool> checkCloudinaryConnection() async {
    try {
      print('[CLOUDINARY] Testing Cloudinary connection...');
      print('[CLOUDINARY] Cloud name: $_cloudName');
      print('[CLOUDINARY] Upload preset: $_uploadPreset');

      // Kiểm tra cấu hình cơ bản
      if (!CloudinaryConfig.isConfigured) {
        print('[CLOUDINARY] Error: ${CloudinaryConfig.configurationMessage}');
        return false;
      }

      print('[CLOUDINARY] Cloudinary configuration looks good');
      return true;
      
    } catch (e) {
      print('[CLOUDINARY] Connection test failed: $e');
      return false;
    }
  }

  /// Xử lý lỗi Cloudinary
  static AppException _handleCloudinaryError(CloudinaryException e) {
    final message = e.message?.toLowerCase() ?? '';
    
    if (message.contains('network') || message.contains('connection')) {
      return const NetworkException('Lỗi kết nối mạng. Vui lòng kiểm tra internet.');
    } else if (message.contains('unauthorized') || message.contains('invalid')) {
      return const UnauthorizedException('Lỗi xác thực Cloudinary. Kiểm tra cấu hình.');
    } else if (message.contains('file too large') || message.contains('size')) {
      return const ValidationException('File quá lớn. Vui lòng chọn file nhỏ hơn.');
    } else if (message.contains('format') || message.contains('type')) {
      return const ValidationException('Định dạng file không được hỗ trợ.');
    } else {
      return StorageException('Lỗi Cloudinary: ${e.message ?? 'Không xác định'}');
    }
  }

  /// Debug Cloudinary configuration
  static Future<void> debugCloudinaryConfiguration() async {
    print('[CLOUDINARY] === CLOUDINARY DEBUG INFO ===');
    
    try {
      // Kiểm tra Auth
      final user = _auth.currentUser;
      if (user != null) {
        print('[CLOUDINARY] User authenticated: ${user.email}');
        print('[CLOUDINARY] User UID: ${user.uid}');
      } else {
        print('[CLOUDINARY] No authenticated user');
      }
      
      // Kiểm tra Cloudinary config
      print('[CLOUDINARY] Cloud name: $_cloudName');
      print('[CLOUDINARY] Upload preset: $_uploadPreset');
      print('[CLOUDINARY] Configuration status: ${CloudinaryConfig.isConfigured}');
      
      if (!CloudinaryConfig.isConfigured) {
        print('[CLOUDINARY] ${CloudinaryConfig.configurationMessage}');
        CloudinaryConfig.printSetupInstructions();
      } else {
        print('[CLOUDINARY] ✅ Cấu hình hoàn tất! Sẵn sàng upload ảnh.');
      }
      
    } catch (e) {
      print('[CLOUDINARY] Debug failed: $e');
    }
    
    print('[CLOUDINARY] === END DEBUG INFO ===');
  }
}
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Helper class để quản lý file an toàn
/// Copy file từ cache sang app directory để tránh bị Android xóa
class FileHelper {
  static const String _partnerImagesFolder = 'partner_images';

  /// Copy file từ cache sang thư mục app an toàn
  /// Trả về File mới với đường dẫn an toàn
  static Future<File> copyToAppDirectory(File sourceFile, {String? subfolder}) async {
    try {
      // Kiểm tra file nguồn tồn tại
      if (!await sourceFile.exists()) {
        throw Exception('File nguồn không tồn tại: ${sourceFile.path}');
      }

      // Lấy thư mục app documents (không bị Android tự động xóa)
      final appDir = await getApplicationDocumentsDirectory();
      
      // Tạo thư mục con nếu cần
      final targetFolder = subfolder != null 
          ? '${appDir.path}/$_partnerImagesFolder/$subfolder'
          : '${appDir.path}/$_partnerImagesFolder';
      
      final targetDir = Directory(targetFolder);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Tạo tên file unique với timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = sourceFile.path.split('.').last;
      final newFileName = '${timestamp}_${sourceFile.path.split('/').last}';
      final targetPath = '$targetFolder/$newFileName';

      // Copy file
      final newFile = await sourceFile.copy(targetPath);
      debugPrint('[FileHelper] Copied file to: $targetPath');
      
      return newFile;
    } catch (e) {
      debugPrint('[FileHelper] Error copying file: $e');
      rethrow;
    }
  }

  /// Xóa file an toàn (không throw exception nếu file không tồn tại)
  static Future<void> deleteFile(File? file) async {
    if (file == null) return;
    
    try {
      if (await file.exists()) {
        await file.delete();
        debugPrint('[FileHelper] Deleted file: ${file.path}');
      }
    } catch (e) {
      debugPrint('[FileHelper] Error deleting file: $e');
      // Không throw exception, chỉ log
    }
  }

  /// Xóa nhiều file
  static Future<void> deleteFiles(List<File> files) async {
    for (final file in files) {
      await deleteFile(file);
    }
  }

  /// Xóa toàn bộ thư mục partner images
  static Future<void> clearPartnerImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final partnerDir = Directory('${appDir.path}/$_partnerImagesFolder');
      
      if (await partnerDir.exists()) {
        await partnerDir.delete(recursive: true);
        debugPrint('[FileHelper] Cleared partner images folder');
      }
    } catch (e) {
      debugPrint('[FileHelper] Error clearing partner images: $e');
    }
  }

  /// Kiểm tra file có tồn tại và có thể đọc được không
  static Future<bool> isFileValid(File? file) async {
    if (file == null) return false;
    
    try {
      if (!await file.exists()) return false;
      
      // Thử đọc length để đảm bảo file accessible
      await file.length();
      return true;
    } catch (e) {
      return false;
    }
  }
}

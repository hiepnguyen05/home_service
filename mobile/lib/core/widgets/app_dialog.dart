import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_button.dart';

/// Enum định nghĩa các loại dialog
enum DialogType { success, error, warning, info }

/// Widget Dialog chung cho ứng dụng
class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool barrierDismissible;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon theo loại dialog
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getIcon(),
                size: 30,
                color: _getIconColor(),
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Tiêu đề
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Nội dung
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Các nút
            Row(
              children: [
                // Nút phụ (nếu có)
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: AppButton(
                      text: secondaryButtonText!,
                      type: AppButtonType.outline,
                      onPressed: onSecondaryPressed ??
                          () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                ],

                // Nút chính
                Expanded(
                  child: AppButton(
                    text: primaryButtonText ?? 'OK',
                    type: AppButtonType.primary,
                    onPressed:
                        onPrimaryPressed ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy icon theo loại dialog
  IconData _getIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle;
      case DialogType.error:
        return Icons.error;
      case DialogType.warning:
        return Icons.warning;
      case DialogType.info:
        return Icons.info;
    }
  }

  /// Lấy màu icon theo loại dialog
  Color _getIconColor() {
    switch (type) {
      case DialogType.success:
        return AppColors.green;
      case DialogType.error:
        return AppColors.red;
      case DialogType.warning:
        return AppColors.orange;
      case DialogType.info:
        return AppColors.primary;
    }
  }

  /// Lấy màu nền icon theo loại dialog
  Color _getIconBackgroundColor() {
    switch (type) {
      case DialogType.success:
        return AppColors.greenLight;
      case DialogType.error:
        return AppColors.redLight;
      case DialogType.warning:
        return AppColors.orangeLight;
      case DialogType.info:
        return AppColors.primary.withOpacity(0.1);
    }
  }
}

/// Utility class để hiển thị các dialog
class DialogUtils {
  /// Hiển thị dialog thành công
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        type: DialogType.success,
        primaryButtonText: buttonText ?? 'Tuyệt vời',
        onPrimaryPressed: onPressed,
      ),
    );
  }

  /// Hiển thị dialog lỗi
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        type: DialogType.error,
        primaryButtonText: buttonText ?? 'Thử lại',
        onPrimaryPressed: onPressed,
      ),
    );
  }

  /// Hiển thị dialog cảnh báo
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        type: DialogType.warning,
        primaryButtonText: buttonText ?? 'Hiểu rồi',
        onPrimaryPressed: onPressed,
      ),
    );
  }

  /// Hiển thị dialog thông tin
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        type: DialogType.info,
        primaryButtonText: buttonText ?? 'OK',
        onPrimaryPressed: onPressed,
      ),
    );
  }

  /// Hiển thị dialog xác nhận với 2 nút
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        type: DialogType.warning,
        primaryButtonText: confirmText ?? 'Xác nhận',
        secondaryButtonText: cancelText ?? 'Hủy',
        onPrimaryPressed: () {
          Navigator.of(context).pop(true);
          onConfirm?.call();
        },
        onSecondaryPressed: () {
          Navigator.of(context).pop(false);
          onCancel?.call();
        },
      ),
    );
  }

  /// Hiển thị dialog loading
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // Đảm bảo hiển thị trên Root Navigator
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              Text(
                message ?? 'Đang xử lý...',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Đóng dialog loading
  static void hideLoading(BuildContext context) {
    // Đảm bảo pop từ Root Navigator (nơi showDialog mặc định hiển thị)
    Navigator.of(context, rootNavigator: true).pop();
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ProviderSaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const ProviderSaveButton({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Lưu thay đổi',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }
}

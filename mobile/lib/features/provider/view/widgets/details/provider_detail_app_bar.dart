import 'package:flutter/material.dart';

class ProviderDetailAppBar extends StatelessWidget {
  final bool isViewOnly;
  final bool isEditing;
  final VoidCallback onEditPressed;
  final VoidCallback onClosePressed;
  final VoidCallback onBackPressed;

  const ProviderDetailAppBar({
    super.key,
    this.isViewOnly = false,
    required this.isEditing,
    required this.onEditPressed,
    required this.onClosePressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBackPressed,
      ),
      title: const Text(
        'Chi tiết hồ sơ',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        if (!isViewOnly) ...[
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: onEditPressed,
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: onClosePressed,
            ),
        ],
      ],
    );
  }
}

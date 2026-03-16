import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class EvidenceUploadArea extends StatelessWidget {
  final File? image;
  final VoidCallback onPickImage;
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final bool isDashed;

  const EvidenceUploadArea({
    super.key,
    required this.image,
    required this.onPickImage,
    this.title = "Chụp ảnh",
    this.description = "Vui lòng chụp ảnh để xác nhận.",
    this.buttonText = "Chụp ảnh",
    this.icon = Icons.photo_camera,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDashed ? Colors.white : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isDashed 
            ? null 
            : Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
        ),
        child: Stack(
          children: [
            if (isDashed)
              Positioned.fill(
                child: CustomPaint(
                  painter: DashedBorderPainter(color: const Color(0xFFD1D5DB)),
                ),
              ),
            image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 48,
                          color: isDashed ? const Color(0xFF9CA3AF) : AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDashed 
                                ? AppColors.primary.withOpacity(0.2) 
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              color: isDashed ? AppColors.primary : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    this.color = const Color(0xFFD1D5DB),
    this.strokeWidth = 2,
    this.dashWidth = 8,
    this.dashSpace = 4,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    double distance = 0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class PromotionBanner extends StatelessWidget {
  const PromotionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAOjJmWBZzor05aCz2MaE1pCgOk0v7S2dCzcNLyAVvWzTS8rkJcDF0Ct2gzZUR2-4CYMA2bHVvUnU1KEOixQ9iSgcH2WG8U0sxBrjFMkZMyRzzem6YbnhBfuTApNl42pnJOsjj6XZUU3O8Pb4f8ppIn-Xjk64V8Z1KyyXyd5MLxl9m5_V9Y6yG2tK-j5D_T0OsJV0rrmEKfPgz3WediWV3SWaGOEqFgPjNqi7p8vV0tWQQ1UZ1S-WNrFSQHJu-5gBZen-zQNfhP_Jw',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giảm giá 50%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Dịch vụ dọn dẹp nhà cửa.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

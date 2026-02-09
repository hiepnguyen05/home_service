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
              'https://lh3.googleusercontent.com/gg-dl/AOI_d_9jjpzbNHcbLzDn4urCTiww2RQ6g9A_C_vd6SfYc_eLqJSAKlb7Wg-trqoAVuGUTYs8goZH5BkZrHZ18xLXOkXi48u4dZAbMi3ueG3YpOCAoQZCiu886emYj1ySsq-7hY_X06ErmH54dfjMy5yV0_e8ajKaJ2Zd0948YURIqSDrAO0cog=s1024-rj',
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

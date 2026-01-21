import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TechnicianSuggestion extends StatelessWidget {
  const TechnicianSuggestion({super.key});

  final List<Map<String, dynamic>> _technicians = const [
    {
      'name': 'Minh Anh',
      'avatar':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCMf-fr0UeJEa2rX5e3p_1t7tX9t6kDyKsybWupW8Di85OOHA9ABFACnnijbwEnSHLeaBrgNSVJdPIvEm1YO3D9xngqjKTnITFDjAsvMWHSjqmT2H-dmOIcNdIsMVedHQSHYVYpWBf5t-77aUkNXs5H2HpIZDMMgY_MO9k4Xz-wREK_R04koZYAUtnTgSuQLS_ZZsrIOyElCeEdpAX3XXNa_sSRMWgvVaV3qleXTEfp0OHL7XOX8zCn-vfW99d467GPQyqoj6M5zt8',
      'rating': 4.9,
      'distance': '1.2 km',
    },
    {
      'name': 'Hoàng Nam',
      'avatar':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCwp4ifGk-CNLeylOqV9B7643Hj63GM8Ik51fN1T6cNjTaIlrLiM_BWQcmGe-_oI99uLxpBmiZ2oLayLGjNjqSiGSOvKu0aY5hH4abVFtRG3kdJyuDshZvLci3NKmP3V9l_k9xPnI7m6mzOnzkWk6EGq0lO0Xg0xWDVDFWZA44H0UMIuzG0Q_YhkkvTo_2j6fiznaA-qqwsLgmR43WCfTag9_FTzgqznK_W-phd82sg9uuuYRzHc2DpktlypRm0fk27z7fQY5AvC20',
      'rating': 4.8,
      'distance': '2.5 km',
    },
    {
      'name': 'Thanh Huyền',
      'avatar':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAtZT9rTkZfd5mhdemFTKN8xgks8iJ8baXABSOEwwKjiX9Ywo_2e9MHjBk9IkN75rYm3lr1tk7gJ0027DFg9CMnL6V1nCpONBFushDZjJyLBYL8dhEP-GPlkRDvKzGA1CiJDu1tyESEfGrQlruKXZTP8jLUcmKtswxoRQiocJzb3jVXUAICUdcc8Q5coPtwfd8fSTk5Z_i5TrqBFXDypIsFCsPFVnlQFQW9dSBJB1q6xloJzPpE2QdROh8uKARr46D8jrTvaIVbSFk',
      'rating': 4.7,
      'distance': '3.1 km',
    },
    {
      'name': 'Quang Vinh',
      'avatar':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCusbBOqJ25QeRu03v-VDGGiNxGi2GnOEMGsgvWB2ET6jMHJ0nLYhF8SuslM8wSfpI65TPZ79d0Cz9q_iv6flKS1e0ZKX2x2nHUT7BR1epxF-84-hxFVlikaQLyLVaes16xXZyLjLPvLfz2sMaT6tVRf22st7efTphXmXwafBLKqEN8xGLNhj_-r6FLTcuWWanTzF73xKzkXBIQ8bG6bSD5NayHw7qmuElJFP3tZKKd751hdKdlukgxa_ixG6IYwEUrA6FTTM7d8aU',
      'rating': 5.0,
      'distance': '4.0 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Gợi ý chuyên gia gần bạn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _technicians.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tech = _technicians[index];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(tech['avatar']),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tech['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${tech['rating']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cách ${tech['distance']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

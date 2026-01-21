import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'Tôi có cần chuẩn bị dụng cụ gì không?',
      'answer':
          'Không, chuyên gia của chúng tôi sẽ mang đầy đủ các dụng cụ và chất tẩy rửa cần thiết. Nếu bạn có yêu cầu đặc biệt, vui lòng báo trước.',
    },
    {
      'question': 'Chính sách hủy lịch như thế nào?',
      'answer':
          'Bạn có thể hủy lịch miễn phí trước 24 giờ so với thời gian đã đặt. Nếu hủy trong vòng 24 giờ, một khoản phí nhỏ sẽ được áp dụng.',
    },
    {
      'question': 'Làm sao để thanh toán?',
      'answer':
          'Bạn có thể thanh toán qua thẻ tín dụng, ví điện tử hoặc tiền mặt trực tiếp cho chuyên gia sau khi dịch vụ hoàn thành.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giải đáp thắc mắc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final faq = _faqs[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq['answer']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  // 1. DỮ LIỆU CỐ ĐỊNH
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'Tôi có cần chuẩn bị dụng cụ gì không?',
      'answer':
          'Không, chuyên gia của chúng tôi sẽ mang đầy đủ dụng cụ cần thiết.',
    },
    {
      'question': 'Chính sách hủy lịch như thế nào?',
      'answer': 'Bạn có thể hủy miễn phí trước 24 giờ.',
    },
    {
      'question': 'Làm sao để thanh toán?',
      'answer': 'Hỗ trợ ví điện tử, thẻ tín dụng, hoặc tiền mặt.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. HEADER CỦA SECTION
          Row(
            children: [
              const Icon(Icons.help_outline,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Giải đáp thắc mắc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. DANH SÁCH CÂU HỎI
          // Dùng map để chuyển đổi từ dữ liệu (Map) thành Widget (FAQItem)
          ..._faqs.map((faq) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FAQItem(
                  question: faq['question']!,
                  answer: faq['answer']!,
                ),
              )),
        ],
      ),
    );
  }
}

// 4. WIDGET CON (Code của bạn, đổi tên FaqSection -> FAQItem)
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(),
          // Animation ẩn/hiện nội dung
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild:
                _buildContent(), // Tách content ra widget riêng cho gọn
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child:
                  const Icon(Icons.expand_more, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // Tách phần Content ra để code sạch hơn
  Widget _buildContent() {
    return Column(
      children: [
        Divider(height: 1, color: Colors.grey.shade100),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.answer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// Test main

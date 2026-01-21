import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/service_model.dart';

import '../widgets/technician_suggestion.dart';
import '../widgets/faq_section.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _quantity = 1;

  String _formatCurrency(double amount) {
    if (amount == 0) return 'Liên hệ';
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // background-light
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sticky Header
              SliverAppBar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Chi tiết dịch vụ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 100), // Space for sticky bottom
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Image
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[
                                200], // Background while loading or if no image
                            image: widget.service.imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image:
                                        NetworkImage(widget.service.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAdtYnNsFv6ThcUKEFIds9KQDNqH4Uqrt8OZZrMfC_MrWHzw_BX5HBwQ9VO3I7IY3XnIv7273ZdbL-H_NP8oAGZrHYtUS73tj-w4wGy5OYHB8xdIjbYxXo6Aba_Nmv8iuWlMeLjp7RO-sxIpHiRdh9stuXf25CX1ckxOQdCgnJBdICmN6QJ2QifWmR7VfUxr5SYYTT_wXpMgBWPSMkAEPSyDSGOdEmxWrWeM1TVIkrFRN8nFFTo_38Vs_omLsyy4u7NJVX8Oc5vN7U',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),

                      // Headline
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          widget.service.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // Rating
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(1.2k lượt đánh giá)',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      // Description
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.service.description.isNotEmpty
                              ? widget.service.description
                              : 'Dịch vụ dọn dẹp chuyên nghiệp, giúp không gian sống của bạn luôn sạch sẽ, gọn gàng và thoáng đãng. Đội ngũ nhân viên tận tâm, trang thiết bị hiện đại.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const Divider(
                          height: 1,
                          color: AppColors.borderLight,
                          thickness: 8),

                      // Pricing and Quantity
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chi tiết đặt lịch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.borderLight),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Price Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Đơn giá:',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 16),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${_formatCurrency(widget.service.suggestedPrice)} / ${widget.service.priceUnit}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          if (widget.service.minPrice > 0 ||
                                              widget.service.maxPrice > 0)
                                            Text(
                                              '(${_formatCurrency(widget.service.minPrice)} - ${_formatCurrency(widget.service.maxPrice)})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Divider(height: 1),
                                  const SizedBox(height: 20),

                                  // Quantity Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.service.priceUnit == 'giờ'
                                            ? 'Số giờ làm việc:'
                                            : 'Số lượng (${widget.service.priceUnit}):',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (_quantity > 1) {
                                                setState(() {
                                                  _quantity--;
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            color: _quantity > 1
                                                ? AppColors.textPrimary
                                                : Colors.grey,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            child: Text(
                                              '$_quantity',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _quantity++;
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                          height: 1,
                          color: AppColors.borderLight,
                          thickness: 8),

                      // Technician Suggestion
                      const TechnicianSuggestion(),

                      const Divider(
                          height: 1,
                          color: AppColors.borderLight,
                          thickness: 8),

                      // FAQs
                      const FAQSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle booking
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Đặt ngay - ${_formatCurrency(widget.service.suggestedPrice * _quantity)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

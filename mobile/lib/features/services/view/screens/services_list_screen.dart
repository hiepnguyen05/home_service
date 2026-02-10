import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/service_item_widget.dart';

import '../../viewmodel/services_viewmodel.dart';
import 'service_detail_screen.dart';

class ServicesListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ServicesListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Truy cập ViewModel
    final viewModel = context.watch<ServicesViewModel>();
    final allServices = viewModel.allServices;
    final isLoading = viewModel.isLoading;

    // Logic lọc: Danh mục + Tìm kiếm
    final filteredServices = allServices.where((service) {
      // 1. Lọc theo danh mục nếu có
      if (widget.categoryId != null &&
          service.categoryId != widget.categoryId) {
        return false;
      }
      // 2. Lọc theo từ khóa tìm kiếm
      if (_searchQuery.isNotEmpty) {
        final queryLower = _searchQuery.toLowerCase();
        return service.name.toLowerCase().contains(queryLower) ||
            service.description.toLowerCase().contains(queryLower);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền sáng
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? 'Danh sách dịch vụ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white, // Màu bề mặt
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.transparent),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm dịch vụ...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Danh sách dịch vụ
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredServices.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy dịch vụ nào',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          return ServiceItemWidget(
                            service: service,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServiceDetailScreen(service: service),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

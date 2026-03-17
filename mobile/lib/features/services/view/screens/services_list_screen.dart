import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/service_item_widget.dart';

import '../../viewmodel/services_viewmodel.dart';
import 'service_detail_screen.dart';

import 'package:mobile/features/partner/data/models/partner_request_model.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/booking/view/screens/booking_time_screen.dart';
import '../../../../core/utils/formatters.dart';

class ServicesListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final ProviderModel? provider; // NEW: If present, show provider specific services
  final List<PartnerServiceRequest>? providerServices; // NEW

  const ServicesListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.provider,
    this.providerServices,
  });

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (widget.provider != null) {
      return _buildProviderServices(context);
    }
    return _buildGlobalServices(context);
  }

  Widget _buildGlobalServices(BuildContext context) {
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
          _buildSearchField(),
          // Danh mục dịch vụ (Existing UI)
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

  Widget _buildProviderServices(BuildContext context) {
    final services = widget.providerServices?.where((s) => s.isActive).toList() ?? [];
    
    final filtered = services.where((s) {
      if (_searchQuery.isEmpty) return true;
      final queryLower = _searchQuery.toLowerCase();
      return s.serviceName.toLowerCase().contains(queryLower);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Dịch vụ của ${widget.provider!.name}',
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
          _buildSearchField(),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy dịch vụ nào',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final service = filtered[index];
                      final priceText = AppFormatters.formatCurrency(double.tryParse(service.price) ?? 0);
                      
                      return ServiceItemWidget(
                        // Adapt PartnerServiceRequest to ServiceItemWidget
                        title: service.serviceName,
                        subtitle: 'Giá từ: $priceText/${service.priceUnit}',
                        iconName: service.iconName ?? 'build',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingTimeScreen(
                                serviceId: service.serviceId,
                                preSelectedProvider: widget.provider,
                              ),
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
// Remove duplicate class _ServicesListScreenState below if any, or just end here.

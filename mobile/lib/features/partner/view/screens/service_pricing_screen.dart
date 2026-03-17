import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../viewmodel/partner_viewmodel.dart';
import '../../../services/data/models/service_model.dart';
import '../widgets/service_item_row.dart';
import '../widgets/partner_progress_bar.dart';
import 'package:mobile/features/partner/data/models/partner_request_model.dart';

class ServicePricingScreen extends StatefulWidget {
  final List<PartnerServiceRequest>? initialServices;
  final bool isUpdateMode;
  final Function(List<PartnerServiceRequest>)? onSave;
  final String? providerId;
  final String? providerName;
  final String? providerPhone;

  const ServicePricingScreen({
    super.key,
    this.initialServices,
    this.isUpdateMode = false,
    this.onSave,
    this.providerId,
    this.providerName,
    this.providerPhone,
  });

  @override
  State<ServicePricingScreen> createState() => _ServicePricingScreenState();
}

class _ServicePricingScreenState extends State<ServicePricingScreen> {
  String _searchQuery = '';

  /// Kiểm tra xem tất cả dịch vụ đã chọn có giá hợp lệ không
  bool _canProceed(PartnerViewModel viewModel) {
    if (viewModel.selectedServiceIds.isEmpty) return false;

    for (final serviceId in viewModel.selectedServiceIds) {
      final priceStr = viewModel.servicePrices[serviceId] ?? '';
      if (priceStr.isEmpty) return false;

      final price =
          double.tryParse(priceStr.replaceAll('.', '').replaceAll(',', ''));
      if (price == null || price <= 0) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Fetch services once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PartnerViewModel>(context, listen: false);
      viewModel.fetchActiveServices();
      if (widget.initialServices != null) {
        viewModel.initializePricing(widget.initialServices!);
      }
    });
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  void _showPricingSuggestionDialog(
      BuildContext context, ServiceModel service, PartnerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gợi ý giá cho ${service.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPricingRow('Giá sàn:', service.minPrice),
            const SizedBox(height: 8),
            _buildPricingRow('Giá trần:', service.maxPrice),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildPricingRow('Giá gợi ý:', service.suggestedPrice,
                isHighlight: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply suggested price
              viewModel.updateServicePrice(service.id,
                  _formatCurrency(service.suggestedPrice).replaceAll('.', ''));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Áp dụng giá gợi ý',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, double price,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color:
                isHighlight ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          '${_formatCurrency(price)} đ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerViewModel>(
      builder: (context, viewModel, child) {
        final filteredServices = viewModel.activeServices.where((s) {
          final matchesSearch =
              s.name.toLowerCase().contains(_searchQuery.toLowerCase());
          if (widget.isUpdateMode) return matchesSearch;
          return viewModel.selectedServiceIds.contains(s.id) && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.isUpdateMode
                  ? 'Cập nhật Dịch vụ & Giá'
                  : 'Thiết lập dịch vụ và giá',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  if (!widget.isUpdateMode)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      child: PartnerProgressBar(currentStep: 3),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bảng giá dịch vụ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isUpdateMode
                              ? 'Cập nhật dịch vụ bạn cung cấp và điều chỉnh giá tiền phù hợp với thị trường.'
                              : 'Cài đặt đơn giá cho các dịch vụ bạn đã chọn. Đơn giá này sẽ là căn cứ để khách hàng đặt lịch.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: widget.isUpdateMode
                              ? 'Tìm kiếm dịch vụ...'
                              : 'Tìm kiếm dịch vụ đã chọn...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${viewModel.selectedServiceIds.length} dịch vụ đã chọn',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: viewModel.isLoadingServices
                        ? const Center(child: CircularProgressIndicator())
                        : filteredServices.isEmpty
                            ? Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? (widget.isUpdateMode
                                          ? 'Không có dịch vụ nào khả dụng'
                                          : 'Bạn chưa chọn dịch vụ nào ở bước trước')
                                      : 'Không tìm thấy dịch vụ tương ứng',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                itemCount: filteredServices.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];
                                  return ServiceItemRow(
                                    service: service,
                                    isChecked: viewModel.selectedServiceIds.contains(service.id),
                                    price: viewModel.servicePrices[service.id] ?? '',
                                    onChecked: (val) => viewModel.toggleServiceSelection(service.id, val ?? false),
                                    onPriceChanged: (value) => viewModel
                                        .updateServicePrice(service.id, value.replaceAll('.', '').replaceAll(',', '')),
                                    priceUnit: service.priceUnit,
                                    onInfoTap: () =>
                                        _showPricingSuggestionDialog(
                                            context, service, viewModel),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              if (viewModel.isSubmitting)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed(viewModel) && !viewModel.isSubmitting
                    ? () async {
                        if (widget.isUpdateMode) {
                          final selectedServices =
                              viewModel.selectedServiceIds.map((id) {
                            final service = viewModel.activeServices
                                .firstWhere((s) => s.id == id);
                            return PartnerServiceRequest(
                              serviceId: id,
                              serviceName: service.name,
                              price: viewModel.servicePrices[id] ?? '0',
                              iconName: service.iconName,
                              priceUnit: service.priceUnit,
                            );
                          }).toList();

                          if (widget.providerId != null) {
                            final success = await viewModel.submitUpdate(
                              userId: widget.providerId!,
                              fullName: widget.providerName ?? 'Thợ',
                              phoneNumber: widget.providerPhone ?? '',
                              services: selectedServices,
                            );

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Yêu cầu cập nhật dịch vụ đã được gửi và đang chờ duyệt.')),
                              );
                              widget.onSave?.call(selectedServices);
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Lỗi: ${viewModel.errorMessage ?? "Không thể gửi yêu cầu"}')),
                              );
                            }
                          } else {
                            widget.onSave?.call(selectedServices);
                            Navigator.pop(context);
                          }
                        } else {
                          Navigator.pushNamed(context, AppRoutes.bioExperience);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed(viewModel)
                      ? AppColors.primary
                      : Colors.grey[300],
                  foregroundColor:
                      _canProceed(viewModel) ? Colors.white : Colors.grey[500],
                  elevation: _canProceed(viewModel) ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isUpdateMode ? 'Cập nhật ngay' : 'Tiếp tục',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

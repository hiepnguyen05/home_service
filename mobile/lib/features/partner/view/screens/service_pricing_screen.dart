import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../viewmodel/partner_viewmodel.dart';
import '../../../services/data/models/service_model.dart';
import '../widgets/service_item_row.dart';
import '../widgets/partner_progress_bar.dart';

class ServicePricingScreen extends StatefulWidget {
  const ServicePricingScreen({super.key});

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
      
      final price = double.tryParse(priceStr.replaceAll('.', '').replaceAll(',', ''));
      if (price == null || price <= 0) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Fetch services once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PartnerViewModel>(context, listen: false)
          .fetchActiveServices();
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

  List<ServiceModel> _getFilteredServices(List<ServiceModel> services) {
    if (_searchQuery.isEmpty) {
      return services;
    }
    return services
        .where((service) =>
            service.name.toLowerCase().contains(_searchQuery) ||
            service.description.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerViewModel>(
      builder: (context, viewModel, child) {
        final filteredServices = _getFilteredServices(viewModel.activeServices);

        // Listen for submission errors
        if (viewModel.errorMessage != null && !viewModel.isSubmitting) {
          // Use Future.microtask to avoid build-time setState or snackbar
          Future.microtask(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${viewModel.errorMessage}')),
            );
            // IMPORTANT: Ideally clear error after showing
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey[50], // background-light
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Thiết lập dịch vụ và giá',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Step 3 Progress Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: PartnerProgressBar(currentStep: 3),
              ),

              // Header Description
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Chọn dịch vụ bạn cung cấp và đặt giá mong muốn cho mỗi dịch vụ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm dịch vụ...',
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              // Main Content Area
              Expanded(
                child: viewModel.isLoadingServices
                    ? const Center(child: CircularProgressIndicator())
                    : filteredServices.isEmpty
                        ? const Center(
                            child: Text('Không tìm thấy dịch vụ phù hợp'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: filteredServices.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              final isChecked = viewModel.selectedServiceIds
                                  .contains(service.id);

                              // We use a controller that updates when model updates, carefully
                              // In a real optimized scenario, we might want individual items to be widgets
                              // that listen to specific parts or just rebuild.
                              // For now, rebuilding list is fine.

                              final currentPrice =
                                  viewModel.servicePrices[service.id] ?? '';

                              // Note: Recreating controller every build can be annoying for cursor position.
                              // A robust solution uses a separate widget for the input or keeps controllers in state.
                              // For simplicity here, we'll try to keep cursor at end if we use key or similar,
                              // OR just let the controller be created and hope Flutter diffing keeps focus if key is stable.
                              // Using unique key for TextField might help preserve focus but not cursor.
                              // Best simple way: Use a compiled formatting function in onChanged only, and here
                              // only set text if it differs significantly, OR use a custom StatefulWidget for the row.

                              return ServiceItemRow(
                                service: service,
                                isChecked: isChecked,
                                price: currentPrice,
                                onChecked: (val) =>
                                    viewModel.toggleServiceSelection(
                                        service.id, val ?? false),
                                onPriceChanged: (val) =>
                                    viewModel.updateServicePrice(
                                        service.id,
                                        val
                                            .replaceAll('.', '')
                                            .replaceAll(',', '')),
                                priceUnit: service.priceUnit,
                                onInfoTap: () => _showPricingSuggestionDialog(
                                    context, service, viewModel),
                              );
                            },
                          ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed(viewModel)
                    ? () {
                        Navigator.pushNamed(context, AppRoutes.bioExperience);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed(viewModel)
                      ? AppColors.primary
                      : Colors.grey[300],
                  foregroundColor: _canProceed(viewModel)
                      ? Colors.white
                      : Colors.grey[500],
                  elevation: _canProceed(viewModel) ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'dart:async';

import 'package:mobile/core/widgets/app_dialog.dart';

import 'package:mobile/features/address/viewmodel/address_viewmodel.dart';
import 'package:mobile/features/address/data/models/address_model.dart';
import 'package:mobile/core/services/location_service.dart';

import '../widgets/common/booking_stepper.dart';
import '../widgets/address/address_mini_map.dart';
import '../widgets/address/address_search_bar.dart';
import '../widgets/address/current_location_button.dart';
import '../widgets/address/saved_address_list.dart';
import 'booking_provider_screen.dart';

class BookingAddressScreen extends StatefulWidget {
  final String serviceId;
  final DateTime bookingTime; // NEW

  const BookingAddressScreen({
    super.key,
    required this.serviceId,
    required this.bookingTime, // NEW
  });

  @override
  State<BookingAddressScreen> createState() => _BookingAddressScreenState();
}

class _BookingAddressScreenState extends State<BookingAddressScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String? _selectedId;
  double? _displayLat;
  double? _displayLng;

  // Trạng thái để quản lý UI
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().loadAddresses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- XỬ LÝ LỖI (HIỆN DIALOG) ---
  void _showErrorDialog() {
    DialogUtils.showError(
      context,
      title: "Không tìm thấy vị trí",
      message:
          "Rất tiếc, chúng tôi không thể tìm thấy địa chỉ này trên bản đồ. Vui lòng kiểm tra lại hoặc chọn vị trí gần đúng.",
      buttonText: "Đã hiểu",
    );
  }

  // --- TÌM KIẾM ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (!_isSearching) setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 1500), () async {
      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          _displayLat = null;
          _displayLng = null;
        });
        return;
      }

      final result = await LocationService.getCoordinatesFromAddress(query);

      if (mounted) {
        setState(() {
          _isSearching = false;
          if (result != null) {
            _displayLat = result['latitude'];
            _displayLng = result['longitude'];
            _selectedId = null;
          } else {
            // Không tìm thấy -> Hiện Dialog
            _displayLat = null;
            _displayLng = null;
            _showErrorDialog();
          }
        });
      }
    });
  }

  // --- LẤY VỊ TRÍ HIỆN TẠI (GPS) ---
  Future<void> _getCurrentLocation() async {
    // 1. Hiện thông báo (hoặc loading)
    if (!mounted) return;
    DialogUtils.showLoading(context, message: "Đang định vị...");

    final position = await LocationService.getCurrentPosition();

    // Tắt loading
    if (mounted) DialogUtils.hideLoading(context);

    if (position != null) {
      final locationData = await LocationService.getLocationDetails(
          position.latitude, position.longitude);

      final fullAddress = locationData['full_address'] ?? "Không xác định";

      if (!mounted) return;

      setState(() {
        _searchController.text = fullAddress;
        _displayLat = position.latitude;
        _displayLng = position.longitude;
        _selectedId = null;
      });

      // Báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật vị trí hiện tại')),
      );
    } else {
      if (!mounted) return;
      DialogUtils.showError(
        context,
        title: "Lỗi quyền truy cập",
        message:
            "Vui lòng cho phép quyền truy cập vị trí để sử dụng tính năng này.",
      );
    }
  }

  // --- CHỌN ĐỊA CHỈ TỪ DANH SÁCH ---
  Future<void> _onAddressSelected(AddressModel addr) async {
    // 1. Kiểm tra nếu đang chọn chính nó -> Bỏ chọn (Toggle)
    if (_selectedId == addr.id) {
      setState(() {
        _selectedId = null;
        _displayLat = null;
        _displayLng = null;
        _searchController.clear();
      });
      return;
    }

    // 2. Nếu chọn cái mới
    setState(() {
      _selectedId = addr.id;
      _searchController.clear();
    });

    if (addr.latitude != null && addr.longitude != null) {
      setState(() {
        _displayLat = addr.latitude;
        _displayLng = addr.longitude;
      });
    } else {
      setState(() {
        _displayLat = null;
        _displayLng = null;
        _isSearching = true;
      });

      final result =
          await LocationService.getCoordinatesFromAddress(addr.fullAddress);

      if (mounted && _selectedId == addr.id) {
        setState(() {
          _isSearching = false;
          if (result != null) {
            _displayLat = result['latitude'];
            _displayLng = result['longitude'];
          } else {
            _showErrorDialog();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressVM = context.watch<AddressViewModel>();
    final addresses = addressVM.addresses;

    bool canContinue =
        _selectedId != null || (_displayLat != null && _displayLng != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Nhập địa chỉ"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: BookingStepper(currentStep: 1),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Địa chỉ thực hiện dịch vụ",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Nút lấy vị trí hiện tại
                  CurrentLocationButton(
                    onTap: _getCurrentLocation,
                  ),

                  const SizedBox(height: 16),

                  AddressSearchBar(
                    controller: _searchController,
                    onChanged: (text) => _onSearchChanged(text),
                  ),

                  if (_isSearching && _selectedId == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Text("Đang tìm vị trí...",
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),

                  const SizedBox(height: 24),

                  SavedAddressList(
                    addresses: addresses,
                    selectedAddressId: _selectedId,
                    addressVM: addressVM,
                    onAddressSelected: _onAddressSelected,
                    onRefresh: () {
                      if (mounted) {
                        context.read<AddressViewModel>().loadAddresses();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // BẢN ĐỒ
                  if (_displayLat != null && _displayLng != null) ...[
                    const Text("Vị trí bản đồ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    AddressMiniMap(
                        key: ValueKey("$_displayLat$_displayLng"),
                        latitude: _displayLat!,
                        longitude: _displayLng!),
                  ] else if (_isSearching) ...[
                    // Loading placeholder for map
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ))
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: canContinue
                ? () {
                    if (_displayLat != null && _displayLng != null) {
                      // Get address string - either from selected saved address or search text
                      String addressText;
                      if (_selectedId != null) {
                        // Get address from saved addresses
                        final savedAddress = context
                            .read<AddressViewModel>()
                            .addresses
                            .firstWhere((a) => a.id == _selectedId);
                        addressText = savedAddress.fullAddress;
                      } else {
                        addressText = _searchController.text;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingProviderScreen(
                            userLat: _displayLat!,
                            userLng: _displayLng!,
                            serviceId: widget.serviceId,
                            bookingTime: widget.bookingTime,
                            address: addressText,
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Tiếp theo",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

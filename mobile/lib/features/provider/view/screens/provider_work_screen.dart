import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../widgets/workflow/workflow_job_card.dart';
import '../widgets/workflow/workflow_timer.dart';
import '../widgets/workflow/workflow_actions.dart';
import 'provider_complete_job_screen.dart';
import 'extra_cost_screen.dart'; // Add this

class ProviderWorkScreen extends StatefulWidget {
  final BookingModel booking;
  final String? serviceName;
  final String? customerName;

  const ProviderWorkScreen({
    super.key,
    required this.booking,
    this.serviceName,
    this.customerName,
  });

  @override
  State<ProviderWorkScreen> createState() => _ProviderWorkScreenState();
}

class _ProviderWorkScreenState extends State<ProviderWorkScreen> {
  Timer? _ticker;
  int _currentSeconds = 0;
  int _lastSyncedSeconds = 0;
  bool _isLoading = false;
  String? _displayServiceName;
  String? _displayCustomerName;
  bool _isCancellationDialogShowing = false;
  String? _lastExtraCostStatus;
  bool _isExtraCostDialogShowing = false;
  StreamSubscription<BookingModel>? _bookingSubscription;

  @override
  void initState() {
    super.initState();
    _displayServiceName = widget.serviceName;
    _displayCustomerName = widget.customerName;
    _initTimerLogic();
    _fetchMissingNames();

    // Lắng nghe realtime cho các thay đổi quan trọng (hủy đơn, chi phí phát sinh)
    _bookingSubscription = BookingRepository()
        .streamBooking(widget.booking.id)
        .listen(_onBookingUpdated);
  }

  Future<void> _fetchMissingNames() async {
    bool needsUpdate = false;
    
    if (_displayServiceName == null || _displayServiceName == "Dịch vụ") {
      try {
        final service = await ServiceRepository().getServiceById(widget.booking.serviceId);
        _displayServiceName = service.name;
        needsUpdate = true;
      } catch (e) {
        print("Error fetching service name: $e");
      }
    }

    if (_displayCustomerName == null || _displayCustomerName == "Khách hàng") {
      try {
        final user = await AuthRepository().getUserById(widget.booking.customerId);
        _displayCustomerName = user?.fullName;
        needsUpdate = true;
      } catch (e) {
        print("Error fetching customer name: $e");
      }
    }

    if (needsUpdate && mounted) {
      setState(() {});
    }
  }

  void _initTimerLogic() {
    // Determine initial seconds based on current status
    _updateLocalTimer(widget.booking);
    
    // If already processing, start ticking
    if (widget.booking.status == BookingStatus.processing) {
      _startTicker();
    }
  }

  void _updateLocalTimer(BookingModel booking) {
    final int baseSeconds = booking.totalWorkingSeconds;
    if (baseSeconds > _lastSyncedSeconds) {
      _lastSyncedSeconds = baseSeconds;
    }

    if (booking.status == BookingStatus.processing && booking.lastStartedAt != null) {
      final elapsedSinceLastStart = DateTime.now().difference(booking.lastStartedAt!).inSeconds;
      _currentSeconds = _lastSyncedSeconds + elapsedSinceLastStart;
    } else {
      _currentSeconds = _lastSyncedSeconds;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentSeconds++;
        });
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    _bookingSubscription?.cancel();
    super.dispose();
  }

  void _onBookingUpdated(BookingModel booking) {
    if (!mounted) return;

    // Cập nhật timer local
    _updateLocalTimer(booking);

    // Hiển thị dialog khi đơn bị hủy
    if (booking.status == BookingStatus.cancelled &&
        !_isCancellationDialogShowing) {
      _isCancellationDialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _stopTicker();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Thông báo"),
            content: const Text("Đơn hàng này đã bị hủy."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit WorkScreen
                },
                child: const Text("Đóng"),
              ),
            ],
          ),
        ).then((_) {
          _isCancellationDialogShowing = false;
        });
      });
    }

    // Hiển thị dialog phản hồi chi phí phát sinh (chấp nhận / từ chối)
    _maybeShowExtraCostDialog(booking);
  }

  Future<void> _handleStart(BookingModel booking) async {
    setState(() => _isLoading = true);
    try {
      await BookingRepository().startWorking(booking.id);
      _startTicker();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePause(BookingModel booking) async {
    setState(() => _isLoading = true);
    try {
      // Calculate seconds to add to total
      final lastStart = booking.lastStartedAt ?? DateTime.now();
      final sessionSeconds = DateTime.now().difference(lastStart).inSeconds;

      await BookingRepository().pauseWorking(booking.id, sessionSeconds);
      _stopTicker();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleComplete(BookingModel booking) async {
    int sessionSeconds = 0;
    if (booking.status == BookingStatus.processing && booking.lastStartedAt != null) {
      sessionSeconds = DateTime.now().difference(booking.lastStartedAt!).inSeconds;
    }
    
    debugPrint("--- DEBUG: WorkScreen Final Session Calculation ---");
    debugPrint("Last Started At: ${booking.lastStartedAt}");
    debugPrint("Current Time: ${DateTime.now()}");
    debugPrint("Total Working Seconds (DB): ${booking.totalWorkingSeconds}");
    debugPrint("Calculated Session Seconds (Current): $sessionSeconds");

    // Thay vì hoàn thành ngay, chuyển sang màn hình chụp ảnh bằng chứng
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderCompleteJobScreen(
            booking: booking,
            finalSessionSeconds: sessionSeconds,
            serviceName: _displayServiceName,
            customerName: _displayCustomerName,
          ),
        ),
      );
    }
  }

  Future<void> _handleCancelRequest(BookingModel booking) async {
    final TextEditingController reasonController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 24,
          top: 12,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Yêu cầu hủy đơn",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Vui lòng cho biết lý do bạn muốn hủy đơn hàng này. Yêu cầu sẽ được gửi tới khách hàng để xác nhận.",
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            
            // Input Field
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Nhập lý do chi tiết...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Đóng",
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập lý do")),
                        );
                        return;
                      }
                      
                      Navigator.pop(dialogContext);
                      
                      if (!mounted) return;
                      setState(() => _isLoading = true);
                      
                      final messenger = ScaffoldMessenger.of(context);
                      
                      try {
                        debugPrint("📡 [REPO] Đang gửi yêu cầu hủy cho đơn: ${booking.id}");
                        await BookingRepository().requestCancellation(
                          booking.id, 
                          booking.providerId, 
                          reason: reason
                        );
                        
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Đã gửi yêu cầu hủy cho khách hàng"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("❌ [REPO] Lỗi gửi yêu cầu hủy: $e");
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text("Lỗi: $e"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Gửi yêu cầu",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExtraCost(BookingModel booking) async {
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExtraCostScreen(booking: booking),
        ),
      );
    }
  }

  Widget _buildExtraCostWaitingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đã gửi yêu cầu chi phí phát sinh. Vui lòng chờ khách hàng trả lời để tiếp tục công việc.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBooking(widget.booking.id),
      initialData: widget.booking,
      builder: (context, snapshot) {
        final booking = snapshot.data ?? widget.booking;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7F6),
// ... appbar code ...
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6F7F6),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2937)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Thực hiện công việc",
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      WorkflowJobCard(
                        booking: booking,
                        serviceName: _displayServiceName ?? "Dịch vụ",
                        customerName: _displayCustomerName ?? "Khách hàng",
                      ),
                      const SizedBox(height: 40),
                      if (booking.extraCostStatus == 'pending')
                        _buildExtraCostWaitingBanner(),
                      WorkflowTimer(totalSeconds: _currentSeconds),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: WorkflowActions(
                  status: booking.status,
                  onStart: () => _handleStart(booking),
                  onPause: () => _handlePause(booking),
                  onComplete: () => _handleComplete(booking),
                  onCancelRequest: () => _handleCancelRequest(booking),
                  onAddExtraCost: () => _handleExtraCost(booking),
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _maybeShowExtraCostDialog(BookingModel booking) {
    final status = booking.extraCostStatus;
    if (status == null || (status != 'approved' && status != 'rejected')) return;
    if (status == _lastExtraCostStatus) return;
    _lastExtraCostStatus = status;
    if (_isExtraCostDialogShowing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isExtraCostDialogShowing = true;
      _showExtraCostResponseDialog(booking, status).whenComplete(() {
        _isExtraCostDialogShowing = false;
      });
    });
  }

  Future<void> _showExtraCostResponseDialog(BookingModel booking, String status) {
    final formatter = NumberFormat.currency(locale: 'vi', symbol: '₫');
    final amount = booking.extraCostAmount ?? 0.0;
    final formattedAmount = formatter.format(amount);
    final title = status == 'approved'
        ? 'Chi phí phát sinh đã được chấp nhận'
        : 'Chi phí phát sinh bị từ chối';
    final message = status == 'approved'
        ? 'Khách hàng đã đồng ý và thanh toán $formattedAmount. Vui lòng tiếp tục công việc.'
        : 'Khách hàng từ chối phần chi phí này. Bạn có thể điều chỉnh đề xuất hoặc liên hệ trực tiếp để thống nhất lại.';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(status == 'approved' ? 'Đã hiểu' : 'Đóng'),
          ),
          if (status == 'approved')
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tiếp tục công việc'),
            ),
        ],
      ),
    );
  }
}







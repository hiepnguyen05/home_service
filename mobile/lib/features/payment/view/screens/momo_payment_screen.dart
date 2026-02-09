import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../data/services/payment_api_service.dart';
import '../widgets/momo/momo_payment_info_card.dart';
import '../widgets/momo/momo_instruction_card.dart';

class MoMoPaymentScreen extends StatefulWidget {
  final MoMoPaymentResult paymentResult;
  final String serviceName;
  final double amount;
  final Function(bool success) onPaymentComplete;

  const MoMoPaymentScreen({
    super.key,
    required this.paymentResult,
    required this.serviceName,
    required this.amount,
    required this.onPaymentComplete,
  });

  @override
  State<MoMoPaymentScreen> createState() => _MoMoPaymentScreenState();
}

class _MoMoPaymentScreenState extends State<MoMoPaymentScreen> {
  final PaymentApiService _apiService = PaymentApiService();
  bool _isCheckingStatus = false;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _countdownSeconds = 300; // 5 phút

  // Deep Link
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startPolling();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    debugPrint('[MOMO_DEEPLINK] Initializing AppLinks listener...');
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('[MOMO_DEEPLINK] 🔔 Received URI: $uri');
      if (uri.scheme == 'homeservice' && uri.host == 'payment-callback') {
        _handleDeepLinkCallback(uri);
      }
    });
  }

  void _handleDeepLinkCallback(Uri uri) {
    debugPrint('[MOMO_DEEPLINK] Handling callback: $uri');
    final resultCode = uri.queryParameters['resultCode'];
    final orderId =
        uri.queryParameters['orderId'] ?? widget.paymentResult.orderId;
    debugPrint('[MOMO_DEEPLINK] resultCode: $resultCode, orderId: $orderId');

    if (resultCode == '0' && orderId != null) {
      debugPrint('[MOMO_DEEPLINK] ✅ Success! Calling confirm API...');
      _confirmPaymentAndComplete(orderId, resultCode!);
    } else {
      debugPrint('[MOMO_DEEPLINK] ❌ Failed or cancelled');
      // Không làm gì, để polling tiếp tục hoặc user bấm hủy
    }
  }

  Future<void> _confirmPaymentAndComplete(
      String orderId, String resultCode) async {
    // Gọi API confirm để cập nhật DB
    final confirmed = await _apiService.confirmPayment(orderId, resultCode);
    debugPrint('[MOMO_DEEPLINK] Confirm API result: $confirmed');

    if (confirmed && mounted) {
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      Navigator.pop(context);
      widget.onPaymentComplete(true);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          timer.cancel();
          Navigator.pop(context);
          widget.onPaymentComplete(false);
        }
      });
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;

    setState(() => _isCheckingStatus = true);

    try {
      final orderId = widget.paymentResult.orderId;
      debugPrint('[MOMO_POLL] Checking status for orderId: $orderId');
      if (orderId == null) {
        debugPrint('[MOMO_POLL] ERROR: orderId is null!');
        return;
      }

      final result = await _apiService.checkPaymentStatus(orderId);
      debugPrint('[MOMO_POLL] API Response: $result');

      final data = result['data'];
      final status = data?['status'];
      debugPrint('[MOMO_POLL] Status from DB: $status');

      if (status == 'success' && mounted) {
        debugPrint('[MOMO_POLL] ✅ Payment SUCCESS! Navigating...');
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();
        Navigator.pop(context);
        widget.onPaymentComplete(true);
      } else {
        debugPrint('[MOMO_POLL] ⏳ Status not success yet, will retry in 3s...');
      }
    } catch (e) {
      debugPrint('[MOMO_POLL] ❌ Check status error: $e');
    } finally {
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelPayment() async {
    final confirmed = await DialogUtils.showConfirmation(
      context,
      title: 'Hủy thanh toán',
      message: 'Bạn có chắc chắn muốn hủy giao dịch này không?',
      confirmText: 'Đồng ý',
      cancelText: 'Quay lại',
    );

    if (confirmed == true && mounted) {
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      Navigator.pop(context);
      widget.onPaymentComplete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Thanh toán MoMo"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5).withOpacity(0.8),
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: _cancelPayment,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Timer countdown
              Text(
                'Thời gian còn lại:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(_countdownSeconds),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _countdownSeconds < 60
                      ? Colors.red
                      : Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 20),

              // Main Payment Card
              MoMoPaymentInfoCard(
                serviceName: widget.serviceName,
                amount: widget.amount,
                payUrl: widget.paymentResult.payUrl,
                deepLink: widget.paymentResult.deepLink,
                onOpenApp: () async {
                  bool opened = await _apiService.openMoMoApp(
                    widget.paymentResult.deepLink,
                  );
                  if (!opened && mounted) {
                    await _apiService.openPayUrl(
                      widget.paymentResult.payUrl,
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Instructions
              const MoMoInstructionCard(),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: _cancelPayment,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                  child: const Text(
                    'Hủy thanh toán',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

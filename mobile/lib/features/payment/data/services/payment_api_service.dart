import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MoMoPaymentResult {
  final bool success;
  final String? payUrl;
  final String? qrCodeUrl;
  final String? deepLink;
  final String? orderId;
  final String? message;

  MoMoPaymentResult({
    required this.success,
    this.payUrl,
    this.qrCodeUrl,
    this.deepLink,
    this.orderId,
    this.message,
  });

  factory MoMoPaymentResult.fromJson(Map<String, dynamic> json) {
    return MoMoPaymentResult(
      success: json['success'] ?? false,
      payUrl: json['payUrl'],
      qrCodeUrl: json['qrCodeUrl'],
      deepLink: json['deepLink'],
      orderId: json['orderId'],
      message: json['message'],
    );
  }
}

class PaymentApiService {
  // TODO: Thay bằng URL ngrok của bạn hoặc IP public
  // Lưu ý: Đối với Android Emulator, localhost là 10.0.2.2
  // Nhưng ở đây dùng ngrok nên cứ dùng URL ngrok cho tiện
  static const String baseUrl =
      'https://home-service-vjf7.onrender.com/api/payment'; // Production URL on Render
  // static const String baseUrl = 'http://10.0.2.2:3000/api/payment'; // Localhost for Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api/payment'; // Localhost for iOS Simulator yêu cầu thanh toán MoMo
  Future<MoMoPaymentResult> createMoMoPayment({
    required String bookingId,
    required double amount,
    required String orderInfo,
  }) async {
    print("🔗 [API] Calling createMoMoPayment... URL: $baseUrl/create");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'orderInfo': orderInfo,
        }),
      );

      print("📥 [API] Response Code: ${response.statusCode}");
      print("📥 [API] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return MoMoPaymentResult.fromJson(jsonDecode(response.body));
      } else {
        return MoMoPaymentResult(
          success: false,
          message: 'Failed to create payment: ${response.body}',
        );
      }
    } catch (e) {
      print("❌ [API] Error calling createMoMoPayment: $e");
      return MoMoPaymentResult(
        success: false,
        message: 'Payment API Error: $e',
      );
    }
  }

  /// Kiểm tra trạng thái thanh toán
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$orderId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Payment not found'};
      }
    } catch (e) {
      throw Exception('Check Status Error: $e');
    }
  }

  /// Mở ứng dụng MoMo qua DeepLink
  Future<bool> openMoMoApp(String? deepLink) async {
    if (deepLink == null || deepLink.isEmpty) return false;

    final Uri uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Mở URL thanh toán trên trình duyệt (fallback)
  Future<bool> openPayUrl(String? payUrl) async {
    if (payUrl == null || payUrl.isEmpty) return false;

    final Uri uri = Uri.parse(payUrl);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Xác nhận thanh toán thủ công (backup khi IPN không về)
  Future<bool> confirmPayment(String orderId, String resultCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'resultCode': resultCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('[CONFIRM_API] Error: $e');
      return false;
    }
  }
}

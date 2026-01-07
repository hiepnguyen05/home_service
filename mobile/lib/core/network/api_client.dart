import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Client API để giao tiếp với backend
class ApiClient {
  // URL cơ sở của backend - thay đổi theo môi trường thực tế
  static const String baseUrl = 'http://10.0.2.2:5000'; // Dành cho Android Emulator - cổng 5000
  static const Duration timeout = Duration(seconds: 30);

  /// Headers mặc định cho tất cả request
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers có kèm token xác thực
  static Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  /// Gửi GET request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _headersWithAuth(token) : _headers;
    
    try {
      print('🌐 GET Request: $url');
      print('📋 Headers: $headers');
      
      final response = await http.get(url, headers: headers).timeout(timeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException catch (e) {
      print('⏰ Timeout Exception: $e');
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }

  /// Gửi POST request
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _headersWithAuth(token) : _headers;
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    try {
      print('🌐 POST Request: $url');
      print('📋 Headers: $headers');
      print('📤 Body: $jsonBody');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      ).timeout(timeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException catch (e) {
      print('⏰ Timeout Exception: $e');
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }

  /// Gửi PUT request
  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _headersWithAuth(token) : _headers;
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    try {
      print('🌐 PUT Request: $url');
      print('📋 Headers: $headers');
      print('📤 Body: $jsonBody');
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonBody,
      ).timeout(timeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException catch (e) {
      print('⏰ Timeout Exception: $e');
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }

  /// Gửi DELETE request
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _headersWithAuth(token) : _headers;
    
    try {
      print('🌐 DELETE Request: $url');
      print('📋 Headers: $headers');
      
      final response = await http.delete(url, headers: headers).timeout(timeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException catch (e) {
      print('⏰ Timeout Exception: $e');
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }
}
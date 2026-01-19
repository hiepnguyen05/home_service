import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý lưu trữ local persistent
class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';

  /// Lưu token đăng nhập
  static Future<void> saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, token);
      if (kDebugMode) {
        print('Đã lưu auth token vào SharedPreferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lưu auth token: $e');
      }
    }
  }

  /// Lấy token đăng nhập
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_authTokenKey);
      if (kDebugMode) {
        print('Lấy auth token: ${token != null ? 'có' : 'không có'}');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy auth token: $e');
      }
      return null;
    }
  }

  /// Lưu thông tin user
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userInfoKey, jsonEncode(userInfo));
      if (kDebugMode) {
        print('Đã lưu user info vào SharedPreferences: ${userInfo['full_name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lưu user info: $e');
      }
    }
  }

  /// Lấy thông tin user
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoStr = prefs.getString(_userInfoKey);
      if (userInfoStr != null) {
        final userInfo = jsonDecode(userInfoStr) as Map<String, dynamic>;
        if (kDebugMode) {
          print('Lấy user info: ${userInfo['full_name']}');
        }
        return userInfo;
      }
      if (kDebugMode) {
        print('Không có user info trong SharedPreferences');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy user info: $e');
      }
      return null;
    }
  }

  /// Xóa tất cả dữ liệu đăng nhập
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userInfoKey);
      if (kDebugMode) {
        print('Đã xóa auth data khỏi SharedPreferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi xóa auth data: $e');
      }
    }
  }

  /// Kiểm tra có đăng nhập không
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAuthToken();
      final userInfo = await getUserInfo();
      final loggedIn = token != null && userInfo != null;
      if (kDebugMode) {
        print('Kiểm tra đăng nhập: ${loggedIn ? 'đã đăng nhập' : 'chưa đăng nhập'}');
      }
      return loggedIn;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi kiểm tra đăng nhập: $e');
      }
      return false;
    }
  }
}
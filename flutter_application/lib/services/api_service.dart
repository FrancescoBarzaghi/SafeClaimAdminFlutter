import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.apiBaseUrl;

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get the saved admin token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }

  /// POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    return response;
  } catch (e) {
    print('API ERROR [$endpoint]: $e');
    rethrow;
  }
}

  /// GET request
  Future<http.Response> get(String endpoint, {String? token}) {
    return http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers(token: token),
    );
  }

  /// PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {String? token}) {
    return http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint, {String? token}) {
    return http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers(token: token),
    );
  }
}

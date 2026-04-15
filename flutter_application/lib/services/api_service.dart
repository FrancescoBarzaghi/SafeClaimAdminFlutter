import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Sostituito SharedPreferences
import '../config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Genera gli header includendo il token se presente
  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Recupera il token salvato da AuthService (Keycloak)
  Future<String?> getToken() async {
    // Usiamo la chiave 'jwt_token' definita nell'AuthService
    return await _storage.read(key: 'jwt_token');
  }

  /// POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      print('API ERROR POST [$endpoint]: $e');
      rethrow;
    }
  }

  /// GET request
  Future<http.Response> get(String endpoint) async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      print('API ERROR GET [$endpoint]: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _headers();
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      print('API ERROR PUT [$endpoint]: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      print('API ERROR DELETE [$endpoint]: $e');
      rethrow;
    }
  }
}
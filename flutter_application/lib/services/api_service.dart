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

  /// PATCH request
  Future<http.Response> patch(String endpoint, Map<String, dynamic> body, {String? token}) {
    return http.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  /// GET request with query parameters
  Future<http.Response> getWithQuery(String endpoint, Map<String, String> queryParams, {String? token}) {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    return http.get(
      uri,
      headers: _headers(token: token),
    );
  }

  /// Recupera la lista di utenti da /api/gestioneUtenti/utenti
  Future<List<Map<String, dynamic>>> getUtenti({String? token}) async {
    try {
      final endpoint = '/gestioneUtenti/utenti';
      print('📡 GET $_baseUrl$endpoint (Token: ${token != null ? "Present" : "Null"})');
      
      final response = await get(endpoint, token: token);
      print('📊 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('✅ Raw Response: $json');
        
        final utenti = json['utenti'] as List?;
        return utenti?.cast<Map<String, dynamic>>() ?? [];
      } else {
        print('❌ Error Response: ${response.body}');
        throw Exception('Errore nel caricamento degli utenti: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  /// Ricerca utenti per nome, cognome o email
  Future<List<Map<String, dynamic>>> cercaUtenti(String query, {String? token}) async {
    try {
      final endpoint = '/gestioneUtenti/utenti/cerca';
      print('📡 GET $_baseUrl$endpoint?q=$query');
      
      final response = await getWithQuery(endpoint, {'q': query}, token: token);
      print('📊 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final utenti = json['utenti_trovati'] as List?;
        return utenti?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception('Errore nella ricerca: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la ricerca: $e');
      rethrow;
    }
  }

  /// Testa la connessione all'API
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/common/health'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 5));
      
      print('🔗 API Health Check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ API non raggiungibile: $e');
      return false;
    }
  }
}

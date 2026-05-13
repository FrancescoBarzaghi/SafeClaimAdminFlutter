import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Genera gli header includendo il token automaticamente
  // Abbiamo aggiunto il parametro opzionale 'token' per compatibilità con le chiamate esistenti
  Future<Map<String, String>> _headers({String? token}) async {
    final effectiveToken = token ?? await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
    };
  }

  /// Recupera il token salvato da AuthService (Keycloak)
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _headers();
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      debugPrint('API ERROR POST [$endpoint]: $e');
      rethrow;
    }
  }

  /// GET request (Aggiornata per supportare il parametro token opzionale)
  Future<http.Response> get(String endpoint, {String? token}) async {
    try {
      final headers = await _headers(token: token);
      final response = await http
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      debugPrint('API ERROR GET [$endpoint]: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _headers();
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      debugPrint('API ERROR PUT [$endpoint]: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await _headers();
      final response = await http
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      debugPrint('API ERROR DELETE [$endpoint]: $e');
      rethrow;
    }
  }

  /// PATCH request
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = await _headers(token: token);
    return http.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  /// GET request with query parameters
  Future<http.Response> getWithQuery(
    String endpoint,
    Map<String, String> queryParams, {
    String? token,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _headers(token: token);
    return http.get(uri, headers: headers);
  }

  /// Recupera la lista di utenti da /api/gestioneUtenti/utenti
  Future<List<Map<String, dynamic>>> getUtenti({String? token}) async {
    try {
      final endpoint = '/gestioneUtenti/utenti';
      debugPrint('GET $_baseUrl$endpoint');

      final response = await get(endpoint, token: token);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final utenti = json['utenti'] as List?;
        return utenti?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception(
          'Errore nel caricamento degli utenti: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception getUtenti: $e');
      rethrow;
    }
  }

  /// Ricerca utenti per nome, cognome o email
  Future<List<Map<String, dynamic>>> cercaUtenti(
    String query, {
    String? token,
  }) async {
    try {
      final endpoint = '/gestioneUtenti/utenti/cerca';
      final response = await getWithQuery(endpoint, {'q': query}, token: token);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final utenti = json['utenti_trovati'] as List?;
        return utenti?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception('Errore nella ricerca: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Errore durante la ricerca: $e');
      rethrow;
    }
  }

  /// Testa la connessione all'API
  Future<bool> testConnection() async {
    try {
      final headers = await _headers();
      final response = await http
          .get(Uri.parse('$_baseUrl/common/health'), headers: headers)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

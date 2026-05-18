import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import 'auth_service.dart';
import 'session.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _auth = AuthService();

  // Coalesce eventuali refresh paralleli: se più chiamate ricevono 401 nello
  // stesso istante, devono considerare lo stesso futuro di refresh.
  Future<bool>? _ongoingRefresh;

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

  /// Esegue una richiesta HTTP e intercetta i 401: tenta un refresh, e
  /// se questo fallisce forza il logout + redirect a `LoginPage`.
  Future<http.Response> _sendWithAuth(
    Future<http.Response> Function(Map<String, String> headers) doRequest, {
    String? explicitToken,
  }) async {
    final firstResponse =
        await doRequest(await _headers(token: explicitToken));

    if (firstResponse.statusCode != 401 || explicitToken != null) {
      return firstResponse;
    }

    final refreshed = await _refreshTokenCoalesced();
    if (!refreshed) {
      await forceLogoutToLogin();
      return firstResponse;
    }

    return doRequest(await _headers());
  }

  Future<bool> _refreshTokenCoalesced() {
    return _ongoingRefresh ??= () async {
      try {
        return await _auth.refreshToken();
      } finally {
        _ongoingRefresh = null;
      }
    }();
  }

  /// POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _sendWithAuth((headers) => http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10)));
    } catch (e) {
      debugPrint('API ERROR POST [$endpoint]: $e');
      rethrow;
    }
  }

  /// GET request (Aggiornata per supportare il parametro token opzionale)
  Future<http.Response> get(String endpoint, {String? token}) async {
    try {
      return await _sendWithAuth(
        (headers) => http
            .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
            .timeout(const Duration(seconds: 10)),
        explicitToken: token,
      );
    } catch (e) {
      debugPrint('API ERROR GET [$endpoint]: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _sendWithAuth((headers) => http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10)));
    } catch (e) {
      debugPrint('API ERROR PUT [$endpoint]: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      return await _sendWithAuth((headers) => http
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10)));
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
    return _sendWithAuth(
      (headers) => http.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ),
      explicitToken: token,
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
    return _sendWithAuth(
      (headers) => http.get(uri, headers: headers),
      explicitToken: token,
    );
  }

  /// Recupera la lista di utenti da /api/v1/utenti
  Future<List<Map<String, dynamic>>> getUtenti({String? token}) async {
    try {
      final endpoint = '/v1/utenti';
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
  /// (usa lo stesso endpoint /v1/utenti con query param ?search=)
  Future<List<Map<String, dynamic>>> cercaUtenti(
    String query, {
    String? token,
  }) async {
    try {
      final endpoint = '/v1/utenti';
      final response =
          await getWithQuery(endpoint, {'search': query}, token: token);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final utenti = json['utenti'] as List?;
        return utenti?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception('Errore nella ricerca: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Errore durante la ricerca: $e');
      rethrow;
    }
  }

  /// Aggiorna i ruoli di un utente
  Future<bool> updateUserRoles(String userId, List<String> roles, {String? token}) async {
    try {
      final endpoint = '/v1/utenti/$userId/ruoli';
      final body = {
        'ruoli': roles,
      };

      debugPrint('POST $_baseUrl$endpoint with roles: $roles');

      // Prova con POST se PUT non funziona per CORS
      final response = await post(endpoint, body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Ruoli aggiornati con successo');
        return true;
      } else {
        debugPrint('Errore nell\'aggiornamento dei ruoli: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception updateUserRoles: $e');
      return false;
    }
  }

  /// Elimina un utente dal sistema (DB + Keyclock) mappato sull'endpoint canonico /v1/utenti/<id>
  Future<bool> deleteUser(String userId) async {
    try {
      final endpoint = '/v1/utenti/$userId';
      debugPrint('DELETE $_baseUrl$endpoint');

      final response = await delete(endpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Utente $userId eliminato con successo dal server');
        return true;
      } else {
        debugPrint('Errore nell\'eliminazione dell\'utente: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception deleteUser: $e');
      return false;
    }
  }

  /// Testa la connessione all'API
  Future<bool> testConnection() async {
    try {
      // L'endpoint /v1/health è whitelisted lato backend e non richiede
      // token: chiamiamolo senza passare per l'interceptor (no auto-logout).
      final response = await http
          .get(
            Uri.parse('$_baseUrl/v1/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
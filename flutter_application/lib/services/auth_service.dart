import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  final String _baseUrl = 'https://keycloak.giobra.com';
  final String _realm = 'safeClaim';
  final String _clientId = 'safeclaim-client';

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/realms/$_realm/protocol/openid-connect/token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': _clientId,
          'username': email,
          'password': password,
          'scope': 'openid profile email',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String accessToken = data['access_token'];
        
        // --- CONTROLLO RUOLO ADMIN ---
        if (!_hasAdminRole(accessToken)) {
          // Lanciamo un'eccezione che verrà catturata da login.dart
          throw Exception('Accesso negato: non hai i permessi di amministratore.');
        }

        // Salviamo SIA l'access_token CHE il refresh_token (solo se è admin)
        await _secureStorage.write(key: 'jwt_token', value: accessToken);
        if (data['refresh_token'] != null) {
          await _secureStorage.write(key: 'refresh_token', value: data['refresh_token']);
        }
        return true;
      } else {
        print('Errore Login Keycloak: ${response.body}');
        return false;
      }
    } catch (e) {
      // Se l'errore è la nostra eccezione sui permessi, la passiamo alla pagina di login
      if (e.toString().contains('Accesso negato')) {
        rethrow;
      }
      print('Errore di connessione: $e');
      return false;
    }
  }

  /// Estrae il payload del JWT e verifica la presenza del ruolo "admin"
  bool _hasAdminRole(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = _decodeBase64(parts[1]);
      final Map<String, dynamic> payloadMap = jsonDecode(payload);

      // Cerca il ruolo 'admin' in realm_access -> roles
      if (payloadMap.containsKey('realm_access')) {
        final realmAccess = payloadMap['realm_access'];
        if (realmAccess is Map<String, dynamic> && realmAccess.containsKey('roles')) {
          final List<dynamic> roles = realmAccess['roles'];
          return roles.contains('admin');
        }
      }
      return false;
    } catch (e) {
      print('Errore durante la decodifica dei ruoli: $e');
      return false;
    }
  }

  /// Tenta di rinnovare il token usando il refresh_token salvato
  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    final url = Uri.parse('$_baseUrl/realms/$_realm/protocol/openid-connect/token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(key: 'jwt_token', value: data['access_token']);
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(key: 'refresh_token', value: data['refresh_token']);
        }
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      print('Errore Refresh Token: $e');
      return false; 
    }
  }

  /// Verifica se il token sta per scadere (es. entro i prossimi 60 secondi)
  Future<bool> isTokenExpiringSoon() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = _decodeBase64(parts[1]);
      final payloadMap = jsonDecode(payload);

      if (payloadMap is! Map<String, dynamic> || !payloadMap.containsKey('exp')) {
        return true;
      }

      final exp = payloadMap['exp'] as int;
      final expireDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      return expireDate.difference(now).inSeconds < 60;
    } catch (e) {
      return true;
    }
  }

  /// Helper per decodificare il base64 del JWT
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0: break;
      case 2: output += '=='; break;
      case 3: output += '='; break;
      default: return '';
    }
    return utf8.decode(base64Url.decode(output));
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    await _secureStorage.delete(key: 'refresh_token');
  }
}
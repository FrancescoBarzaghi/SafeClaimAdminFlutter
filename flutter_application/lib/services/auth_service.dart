import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Dati di Keycloak aggiornati
  final String _baseUrl = 'https://keycloak.giobra.com';
  final String _realm = 'safeClaim';
  final String _clientId = 'safeclaim-client'; // <--- AGGIORNATO DA safeClaim-realm

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
        
        // Salviamo il token per ApiService
        await _secureStorage.write(key: 'jwt_token', value: accessToken);
        return true;
      } else {
        // Stampa l'errore esatto restituito da Keycloak per il debug
        print('Errore Keycloak: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Errore di connessione: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }
}
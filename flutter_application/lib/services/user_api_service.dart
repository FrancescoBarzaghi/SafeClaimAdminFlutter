import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/user_category.dart';

/// Servizio API per gestire le richieste degli utenti
/// In un'app reale, useresti http package per fare le richieste
class UserApiService {
  // Sostituisci con l'URL del tuo backend
  static const String baseUrl = 'https://api.safeclaim.local/api';
  
  // Per le richieste HTTP, aggiungi:
  // import 'package:http/http.dart' as http;
  // final client = http.Client();

  /// Recupera la lista degli utenti online
  /// 
  /// GET /api/users/online
  /// 
  /// Risposta attesa:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": [
  ///     {
  ///       "id": "user_1",
  ///       "name": "Mario Rossi",
  ///       "email": "mario@example.com",
  ///       "category": "admin",
  ///       "isOnline": true,
  ///       "lastSeen": "2026-03-04T12:00:00Z",
  ///       "profileImage": "https://example.com/image.jpg"
  ///     }
  ///   ],
  ///   "count": 1
  /// }
  /// ```
  Future<List<User>> getOnlineUsers() async {
    try {
      // Implementazione con http package:
      // final response = await client.get(
      //   Uri.parse('$baseUrl/users/online'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final json = jsonDecode(response.body);
      //   final List<dynamic> usersList = json['data'];
      //   return usersList.map((user) => User.fromJson(user)).toList();
      // } else {
      //   throw Exception('Errore nel caricamento degli utenti online: ${response.statusCode}');
      // }

      // Dati mock per il test
      return _getMockOnlineUsers();
    } catch (e) {
      if (kDebugMode) {
        print('Errore getOnlineUsers: $e');
      }
      rethrow;
    }
  }

  /// Recupera gli utenti per categoria
  /// 
  /// GET /api/users/category/{category}
  /// 
  /// Parametri:
  /// - category: Categoria degli utenti (es: 'admin', 'moderator', 'user')
  /// - limit: (opzionale) Numero massimo di risultati (default: 50)
  /// - offset: (opzionale) Numero di risultati da saltare (default: 0)
  /// 
  /// Risposta attesa:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": [
  ///     {
  ///       "id": "user_1",
  ///       "name": "Mario Rossi",
  ///       "email": "mario@example.com",
  ///       "category": "admin",
  ///       "isOnline": true,
  ///       "lastSeen": "2026-03-04T12:00:00Z",
  ///       "profileImage": "https://example.com/image.jpg"
  ///     }
  ///   ],
  ///   "count": 10,
  ///   "total": 25
  /// }
  /// ```
  Future<List<User>> getUsersByCategory(
    String category, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Implementazione con http package:
      // final queryParameters = {
      //   'limit': limit.toString(),
      //   'offset': offset.toString(),
      // };
      //
      // final response = await client.get(
      //   Uri.parse('$baseUrl/users/category/$category')
      //       .replace(queryParameters: queryParameters),
      //   headers: {'Content-Type': 'application/json'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final json = jsonDecode(response.body);
      //   final List<dynamic> usersList = json['data'];
      //   return usersList.map((user) => User.fromJson(user)).toList();
      // } else {
      //   throw Exception('Errore nel caricamento degli utenti: ${response.statusCode}');
      // }

      // Dati mock per il test
      return _getMockUsersByCategory(category);
    } catch (e) {
      if (kDebugMode) {
        print('Errore getUsersByCategory: $e');
      }
      rethrow;
    }
  }

  /// Recupera tutte le categorie di utenti
  /// 
  /// GET /api/users/categories
  /// 
  /// Risposta attesa:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": [
  ///     {
  ///       "id": "admin",
  ///       "name": "Administrator",
  ///       "description": "Amministratori del sistema",
  ///       "userCount": 5,
  ///       "icon": "admin_icon"
  ///     }
  ///   ]
  /// }
  /// ```
  Future<List<UserCategory>> getUserCategories() async {
    try {
      // Implementazione con http package:
      // final response = await client.get(
      //   Uri.parse('$baseUrl/users/categories'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final json = jsonDecode(response.body);
      //   final List<dynamic> categoriesList = json['data'];
      //   return categoriesList
      //       .map((category) => UserCategory.fromJson(category))
      //       .toList();
      // } else {
      //   throw Exception('Errore nel caricamento delle categorie: ${response.statusCode}');
      // }

      // Dati mock per il test
      return _getMockUserCategories();
    } catch (e) {
      if (kDebugMode) {
        print('Errore getUserCategories: $e');
      }
      rethrow;
    }
  }

  /// Conta il numero di utenti online
  /// 
  /// GET /api/users/online/count
  /// 
  /// Risposta attesa:
  /// ```json
  /// {
  ///   "success": true,
  ///   "count": 15
  /// }
  /// ```
  Future<int> getOnlineUsersCount() async {
    try {
      final onlineUsers = await getOnlineUsers();
      return onlineUsers.length;
    } catch (e) {
      if (kDebugMode) {
        print('Errore getOnlineUsersCount: $e');
      }
      rethrow;
    }
  }

  // ==================== DATI MOCK PER TEST ====================
  // Rimuovi questi metodi quando connetto il vero backend

  List<User> _getMockOnlineUsers() {
    return [
      User(
        id: 'user_1',
        name: 'Mario Rossi',
        email: 'mario@example.com',
        category: 'admin',
        isOnline: true,
        lastSeen: DateTime.now(),
        profileImage: null,
      ),
      User(
        id: 'user_2',
        name: 'Giulia Bianchi',
        email: 'giulia@example.com',
        category: 'moderator',
        isOnline: true,
        lastSeen: DateTime.now(),
        profileImage: null,
      ),
      User(
        id: 'user_3',
        name: 'Andrea Verdi',
        email: 'andrea@example.com',
        category: 'user',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        profileImage: null,
      ),
    ];
  }

  List<User> _getMockUsersByCategory(String category) {
    final allUsers = [
      // Admin users
      User(
        id: 'admin_1',
        name: 'Mario Rossi',
        email: 'mario@example.com',
        category: 'admin',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'admin_2',
        name: 'Laura Rossi',
        email: 'laura@example.com',
        category: 'admin',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      // Moderators
      User(
        id: 'mod_1',
        name: 'Giulia Bianchi',
        email: 'giulia@example.com',
        category: 'moderator',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'mod_2',
        name: 'Francesco Neri',
        email: 'francesco@example.com',
        category: 'moderator',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      // Regular users
      User(
        id: 'user_1',
        name: 'Andrea Verdi',
        email: 'andrea@example.com',
        category: 'user',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'user_2',
        name: 'Sofia Gialli',
        email: 'sofia@example.com',
        category: 'user',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    return allUsers.where((user) => user.category == category).toList();
  }

  List<UserCategory> _getMockUserCategories() {
    return [
      UserCategory(
        id: 'admin',
        name: 'Amministratore',
        description: 'Amministratori del sistema',
        userCount: 5,
        icon: '👨‍💼',
      ),
      UserCategory(
        id: 'moderator',
        name: 'Moderatore',
        description: 'Moderatori della comunità',
        userCount: 12,
        icon: '👮',
      ),
      UserCategory(
        id: 'user',
        name: 'Utente',
        description: 'Utenti normali',
        userCount: 1543,
        icon: '👤',
      ),
      UserCategory(
        id: 'premium',
        name: 'Premium',
        description: 'Utenti con account premium',
        userCount: 234,
        icon: '⭐',
      ),
    ];
  }
}

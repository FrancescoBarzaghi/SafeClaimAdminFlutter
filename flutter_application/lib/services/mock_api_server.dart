/// Mock API Server per test e sviluppo locale
/// Simula le risposte del backend senza bisogno di una connessione reale
import 'dart:convert';

class MockApiServer {
  /// Simula la risposta dell'endpoint GET /api/users/online
  static Map<String, dynamic> getOnlineUsersResponse() {
    return {
      "success": true,
      "data": [
        {
          "id": "user_1",
          "name": "Mario Rossi",
          "email": "mario@example.com",
          "category": "admin",
          "isOnline": true,
          "lastSeen": DateTime.now().toIso8601String(),
          "profileImage": null
        },
        {
          "id": "user_2",
          "name": "Giulia Bianchi",
          "email": "giulia@example.com",
          "category": "moderator",
          "isOnline": true,
          "lastSeen": DateTime.now().toIso8601String(),
          "profileImage": null
        },
        {
          "id": "user_3",
          "name": "Andrea Verdi",
          "email": "andrea@example.com",
          "category": "user",
          "isOnline": true,
          "lastSeen": DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          "profileImage": null
        },
      ],
      "count": 3
    };
  }

  /// Simula la risposta dell'endpoint GET /api/users/category/{category}
  static Map<String, dynamic> getUsersByCategoryResponse(String category) {
    final allUsers = {
      "admin": [
        {
          "id": "admin_1",
          "name": "Mario Rossi",
          "email": "mario@example.com",
          "category": "admin",
          "isOnline": true,
          "lastSeen": DateTime.now().toIso8601String(),
          "profileImage": null
        },
        {
          "id": "admin_2",
          "name": "Laura Rossi",
          "email": "laura@example.com",
          "category": "admin",
          "isOnline": false,
          "lastSeen": DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          "profileImage": null
        },
      ],
      "moderator": [
        {
          "id": "mod_1",
          "name": "Giulia Bianchi",
          "email": "giulia@example.com",
          "category": "moderator",
          "isOnline": true,
          "lastSeen": DateTime.now().toIso8601String(),
          "profileImage": null
        },
        {
          "id": "mod_2",
          "name": "Francesco Neri",
          "email": "francesco@example.com",
          "category": "moderator",
          "isOnline": false,
          "lastSeen": DateTime.now()
              .subtract(const Duration(minutes: 30))
              .toIso8601String(),
          "profileImage": null
        },
      ],
      "user": [
        {
          "id": "user_1",
          "name": "Andrea Verdi",
          "email": "andrea@example.com",
          "category": "user",
          "isOnline": true,
          "lastSeen": DateTime.now().toIso8601String(),
          "profileImage": null
        },
        {
          "id": "user_2",
          "name": "Sofia Gialli",
          "email": "sofia@example.com",
          "category": "user",
          "isOnline": true,
          "lastSeen": DateTime.now()
              .subtract(const Duration(minutes: 15))
              .toIso8601String(),
          "profileImage": null
        },
        {
          "id": "user_3",
          "name": "Paolo Blu",
          "email": "paolo@example.com",
          "category": "user",
          "isOnline": false,
          "lastSeen": DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
          "profileImage": null
        },
      ],
      "premium": [
        {
          "id": "premium_1",
          "name": "Elena Gialli",
          "email": "elena@example.com",
          "category": "premium",
          "isOnline": true,
          "lastSeen": DateTime.now().toIso8601String(),
          "profileImage": null
        },
      ]
    };

    final users = allUsers[category] ?? [];
    return {
      "success": true,
      "data": users,
      "count": users.length,
      "total": users.length
    };
  }

  /// Simula la risposta dell'endpoint GET /api/users/categories
  static Map<String, dynamic> getUserCategoriesResponse() {
    return {
      "success": true,
      "data": [
        {
          "id": "admin",
          "name": "Amministratore",
          "description": "Amministratori del sistema",
          "userCount": 5,
          "icon": "👨‍💼"
        },
        {
          "id": "moderator",
          "name": "Moderatore",
          "description": "Moderatori della comunità",
          "userCount": 12,
          "icon": "👮"
        },
        {
          "id": "user",
          "name": "Utente",
          "description": "Utenti normali",
          "userCount": 1543,
          "icon": "👤"
        },
        {
          "id": "premium",
          "name": "Premium",
          "description": "Utenti con account premium",
          "userCount": 234,
          "icon": "⭐"
        },
      ]
    };
  }

  /// Simula la risposta dell'endpoint GET /api/users/online/count
  static Map<String, dynamic> getOnlineUsersCountResponse() {
    return {
      "success": true,
      "count": 3,
    };
  }
}

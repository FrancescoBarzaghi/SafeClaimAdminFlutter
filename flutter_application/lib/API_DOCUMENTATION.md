# API Documentazione - SafeClaim Users API

## Overview
Queste API forniscono accesso ai dati degli utenti, inclusi lo stato online e le categorie di utenti.

## Configurazione Iniziale

### Dipendenze Richieste
Aggiungi `http` al tuo `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

### Configurazione URL Base
Nel file `lib/services/user_api_service.dart`, aggiorna l'URL del backend:

```dart
static const String baseUrl = 'https://api.tuoserver.com/api';
```

## API Endpoints

### 1. GET /api/users/online

Recupera la lista di tutti gli utenti attualmente online.

**Endpoint:**
```
GET /api/users/online
```

**Headers:**
```
Content-Type: application/json
```

**Risposta Esempio (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "user_1",
      "name": "Mario Rossi",
      "email": "mario@example.com",
      "category": "admin",
      "isOnline": true,
      "lastSeen": "2026-03-04T12:00:00Z",
      "profileImage": "https://example.com/image.jpg"
    },
    {
      "id": "user_2",
      "name": "Giulia Bianchi",
      "email": "giulia@example.com",
      "category": "moderator",
      "isOnline": true,
      "lastSeen": "2026-03-04T12:05:00Z",
      "profileImage": null
    }
  ],
  "count": 2
}
```

**Errore (500 Internal Server Error):**
```json
{
  "success": false,
  "error": "Errore nel caricamento degli utenti"
}
```

---

### 2. GET /api/users/category/{category}

Recupera gli utenti di una specifica categoria.

**Endpoint:**
```
GET /api/users/category/{category}?limit=50&offset=0
```

**Parametri:**
- `category` (path, required): La categoria di utenti ('admin', 'moderator', 'user', 'premium', ecc.)
- `limit` (query, optional): Numero massimo di risultati (default: 50)
- `offset` (query, optional): Numero di risultati da saltare per la paginazione (default: 0)

**Esempio di URL:**
```
GET /api/users/category/admin?limit=10&offset=0
```

**Risposta Esempio (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "admin_1",
      "name": "Mario Rossi",
      "email": "mario@example.com",
      "category": "admin",
      "isOnline": true,
      "lastSeen": "2026-03-04T12:00:00Z",
      "profileImage": null
    }
  ],
  "count": 1,
  "total": 5
}
```

**Errore - Categoria non trovata (404):**
```json
{
  "success": false,
  "error": "Categoria non trovata"
}
```

---

### 3. GET /api/users/categories

Recupera tutte le categorie di utenti disponibili.

**Endpoint:**
```
GET /api/users/categories
```

**Risposta Esempio (200 OK):**
```json
{
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
    }
  ]
}
```

---

### 4. GET /api/users/online/count

Recupera il numero totale di utenti online.

**Endpoint:**
```
GET /api/users/online/count
```

**Risposta Esempio (200 OK):**
```json
{
  "success": true,
  "count": 15
}
```

---

## Modelli Dati

### User
```dart
class User {
  final String id;              // ID univoco dell'utente
  final String name;            // Nome completo
  final String email;           // Email dell'utente
  final String category;        // Categoria (admin, moderator, user, premium)
  final bool isOnline;          // Stato online
  final DateTime lastSeen;      // Ultimo accesso
  final String? profileImage;   // URL immagine profilo (opzionale)
}
```

### UserCategory
```dart
class UserCategory {
  final String id;              // ID univoco della categoria
  final String name;            // Nome della categoria
  final String description;     // Descrizione
  final int userCount;          // Numero di utenti in questa categoria
  final String? icon;           // Emoji o icona (opzionale)
}
```

---

## Utilizzo in Flutter

### 1. Recuperare utenti online

```dart
import 'package:flutter_application_1/services/user_api_service.dart';

final apiService = UserApiService();

void _loadOnlineUsers() async {
  try {
    final onlineUsers = await apiService.getOnlineUsers();
    setState(() {
      users = onlineUsers;
    });
  } catch (e) {
    print('Errore: $e');
    // Mostra un dialogo di errore all'utente
  }
}
```

### 2. Recuperare utenti per categoria

```dart
void _loadUsersByCategory(String category) async {
  try {
    final categoryUsers = await apiService.getUsersByCategory(
      category,
      limit: 20,
      offset: 0,
    );
    setState(() {
      users = categoryUsers;
    });
  } catch (e) {
    print('Errore: $e');
  }
}
```

### 3. Recuperare tutte le categorie

```dart
void _loadCategories() async {
  try {
    final categories = await apiService.getUserCategories();
    setState(() {
      userCategories = categories;
    });
  } catch (e) {
    print('Errore: $e');
  }
}
```

### 4. Ottenere il conteggio utenti online

```dart
void _getOnlineCount() async {
  try {
    final count = await apiService.getOnlineUsersCount();
    print('Utenti online: $count');
  } catch (e) {
    print('Errore: $e');
  }
}
```

---

## Implementazione con HTTP Package

Per usare effettivamente le API, decommentare il codice con `http` nel file `user_api_service.dart` e aggiungere al `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

Esempio completo:

```dart
import 'package:http/http.dart' as http;

Future<List<User>> getOnlineUsers() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users/online'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> usersList = json['data'];
      return usersList.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Errore: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}
```

---

## Code di Stato HTTP

- **200 OK**: Richiesta completata con successo
- **400 Bad Request**: Parametri non validi
- **401 Unauthorized**: Autenticazione richiesta
- **403 Forbidden**: Accesso non autorizzato
- **404 Not Found**: Risorsa non trovata
- **500 Internal Server Error**: Errore del server

---

## Note Importanti

1. **Autenticazione**: Se il backend richiede autenticazione, aggiungi il token nei headers:
   ```dart
   headers: {
     'Content-Type': 'application/json',
     'Authorization': 'Bearer $token',
   }
   ```

2. **Timeout**: Considera di aggiungere un timeout alle richieste:
   ```dart
   final response = await http.get(url).timeout(
     const Duration(seconds: 10),
     onTimeout: () => throw Exception('Timeout'),
   );
   ```

3. **Paginazione**: Usa `limit` e `offset` per gestire grandi liste di utenti

4. **Cache**: Considera di implementare una cache locale per migliorare le performance

---

## Testing

Usa la classe `MockApiServer` nel file `mock_api_server.dart` per testare senza backend:

```dart
import 'package:flutter_application_1/services/mock_api_server.dart';

final mockResponse = MockApiServer.getOnlineUsersResponse();
print(mockResponse);
```

# Guida di Implementazione - API Utenti SafeClaim

## 📋 Riepilogo

Sono state create le seguenti API per gestire gli utenti:

### API Disponibili:
1. **GET /api/users/online** - Recupera tutti gli utenti online
2. **GET /api/users/category/{category}** - Recupera utenti per categoria
3. **GET /api/users/categories** - Recupera tutte le categorie disponibili
4. **GET /api/users/online/count** - Conta gli utenti online

---

## 📁 Struttura dei File Creati

```
lib/
├── models/
│   ├── user.dart                 # Modello User
│   └── user_category.dart        # Modello UserCategory
├── services/
│   ├── user_api_service.dart     # Servizio API principale
│   └── mock_api_server.dart      # Server mock per testing
├── pages/
│   └── users_management.dart     # Pagina di esempio
└── API_DOCUMENTATION.md          # Documentazione completa
```

---

## 🚀 Quick Start

### 1. Aggiungere il Package HTTP (se necessario)

```bash
cd flutter_application
flutter pub add http
```

### 2. Importare il Servizio

```dart
import 'package:flutter_application_1/services/user_api_service.dart';
import 'package:flutter_application_1/models/user.dart';
```

### 3. Utilizzare le API

#### Ottenere utenti online:
```dart
final apiService = UserApiService();
final onlineUsers = await apiService.getOnlineUsers();
```

#### Ottenere utenti per categoria:
```dart
final adminUsers = await apiService.getUsersByCategory('admin');
```

#### Ottenere tutte le categorie:
```dart
final categories = await apiService.getUserCategories();
```

---

## 🔧 Configurazione Backend

### Se hai un backend Django/Node.js/ecc:

1. **Aggiorna l'URL in `user_api_service.dart`:**
```dart
static const String baseUrl = 'https://tuo-backend.com/api';
```

2. **Implementa gli endpoint nel tuo backend:**

#### Endpoint 1: GET /api/users/online
Deve restituire:
```json
{
  "success": true,
  "data": [
    {
      "id": "user_1",
      "name": "Nome Utente",
      "email": "email@domain.com",
      "category": "admin",
      "isOnline": true,
      "lastSeen": "2026-03-04T12:00:00Z",
      "profileImage": null
    }
  ],
  "count": 1
}
```

#### Endpoint 2: GET /api/users/category/{category}
Deve restituire:
```json
{
  "success": true,
  "data": [...],
  "count": 10,
  "total": 50
}
```

#### Endpoint 3: GET /api/users/categories
Deve restituire:
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
    }
  ]
}
```

---

## 💻 Esempio di Implementazione Backend (Django)

### models.py
```python
from django.db import models
from django.utils import timezone

class UserCategory(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=100)
    description = models.TextField()
    icon = models.CharField(max_length=10, null=True, blank=True)

    def __str__(self):
        return self.name

class User(models.Model):
    id = models.CharField(max_length=100, primary_key=True)
    name = models.CharField(max_length=100)
    email = models.EmailField()
    category = models.ForeignKey(UserCategory, on_delete=models.CASCADE)
    is_online = models.BooleanField(default=False)
    last_seen = models.DateTimeField(default=timezone.now)
    profile_image = models.URLField(null=True, blank=True)
```

### views.py
```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Count
import json

@api_view(['GET'])
def get_online_users(request):
    users = User.objects.filter(is_online=True).values(
        'id', 'name', 'email', 'category__id', 'is_online', 'last_seen', 'profile_image'
    )
    
    data = [{
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'category': user['category__id'],
        'isOnline': user['is_online'],
        'lastSeen': user['last_seen'].isoformat(),
        'profileImage': user['profile_image']
    } for user in users]
    
    return Response({
        'success': True,
        'data': data,
        'count': len(data)
    })

@api_view(['GET'])
def get_users_by_category(request, category):
    limit = int(request.GET.get('limit', 50))
    offset = int(request.GET.get('offset', 0))
    
    users = User.objects.filter(category__id=category)[offset:offset+limit].values(...)
    total = User.objects.filter(category__id=category).count()
    
    # ...stessa logica di sopra...
    
    return Response({
        'success': True,
        'data': data,
        'count': len(data),
        'total': total
    })

@api_view(['GET'])
def get_categories(request):
    categories = UserCategory.objects.annotate(
        user_count=Count('user')
    ).values('id', 'name', 'description', 'user_count', 'icon')
    
    data = [{
        'id': cat['id'],
        'name': cat['name'],
        'description': cat['description'],
        'userCount': cat['user_count'],
        'icon': cat['icon']
    } for cat in categories]
    
    return Response({
        'success': True,
        'data': data
    })
```

### urls.py
```python
from django.urls import path
from . import views

urlpatterns = [
    path('api/users/online', views.get_online_users, name='online_users'),
    path('api/users/category/<str:category>', views.get_users_by_category, name='category_users'),
    path('api/users/categories', views.get_categories, name='categories'),
]
```

---

## 🧪 Testing con Dati Mock

Per testare senza un vero backend, il servizio usa automaticamente dati mock:

```dart
final apiService = UserApiService();

// Restituirà dati mock
final users = await apiService.getOnlineUsers();
print(users); // [User(...), User(...), ...]
```

---

## 🎯 Come Integrare nella Pagina Esistente

### Aggiungere il pulsante nel `home.dart`:

```dart
import 'package:flutter_application_1/pages/users_management.dart';

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersManagementPage(),
      ),
    );
  },
  child: const Text('Gestione Utenti'),
),
```

---

## 📊 Categorie Utenti Supportate

- **admin** - Amministratori
- **moderator** - Moderatori
- **user** - Utenti normali
- **premium** - Utenti premium

Puoi aggiungere altre categorie secondo le tue necessità.

---

## 🔐 Aggiungere Autenticazione

Se il backend richiede autenticazione:

```dart
Future<List<User>> getOnlineUsers() async {
  final token = await _getAuthToken(); // Ottieni il token JWT
  
  final response = await client.get(
    Uri.parse('$baseUrl/users/online'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  // ...
}
```

---

## 🐛 Troubleshooting

### Errore: "The http package is not imported"
**Soluzione:** Aggiungi `import 'package:http/http.dart' as http;` al file

### Errore: "Connection refused"
**Soluzione:** Verifica che il backend sia online e che l'URL sia corretto

### Errore: "JSON parse error"
**Soluzione:** Controlla che il backend restituisca il formato JSON corretto

---

## 📝 Prossimi Passi

1. ✅ Modelli creati (User, UserCategory)
2. ✅ Servizio API creato (UserApiService)
3. ✅ Pagina di esempio creata (UsersManagementPage)
4. ⏳ Implementare il backend (Django/Node.js/ecc)
5. ⏳ Aggiornare URL baseUrl
6. ⏳ Aggiungere autenticazione se necessario
7. ⏳ Testare gli endpoint

---

## 📞 Domande Frequenti

**D: Come aggiungere più campi ai modelli User?**
A: Modifica `lib/models/user.dart` e aggiungi i campi al modello e al `fromJson()`

**D: Come implementare il refresh automatico degli utenti online?**
A: Usa `Timer` e `setInterval` per chiamare `getOnlineUsers()` ogni X secondi

**D: Come aggiungere filtri di ricerca?**
A: Aggiungi parametri query al servizio: `?search=mario&sort=name`

**D: Posso usare WebSocket per real-time?**
A: Sì, aggiungi il package `web_socket_channel` e implementa una connessione WebSocket

---

## 📚 Risorse Utili

- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Dart JSON Serialization](https://dart.dev/guides/json)
- [REST API Design Best Practices](https://restfulapi.net/)
- [Django REST Framework](https://www.django-rest-framework.org/)

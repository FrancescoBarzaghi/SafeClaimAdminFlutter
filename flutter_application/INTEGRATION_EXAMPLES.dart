// Esempio di come aggiungere UsersManagementPage al main.dart

import 'package:flutter/material.dart';
import 'lib/pages/login.dart';
import 'lib/pages/home.dart';
import 'lib/pages/users_management.dart'; // Importa la nuova pagina

void main() {
  runApp(const SafeClaimApp());
}

class SafeClaimApp extends StatelessWidget {
  const SafeClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // Puoi anche usare la navigazione con nome:
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const LoginPage(),
      //   '/home': (context) => const HomePage(),
      //   '/users': (context) => const UsersManagementPage(),
      // },
    );
  }
}

// ============================================================

// Esempio di come aggiungere il pulsante in home.dart

/*
import 'package:flutter/material.dart';
import 'users_management.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home - SafeClaim'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Benvenuto in SafeClaim!'),
            const SizedBox(height: 20),
            
            // Pulsante per accedere alla gestione utenti
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
            
            const SizedBox(height: 10),
            
            // Pulsante per visualizzare utenti online
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersManagementPage(),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Visualizza Utenti Online'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============================================================

// Esempio di come usare il servizio in una pagina qualsiasi

/*
import 'package:flutter/material.dart';
import '../services/user_api_service.dart';
import '../models/user.dart';

class MyCustomPage extends StatefulWidget {
  const MyCustomPage({super.key});

  @override
  State<MyCustomPage> createState() => _MyCustomPageState();
}

class _MyCustomPageState extends State<MyCustomPage> {
  final UserApiService _apiService = UserApiService();
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    // Carica gli utenti online quando la pagina si inizializza
    _futureUsers = _apiService.getOnlineUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utenti Online')),
      body: FutureBuilder<List<User>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun utente online'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Chip(label: Text(user.category)),
                );
              },
            );
          }
        },
      ),
    );
  }
}
*/

// ============================================================

// Esempio di Provider per gestire lo stato (consigliato per app complesse)

/*
import 'package:flutter/material.dart';
import '../services/user_api_service.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final UserApiService _apiService = UserApiService();
  
  List<User> _onlineUsers = [];
  List<User> _categoryUsers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get onlineUsers => _onlineUsers;
  List<User> get categoryUsers => _categoryUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Metodi
  Future<void> loadOnlineUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _onlineUsers = await _apiService.getOnlineUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryUsers(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categoryUsers = await _apiService.getUsersByCategory(category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Utilizzo in una pagina:
// final provider = Provider.of<UserProvider>(context, listen: false);
// await provider.loadOnlineUsers();
*/

// ============================================================

// Esempio di Stream per aggiornamenti real-time

/*
import 'dart:async';
import '../models/user.dart';
import '../services/user_api_service.dart';

class UserStream {
  final UserApiService _apiService = UserApiService();
  late StreamController<List<User>> _controller;

  Stream<List<User>> get onlineUsersStream => _controller.stream;

  UserStream() {
    _controller = StreamController<List<User>>();
    _startListening();
  }

  void _startListening() {
    // Refresh ogni 10 secondi
    Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final users = await _apiService.getOnlineUsers();
        _controller.add(users);
      } catch (e) {
        _controller.addError(e);
      }
    });
  }

  void dispose() {
    _controller.close();
  }
}

// Utilizzo:
// final userStream = UserStream();
// StreamBuilder<List<User>>(
//   stream: userStream.onlineUsersStream,
//   builder: (context, snapshot) { ... }
// )
*/

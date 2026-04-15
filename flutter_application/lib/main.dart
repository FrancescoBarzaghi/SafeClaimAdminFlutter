import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pages/login.dart';
import 'pages/home.dart'; // Assicurati che il percorso sia corretto per la tua Dashboard
import 'services/auth_service.dart'; // Aggiungi l'import del servizio

// CHIAVE GLOBALE PER LA NAVIGAZIONE (Permette di cambiare pagina anche fuori dai Widget)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const SafeClaimApp());
}

// Convertito in StatefulWidget per gestire il Timer della sessione
class SafeClaimApp extends StatefulWidget {
  const SafeClaimApp({super.key});

  @override
  State<SafeClaimApp> createState() => _SafeClaimAppState();
}

class _SafeClaimAppState extends State<SafeClaimApp> {
  Timer? _sessionTimer;
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _startSessionMonitor();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // --- LOGICA DI CONTROLLO SESSIONE PERIODICO ---
  void _startSessionMonitor() {
    // Controlla ogni 30 secondi se il token è valido
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      // 1. Verifichiamo se c'è un token salvato. Se non c'è, siamo già sloggati, inutile fare controlli.
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return;

      // 2. Chiediamo ad AuthService se il token sta per scadere (es. < 60 secondi)
      bool isExpiring = await _authService.isTokenExpiringSoon();
      
      if (isExpiring) {
        print("Il token sta per scadere. Tento il refresh...");
        bool refreshed = await _authService.refreshToken();
        
        if (!refreshed) {
          print("Refresh fallito. Forzo il logout.");
          _forceLogout();
        } else {
          print("Token aggiornato con successo in background!");
        }
      }
    });
  }

  void _forceLogout() async {
    await _authService.logout();
    
    // Usa la GlobalKey per riportare l'utente alla LoginPage distruggendo la cronologia delle pagine
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // --- LOGICA DI AVVIO APP ---
  // Funzione che controlla se l'utente ha salvato l'accesso in precedenza
  Future<bool> _checkLoginStatus() async {
    // Sostituito SharedPreferences con FlutterSecureStorage per allinearlo al Login
    final String? token = await _storage.read(key: 'jwt_token');
    // Se il token esiste, restituisce true (l'utente è già loggato)
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // PASSA LA CHIAVE AL MATERIAL APP
      debugShowCheckedModeBanner: false,
      title: 'SafeClaim Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 19, 145, 218)),
        useMaterial3: true,
      ),
      // Usiamo FutureBuilder per aspettare la lettura della memoria
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Mostra una schermata vuota o di caricamento mentre legge la memoria
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color.fromARGB(255, 19, 145, 218),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          // Se ha trovato il token, vai alla Dashboard, altrimenti al Login
          if (snapshot.data == true) {
            return const DashboardPage(); 
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
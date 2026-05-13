import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/theme.dart';
import 'pages/login.dart';
import 'services/auth_service.dart';

// CHIAVE GLOBALE PER LA NAVIGAZIONE (Permette di cambiare pagina anche fuori dai Widget)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const SafeClaimApp());
}

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

    // --- MODIFICA AGGIUNTA ---
    // Pulizia immediata: ogni volta che l'app viene riavviata da zero,
    // cancelliamo i vecchi token. In questo modo partiamo sempre da una situazione pulita
    // e il timer inizierà a fare i controlli solo dopo che avrai fatto il nuovo login.
    _authService.logout();
    // -------------------------

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
      // Verifichiamo che il widget sia ancora montato prima di procedere
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // 1. Verifichiamo se c'è un token salvato. Se non c'è (es. siamo alla pagina login), non fa nulla.
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return;

      // 2. Chiediamo ad AuthService se il token sta per scadere (es. < 60 secondi)
      bool isExpiring = await _authService.isTokenExpiringSoon();

      if (isExpiring) {
        debugPrint("Il token sta per scadere. Tento il refresh...");
        bool refreshed = await _authService.refreshToken();

        if (!refreshed) {
          debugPrint("Refresh fallito. Forzo il logout.");
          _forceLogout();
        } else {
          debugPrint("Token aggiornato con successo in background!");
        }
      }
    });
  }

  void _forceLogout() async {
    await _authService.logout();

    // Usa la GlobalKey per riportare l'utente alla LoginPage distruggendo la cronologia delle pagine
    if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // PASSA LA CHIAVE AL MATERIAL APP
      debugShowCheckedModeBanner: false,
      title: 'SafeClaim Admin',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.light,
      // Ora l'app mostrerà sempre la LoginPage all'avvio
      home: const LoginPage(),
    );
  }
}

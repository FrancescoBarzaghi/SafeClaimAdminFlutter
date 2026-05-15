import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'pages/login.dart';
import 'services/auth_service.dart';
import 'services/session.dart';

void main() {
  runApp(const SafeClaimApp());
}

class SafeClaimApp extends StatefulWidget {
  const SafeClaimApp({super.key});

  @override
  State<SafeClaimApp> createState() => _SafeClaimAppState();
}

class _SafeClaimAppState extends State<SafeClaimApp> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Pulizia immediata: ogni volta che l'app viene riavviata da zero,
    // cancelliamo i vecchi token e partiamo dalla LoginPage. La gestione
    // della scadenza durante l'uso è ora a carico dell'interceptor 401
    // dentro `ApiService` (refresh on-demand + redirect al login).
    _authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SafeClaim Admin',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.light,
      home: const LoginPage(),
    );
  }
}

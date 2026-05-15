import 'package:flutter/material.dart';

import '../pages/login.dart';
import 'auth_service.dart';

/// Chiave globale del Navigator dell'app. Permette di forzare un cambio
/// pagina anche da codice non-widget (es. interceptor HTTP).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Pulisce i token dello storage sicuro, prova un logout su Keycloak
/// (best-effort) e riporta l'utente alla `LoginPage` distruggendo lo
/// stack di navigazione.
Future<void> forceLogoutToLogin() async {
  await AuthService().logout();

  final navigator = navigatorKey.currentState;
  if (navigator == null || !navigator.mounted) return;

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (Route<dynamic> route) => false,
  );
}

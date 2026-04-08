import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'pages/home.dart'; // Assicurati che il percorso sia corretto per la tua Dashboard

void main() {
  runApp(const SafeClaimApp());
}

class SafeClaimApp extends StatelessWidget {
  const SafeClaimApp({super.key});

  // Funzione che controlla se l'utente ha salvato l'accesso in precedenza
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('admin_token');
    // Se il token esiste, restituisce true (l'utente è già loggato)
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
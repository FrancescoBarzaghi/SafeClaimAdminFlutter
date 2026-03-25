import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'newaccount.dart';
import 'login.dart';
import 'elenco.dart';
import 'gestioneut.dart';

// NOTA: Se hai 'mockUsers' definito in un altro file (es. elenco.dart), 
// assicurati che sia importato correttamente, altrimenti la ListaUtentiPage darà errore.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        fontFamily: 'Inter',
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 4,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  String errorMessage = '';
  
  int activeUsers = 0;
  Map<String, int> rolesCount = {};

  // ⚠️ ATTENZIONE: Cambia l'URL in base al tuo ambiente!
  // - Emulatore Android: http://10.0.2.2:5000
  // - Dispositivo fisico o Web: http://<IP_DEL_TUO_PC>:5000
  // Assicurati anche di inserire il prefisso corretto del Blueprint se lo hai configurato in Flask.
  final String baseUrl = 'http://10.0.2.2:5000'; 

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      // 1. Chiamata API per il conteggio utenti attivi
      final countRes = await http.get(Uri.parse('$baseUrl/count'));
      if (countRes.statusCode == 200) {
        final countData = json.decode(countRes.body);
        activeUsers = countData['active_users'] ?? 0;
      }

      // 2. Chiamata API per le statistiche dei ruoli
      final rolesRes = await http.get(Uri.parse('$baseUrl/roles-report'));
      if (rolesRes.statusCode == 200) {
        final rolesData = json.decode(rolesRes.body);
        final Map<String, dynamic> apiRoles = rolesData['roles_count'] ?? {};
        // Convertiamo la mappa dinamica in una mappa String, int
        rolesCount = apiRoles.map((key, value) => MapEntry(key, value as int));
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Errore di connessione al server';
        isLoading = false;
      });
      print("Errore API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator()) // Mostra caricamento
              : errorMessage.isNotEmpty 
                ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Passiamo i dati reali alla card
                        _ActiveUsersCard(activeUsers: activeUsers),
                        const SizedBox(height: 20),
                        const _UserManagementCard(),
                        const SizedBox(height: 20),
                        // Passiamo i dati reali alla card dei ruoli
                        _RoleStatisticsCard(rolesMap: rolesCount),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- HEADER ---------------- */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: 70 + topPadding,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E66F5),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                // fallback in caso manchi l'asset per non bloccare l'app
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Colors.white, size: 40),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  itemBuilder: (_) => const [
                    PopupMenuItem(enabled: false, child: Text('Notifiche')),
                  ],
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.person, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'logout') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(enabled: false, child: Text('Admin')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- ACTIVE USERS ---------------- */

class _ActiveUsersCard extends StatelessWidget {
  final int activeUsers; // Aggiunto parametro dinamico

  const _ActiveUsersCard({required this.activeUsers});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.groups, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          const Text(
            'UTENTI ATTIVI',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '$activeUsers', // Usa il valore dall'API
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- USER MANAGEMENT ---------------- */

class _UserManagementCard extends StatelessWidget {
  const _UserManagementCard();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestione Utenti',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            'Crea Nuovo Account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewAccountPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            'Gestisci Ruoli Utenti',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ListaUtentiPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            'Visualizza Elenco',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ElencoPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ---------------- ACTION BUTTON ---------------- */

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionButton(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E66F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/* ---------------- ROLE STATISTICS ---------------- */

class _RoleStatisticsCard extends StatelessWidget {
  final Map<String, int> rolesMap; // Aggiunto parametro per ricevere la mappa

  const _RoleStatisticsCard({required this.rolesMap});

  @override
  Widget build(BuildContext context) {
    // Se non ci sono ruoli mostriamo un messaggio
    if (rolesMap.isEmpty) {
      return const _WhiteCard(
        child: Center(child: Text("Nessuna statistica ruoli disponibile.")),
      );
    }

    return _WhiteCard(
      child: Column(
        // Genera dinamicamente le righe in base a cosa risponde il backend
        children: rolesMap.entries.map((entry) {
          // Capitalizziamo la prima lettera del ruolo (es. "automobilista" -> "Automobilista")
          String capitalizedRole = entry.key.isEmpty 
            ? 'Sconosciuto' 
            : entry.key[0].toUpperCase() + entry.key.substring(1);
            
          return _StatRow(capitalizedRole, entry.value.toString());
        }).toList(),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String role;
  final String total;

  const _StatRow(this.role, this.total);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(role, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(total, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/* ---------------- WHITE CARD ---------------- */

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

/* ---------------- LISTA UTENTI PER SELEZIONE ---------------- */
// (L'ho lasciata intatta per non rompere il tuo codice, in futuro dovremo collegare alle API anche questa!)

class ListaUtentiPage extends StatefulWidget {
  const ListaUtentiPage({super.key});

  @override
  _ListaUtentiPageState createState() => _ListaUtentiPageState();
}

class _ListaUtentiPageState extends State<ListaUtentiPage> {
  String searchQuery = '';
  // ATTENZIONE: Questo mockUsers deve essere definito altrove nel tuo progetto
  // altrimenti dovrai fetchare anche qui l'elenco utenti dal backend (API GET "/")
  final List<dynamic> mockUsers = []; 

  @override
  Widget build(BuildContext context) {
    // ... logica immutata
    return Scaffold(
      appBar: AppBar(title: const Text("Da implementare con API")),
      body: const Center(child: Text("Sostituisci i mock con i dati API GET '/'")),
    );
  }
}
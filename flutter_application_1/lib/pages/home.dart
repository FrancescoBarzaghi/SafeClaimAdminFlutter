import 'package:flutter/material.dart';
import 'newaccount.dart';
import 'login.dart';
import 'elenco.dart';
import 'gestioneut.dart';

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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  SizedBox(height: 20),
                  _ActiveUsersCard(),
                  SizedBox(height: 20),
                  _UserManagementCard(),
                  SizedBox(height: 20),
                  _RoleStatisticsCard(),
                  SizedBox(height: 30),
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
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E66F5),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) =>
                  const Icon(Icons.shield, color: Colors.white, size: 40),
            ),
            const Spacer(),

            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              icon: const Icon(Icons.notifications, color: Colors.white),
              itemBuilder: (_) => const [
                PopupMenuItem(enabled: false, child: Text('Notifiche')),
              ],
            ),

            const SizedBox(width: 16),

            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(enabled: false, child: Text('Admin')),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
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
  const _ActiveUsersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.groups, color: Colors.white, size: 28),
          SizedBox(height: 6),
          Text(
            'UTENTI ATTIVI',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            '312',
            style: TextStyle(
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
              // Mostra prima la lista utenti
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

/* ---------------- LISTA UTENTI PER SELEZIONE ---------------- */

class ListaUtentiPage extends StatefulWidget {
  const ListaUtentiPage({super.key});

  @override
  _ListaUtentiPageState createState() => _ListaUtentiPageState();
}

class _ListaUtentiPageState extends State<ListaUtentiPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = mockUsers.where((u) {
      final q = searchQuery.toLowerCase();
      return q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleziona Utente", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E66F5),
        leading: const BackButton(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cerca utente...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final user = filtered[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GestioneUtPage(user: user),
                  ),
                );
              },
            ),
          );
        },
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
  const _RoleStatisticsCard();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: const [
          _StatRow('Perito', '24'),
          _StatRow('Admin', '5'),
          _StatRow('Soccorso', '18'),
          _StatRow('Officina', '12'),
          _StatRow('Automobilista', '253'),
        ],
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
          Text(role),
          const Spacer(),
          Text(total),
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

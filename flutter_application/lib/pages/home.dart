import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import './newaccount.dart';
import './login.dart';
import './elenco.dart';
import './gestioneut.dart';
import '../models/user_model.dart';

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
            // LOGO (non più più grande dell’header)
            SizedBox(
              height: 40, // <= tienilo tra 32 e 44 per stare bene nell’header
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),

            // BLOCCO ICONE A DESTRA: stesso "box" per allineamento perfetto
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

class _ActiveUsersCard extends StatefulWidget {
  const _ActiveUsersCard();

  @override
  State<_ActiveUsersCard> createState() => _ActiveUsersCardState();
}

class _ActiveUsersCardState extends State<_ActiveUsersCard> {
  final ApiService _api = ApiService();
  int? _totaleUtenti;

  @override
  void initState() {
    super.initState();
    _loadUtenti();
  }

  Future<void> _loadUtenti() async {
    try {
      final token = await _api.getToken();
      final response = await _api.get('/gestioneUtenti/utenti/count', token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() => _totaleUtenti = data['totale_utenti']);
        }
      }
    } catch (_) {
      // Errore di connessione, resta null
    }
  }

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
          _totaleUtenti != null
              ? Text(
                  '$_totaleUtenti',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
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
  final ApiService _apiService = ApiService();
  
  String searchQuery = '';
  List<AppUser> allUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Carica gli utenti dall'API
  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final token = await _apiService.getToken();
      final usersData = await _apiService.getUtenti(token: token);
      
      if (mounted) {
        setState(() {
          allUsers = usersData
              .map((u) => AppUser.fromApiResponse(u))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<AppUser> get filtered {
    return allUsers.where((u) {
      final q = searchQuery.toLowerCase();
      return q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleziona Utente", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E66F5),
        leading: const BackButton(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2), // grigio chiaro
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: "Cerca utente...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Nessun utente trovato',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Nessun risultato',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
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

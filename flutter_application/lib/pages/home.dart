import 'package:flutter/material.dart';
import 'dart:convert';
import '../app/theme.dart';
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
        scaffoldBackgroundColor: SafeClaimColors.background,
        fontFamily: 'Inter',
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: SafeClaimColors.card,
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
                  _RoleStatisticsCard(), // Ora è dinamico
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
        color: SafeClaimColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        border: Border(bottom: BorderSide(color: SafeClaimColors.primaryDark)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
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
                      child: Text(
                        'Logout',
                        style: TextStyle(color: SafeClaimColors.danger),
                      ),
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

enum LoadingStatus { loading, success, error }

class _ActiveUsersCardState extends State<_ActiveUsersCard> {
  final ApiService _api = ApiService();
  int? _totaleUtenti;
  LoadingStatus _status = LoadingStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadUtenti();
  }

  Future<void> _loadUtenti() async {
    setState(() => _status = LoadingStatus.loading);
    try {
      final response = await _api.get('/gestioneUtenti/utenti/count');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _totaleUtenti = data['totale_utenti'];
            _status = LoadingStatus.success;
          });
        }
      } else {
        setState(() => _status = LoadingStatus.error);
      }
    } catch (e) {
      if (mounted) setState(() => _status = LoadingStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _status == LoadingStatus.error
            ? SafeClaimColors.warning
            : SafeClaimColors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SafeClaimColors.primaryDark),
      ),
      child: Column(
        children: [
          Icon(
            _status == LoadingStatus.error ? Icons.warning : Icons.groups,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 6),
          const Text('UTENTI ATTIVI', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          if (_status == LoadingStatus.loading)
            const SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          else if (_status == LoadingStatus.error)
            TextButton(
              onPressed: _loadUtenti,
              child: const Text(
                'Riprova',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              '$_totaleUtenti',
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
                MaterialPageRoute(builder: (_) => const NewAccountPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            'Gestisci Ruoli Utenti',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListaUtentiPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            'Visualizza Elenco',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ElencoPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ---------------- LISTA UTENTI (REAL DATA) ---------------- */

class ListaUtentiPage extends StatefulWidget {
  const ListaUtentiPage({super.key});

  @override
  State<ListaUtentiPage> createState() => ListaUtentiPageState();
}

class ListaUtentiPageState extends State<ListaUtentiPage> {
  final ApiService _apiService = ApiService();

  String searchQuery = '';
  List<AppUser> allUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final token = await _apiService.getToken();
      final usersData = await _apiService.getUtenti(token: token);

      if (mounted) {
        setState(() {
          allUsers = usersData.map((u) => AppUser.fromApiResponse(u)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento utenti: $e");
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
        title: const Text(
          "Seleziona Utente",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: SafeClaimColors.primary,
        leading: const BackButton(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: SafeClaimColors.primaryLightest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SafeClaimColors.primaryLight),
              ),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                style: const TextStyle(
                  color: SafeClaimColors.foreground,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: "Cerca utente...",
                  prefixIcon: Icon(Icons.search),
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
                  const Icon(
                    Icons.people_outline,
                    size: 48,
                    color: SafeClaimColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun utente trovato',
                    style: const TextStyle(color: SafeClaimColors.textMuted),
                  ),
                ],
              ),
            )
          : filtered.isEmpty
          ? Center(
              child: Text(
                'Nessun risultato',
                style: const TextStyle(color: SafeClaimColors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final user = filtered[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
          backgroundColor: SafeClaimColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

/* ---------------- ROLE STATISTICS (MODIFICATA - DINAMICA) ---------------- */

class _RoleStatisticsCard extends StatefulWidget {
  const _RoleStatisticsCard();

  @override
  State<_RoleStatisticsCard> createState() => _RoleStatisticsCardState();
}

class _RoleStatisticsCardState extends State<_RoleStatisticsCard> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _stats = {};
  LoadingStatus _status = LoadingStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _status = LoadingStatus.loading);
    try {
      // Chiamata all'API in homeAdmin.py
      final response = await _api.get('/home-admin/stats-ruoli');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _stats = decoded['data'] ?? {};
            _status = LoadingStatus.success;
          });
        }
      } else {
        if (mounted) setState(() => _status = LoadingStatus.error);
      }
    } catch (e) {
      if (mounted) setState(() => _status = LoadingStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(child: _buildContent());
  }

  Widget _buildContent() {
    if (_status == LoadingStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: SafeClaimColors.primary),
        ),
      );
    }

    if (_status == LoadingStatus.error) {
      return Center(
        child: TextButton(
          onPressed: _loadStats,
          child: const Text(
            'Errore dati. Riprova',
            style: TextStyle(color: SafeClaimColors.danger),
          ),
        ),
      );
    }

    if (_stats.isEmpty) {
      return const Center(child: Text('Nessun utente nel sistema'));
    }

    return Column(
      children: _stats.entries.map((entry) {
        return _StatRow(entry.key, entry.value.toString());
      }).toList(),
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
          Text(
            total,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: SafeClaimColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SafeClaimColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SafeClaimColors.primaryLight),
      ),
      child: child,
    );
  }
}

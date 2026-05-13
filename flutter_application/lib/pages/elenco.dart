import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'gestioneut.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../widgets/safeclaim_ui.dart';

/// =====================
/// PAGINA ELENCO
/// =====================

class ElencoPage extends StatefulWidget {
  const ElencoPage({super.key});

  @override
  State<ElencoPage> createState() => _ElencoPageState();
}

class _ElencoPageState extends State<ElencoPage> {
  final ApiService _apiService = ApiService();

  String search = "";
  UserRole? selectedRole;
  List<AppUser> allUsers = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Carica gli utenti dall'API
  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await _apiService.getToken();
      debugPrint('Token disponibile: ${token != null ? "Si" : "No"}');

      final usersData = await _apiService.getUtenti(token: token);

      if (mounted) {
        setState(() {
          allUsers = usersData.map((u) => AppUser.fromApiResponse(u)).toList();
          isLoading = false;
        });
        debugPrint('${allUsers.length} utenti caricati');
      }
    } catch (e) {
      final errorMsg = 'Errore nel caricamento degli utenti: $e';
      debugPrint(errorMsg);

      if (mounted) {
        setState(() {
          errorMessage = errorMsg;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: SafeClaimColors.danger,
          ),
        );
      }
    }
  }

  /// Ricerca utenti dal API
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      _loadUsers();
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await _apiService.getToken();
      final usersData = await _apiService.cercaUtenti(query, token: token);

      setState(() {
        allUsers = usersData.map((u) => AppUser.fromApiResponse(u)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Errore nella ricerca: $e';
        isLoading = false;
      });
    }
  }

  List<AppUser> get filteredUsers {
    return allUsers.where((u) {
      final s = search.toLowerCase();
      final matchesSearch =
          u.name.toLowerCase().contains(s) ||
          u.email.toLowerCase().contains(s) ||
          u.phone.contains(search);

      final matchesRole =
          selectedRole == null || u.roles.contains(selectedRole);

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafeClaimColors.background,
      appBar: AppBar(
        backgroundColor: SafeClaimColors.primary,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: const [
            Icon(Icons.people, color: Colors.white),
            SizedBox(width: 8),
            Text("Lista Utenti", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadUsers,
            ),
        ],
      ),
      body: isLoading && allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && allUsers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: SafeClaimColors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: SafeClaimColors.danger,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadUsers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final isConnected = await _apiService.testConnection();
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isConnected
                                  ? 'API Raggiungibile'
                                  : 'API Non Raggiungibile',
                            ),
                            backgroundColor: isConnected
                                ? SafeClaimColors.primary
                                : SafeClaimColors.danger,
                          ),
                        );
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Test Connessione'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SafeClaimColors.warning,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _searchBar(),
                  const SizedBox(height: 16),
                  _roleFilter(),
                  const SizedBox(height: 12),
                  Text(
                    "Mostrando ${filteredUsers.length} di ${allUsers.length} utenti",
                    style: const TextStyle(color: SafeClaimColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  if (filteredUsers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'Nessun utente trovato',
                          style: const TextStyle(
                            color: SafeClaimColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredUsers.map(
                      (u) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _userCard(u),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// =====================
  /// SEARCH BAR
  /// =====================

  Widget _searchBar() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: SafeClaimColors.primaryLightest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SafeClaimColors.primaryLight, width: 1),
      ),
      child: TextField(
        onChanged: (v) {
          setState(() => search = v);
          _searchUsers(v);
        },
        style: const TextStyle(color: SafeClaimColors.foreground, fontSize: 16),
        decoration: const InputDecoration(
          hintText: "Cerca utente...",
          hintStyle: TextStyle(color: SafeClaimColors.textMuted, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: SafeClaimColors.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  /// =====================
  /// FILTRI RUOLO
  /// =====================

  Widget _roleFilter() {
    return Card(
      color: SafeClaimColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filtra per ruolo:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("Tutti"),
                  selected: selectedRole == null,
                  onSelected: (_) => setState(() => selectedRole = null),
                  selectedColor: SafeClaimColors.primary,
                  backgroundColor: SafeClaimColors.card,
                  labelStyle: TextStyle(
                    color: selectedRole == null
                        ? Colors.white
                        : SafeClaimColors.textStrong,
                  ),
                ),
                ...UserRole.values.map((r) {
                  final cfg = roleConfig[r]!;
                  final selected = selectedRole == r;
                  return ChoiceChip(
                    label: Text(cfg.label),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedRole = r),
                    selectedColor: cfg.bg,
                    backgroundColor: SafeClaimColors.card,
                    labelStyle: TextStyle(
                      color: selected ? cfg.text : SafeClaimColors.textStrong,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// =====================
  /// CARD UTENTE
  /// =====================

  Widget _userCard(AppUser user) {
<<<<<<< HEAD
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.phone,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.roles.map((role) {
                      final cfg = roleConfig[role]!;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cfg.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cfg.icon, size: 14, color: cfg.text),
                            const SizedBox(width: 4),
                            Text(
                              cfg.label,
                              style:
                                  TextStyle(color: cfg.text, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
=======
    final mainRole = user.roles.first;
    final otherRoles = user.roles.length > 1
        ? user.roles.sublist(1)
        : <UserRole>[];
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GestioneUtPage(user: user)),
        );
        setState(() {}); // Aggiorna i ruoli al ritorno
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: SafeClaimColors.primaryLightest,
                child: const Icon(
                  Icons.person,
                  color: SafeClaimColors.textMuted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (otherRoles.isNotEmpty)
                          PopupMenuButton<UserRole>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            itemBuilder: (context) => [
                              PopupMenuItem<UserRole>(
                                enabled: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Altri ruoli:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: SafeClaimColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...otherRoles.map((role) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: SafeClaimRoleBadge(role: role),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: SafeClaimColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        color: SafeClaimColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: SafeClaimRoleBadge(role: mainRole),
                    ),
                  ],
                ),
>>>>>>> 365c10e (redesign grafico)
              ),
            ),
          ],
        ),
      ),
    );
  }
}


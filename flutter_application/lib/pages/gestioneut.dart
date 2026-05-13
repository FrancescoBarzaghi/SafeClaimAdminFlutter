import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../widgets/safeclaim_ui.dart';

class GestioneUtPage extends StatefulWidget {
  final AppUser user;

  const GestioneUtPage({super.key, required this.user});

  @override
  State<GestioneUtPage> createState() => _GestioneUtPageState();
}

class _GestioneUtPageState extends State<GestioneUtPage> {
  final ApiService _apiService = ApiService();

  late AppUser user;
  String searchQuery = "";
  List<AppUser> allUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _loadUsers();
  }

  /// Carica gli utenti dall'API per la ricerca
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
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<AppUser> get filteredUsers {
    if (searchQuery.isEmpty) {
      return allUsers;
    }
    return allUsers.where((u) {
      final s = searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(s) ||
          u.email.toLowerCase().contains(s) ||
          u.phone.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Controllo se l'utente è attivo (ha almeno un ruolo)
    final bool isActive = user.roles.isNotEmpty;

    return Scaffold(
      backgroundColor: SafeClaimColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SafeClaimColors.primary,
        title: const Text(
          "Gestione Utenti",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.group, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${filteredUsers.length} utenti",
                style: const TextStyle(color: SafeClaimColors.textMuted),
              ),
            ),
            // Card Utente Selezionato
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: safeClaimCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: SafeClaimColors.primaryLightest,
                        child: Icon(
                          Icons.person,
                          color: SafeClaimColors.textMuted,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: SafeClaimColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Badge Attivo / Disattivo Dinamico
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: safeClaimStatusDecoration(
                              background: isActive
                                  ? SafeClaimColors.primaryLightest
                                  : SafeClaimColors.neutral,
                              border: isActive
                                  ? SafeClaimColors.primaryLight
                                  : SafeClaimColors.textMuted,
                              radius: 12,
                            ),
                            child: Text(
                              isActive ? "Attivo" : "Disattivo",
                              style: TextStyle(
                                color: isActive
                                    ? SafeClaimColors.primaryDark
                                    : SafeClaimColors.textStrong,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Seleziona Ruolo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: SafeClaimColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Griglia Ruoli
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.2,
                    children: UserRole.values.map((role) {
                      final isSelected = user.roles.contains(role);
                      final cfg = roleConfig[role]!;

                      return _buildRoleButton(role, cfg, isSelected);
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Bottone Elimina
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: SafeClaimColors.dangerSoft,
                        foregroundColor: SafeClaimColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Logica eliminazione
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(
                        "Elimina Utente",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Risultati ricerca",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredUsers
                        .where((u) => u.id != user.id)
                        .take(5)
                        .map(
                          (u) => GestureDetector(
                            onTap: () => setState(() => user = u),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: SafeClaimColors.primaryLightest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: SafeClaimColors.primaryLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/150',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          u.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          u.email,
                                          style: const TextStyle(
                                            color: SafeClaimColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(UserRole role, RoleConfig cfg, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!isSelected) {
            user.roles.add(role);
          } else {
            // Rimosso il limite: ora puoi deselezionare tutti i ruoli
            user.roles.remove(role);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? cfg.bg : SafeClaimColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? cfg.text.withValues(alpha: 0.45)
                : SafeClaimColors.primaryLight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForRole(role),
              color: isSelected ? cfg.text : SafeClaimColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              cfg.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? cfg.text : SafeClaimColors.textStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.shield_outlined;
      case UserRole.automobilista:
        return Icons.directions_car_outlined;
      case UserRole.officina:
        return Icons.build_outlined;
      case UserRole.soccorso:
        return Icons.local_taxi;
      case UserRole.perito:
        return Icons.assignment_outlined;
      case UserRole.assicuratore:
        return Icons.verified_outlined;
      case UserRole.azienda:
        return Icons.business_outlined;
    }
  }
}

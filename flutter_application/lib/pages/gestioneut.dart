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
  bool isSaving = false;
  bool isDeleting = false; // <-- Nuova variabile di stato per il caricamento dell'eliminazione

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

  /// Salva i ruoli dell'utente nel database
  Future<void> _saveUserRoles() async {
    setState(() => isSaving = true);
    try {
      final rolesStrings = user.roles.map((role) {
        switch (role) {
          case UserRole.perito:
            return 'perito';
          case UserRole.automobilista:
            return 'automobilista';
          case UserRole.officina:
            return 'officina';
          case UserRole.soccorso:
            return 'soccorso';
          case UserRole.admin:
            return 'admin';
          case UserRole.assicuratore:
            return 'assicuratore';
          case UserRole.azienda:
            return 'azienda';
        }
      }).toList();

      final success = await _apiService.updateUserRoles(user.id, rolesStrings);

      if (mounted) {
        setState(() => isSaving = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Ruoli aggiornati con successo'),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Errore nell\'aggiornamento dei ruoli'),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Errore: $e'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Mostra un dialogo di conferma ed elimina definitivamente l'utente
  Future<void> _deleteUserAccount() async {
    // Mostra il popup di conferma
    final bool? confermato = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("⚠️ Conferma Eliminazione"),
          content: Text(
            "Sei sicuro di voler eliminare permanentemente l'account di ${user.name}?\n\nQuesta azione rimuoverà l'utente dal Database e da Keycloak in modo irreversibile.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annulla"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Elimina Definitivamente"),
            ),
          ],
        );
      },
    );

    // Se l'utente annulla, interrompiamo l'esecuzione
    if (confermato != true) return;

    setState(() => isDeleting = true);

    try {
      final success = await _apiService.deleteUser(user.id);

      if (mounted) {
        setState(() => isDeleting = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Utente eliminato con successo da DB e Keycloak'),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 3),
            ),
          );
          // Chiudiamo la pagina corrente tornando alla lista poiché l'utente non esiste più
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Errore durante l\'eliminazione dell\'utente'),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Errore: $e'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Barra di Ricerca
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Cerca utente per nome, email o telefono...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1E66F5),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => searchQuery = ""),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E66F5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
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

                  // Bottoni Azioni
                  Row(
                    children: [
                      // Bottone Salva
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E66F5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: (isSaving || isDeleting) ? null : _saveUserRoles,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            isSaving ? "Salvataggio..." : "Salva Ruoli",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bottone Elimina (Collegato ed ottimizzato)
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: (isSaving || isDeleting) ? null : _deleteUserAccount,
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: Text(
                            isDeleting ? "Eliminazione..." : "Elimina",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
        if (isSaving || isDeleting) return; // Blocca modifiche durante i caricamenti
        setState(() {
          if (!isSelected) {
            user.roles.add(role);
          } else {
            user.roles.remove(role);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? SafeClaimColors.primary : SafeClaimColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.85)
                : SafeClaimColors.primaryLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: SafeClaimColors.primary.withOpacity(0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForRole(role),
              color: isSelected ? Colors.white : SafeClaimColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              cfg.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : SafeClaimColors.textStrong,
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
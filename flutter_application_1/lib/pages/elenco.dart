import 'package:flutter/material.dart';
import 'gestioneut.dart';

/// =====================
/// MODELLI E CONFIG
/// =====================

enum UserRole { perito, automobilista, officina, soccorso, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<UserRole> roles;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roles,
  });
}

class RoleConfig {
  final String label;
  final Color bg;
  final Color text;
  final IconData icon;

  const RoleConfig(this.label, this.bg, this.text, this.icon);
}

// Colori badge simili a Tailwind
final roleConfig = {
  UserRole.perito: RoleConfig(
    "Perito",
    Color(0xFFDBEAFE), // bg-blue-100
    Color(0xFF1E3A8A), // text-blue-800
    Icons.help_outline,
  ),
  UserRole.automobilista: RoleConfig(
    "Automobilista",
    Color(0xFFD1FAE5), // bg-green-100
    Color(0xFF065F46), // text-green-800
    Icons.person,
  ),
  UserRole.officina: RoleConfig(
    "Officina",
    Color(0xFFFFEDD5), // bg-orange-100
    Color(0xFFC2410C), // text-orange-800
    Icons.build,
  ),
  UserRole.soccorso: RoleConfig(
    "Soccorso",
    Color(0xFFEDE9FE), // bg-purple-100
    Color(0xFF6B21A8), // text-purple-800
    Icons.car_crash,
  ),
  UserRole.admin: RoleConfig(
    "Admin",
    Color(0xFFFEE2E2), // bg-red-100
    Color(0xFF991B1B), // text-red-800
    Icons.security,
  ),
};

/// =====================
/// MOCK DATA
/// =====================

final mockUsers = <AppUser>[
  AppUser(
    id: "1",
    name: "Marco Rossi",
    email: "marco.rossi@email.it",
    phone: "+39 333 1234567",
    roles: [UserRole.perito],
  ),
  AppUser(
    id: "2",
    name: "Laura Bianchi",
    email: "laura.bianchi@email.it",
    phone: "+39 333 2345678",
    roles: [UserRole.automobilista],
  ),
  AppUser(
    id: "3",
    name: "Officina Auto Sport",
    email: "info@autosport.it",
    phone: "+39 333 3456789",
    roles: [UserRole.officina, UserRole.soccorso],
  ),
  AppUser(
    id: "4",
    name: "Giuseppe Verdi",
    email: "giuseppe.verdi@email.it",
    phone: "+39 333 4567890",
    roles: [UserRole.soccorso],
  ),
  AppUser(
    id: "5",
    name: "Admin Sistema",
    email: "admin@sistema.it",
    phone: "+39 333 5678901",
    roles: [UserRole.admin],
  ),
];

/// =====================
/// PAGINA ELENCO
/// =====================

class ElencoPage extends StatefulWidget {
  const ElencoPage({super.key});

  @override
  State<ElencoPage> createState() => _ElencoPageState();
}

class _ElencoPageState extends State<ElencoPage> {
  String search = "";
  UserRole? selectedRole;

  List<AppUser> get filteredUsers {
    return mockUsers.where((u) {
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
      backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB), // bg-blue-600
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: const [
            Icon(Icons.people, color: Colors.white),
            SizedBox(width: 8),
            Text("Lista Utenti", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            const SizedBox(height: 16),
            _roleFilter(),
            const SizedBox(height: 12),
            Text(
              "Mostrando ${filteredUsers.length} di ${mockUsers.length} utenti",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
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
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB), // bg-blue-600
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Cerca utente...",
          hintStyle: TextStyle(color: Color(0xFFBFDBFE)),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// =====================
  /// FILTRI RUOLO
  /// =====================

  Widget _roleFilter() {
    return Card(
      color: Colors.white,
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
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                      color: selectedRole == null ? Colors.white : Colors.black),
                ),
                ...UserRole.values.map(
                  (r) {
                    final cfg = roleConfig[r]!;
                    final selected = selectedRole == r;
                    return ChoiceChip(
                      label: Text(cfg.label),
                      selected: selected,
                      onSelected: (_) => setState(() => selectedRole = r),
                      selectedColor: cfg.bg,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? cfg.text : Colors.black,
                      ),
                    );
                  },
                ),
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
    final mainRole = user.roles.first;
    final otherRoles =
        user.roles.length > 1 ? user.roles.sublist(1) : <UserRole>[];
    final config = roleConfig[mainRole]!;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GestioneUtPage(user: user),
          ),
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
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
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
                                fontWeight: FontWeight.w600, fontSize: 15),
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
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...otherRoles.map((role) {
                                      final cfg = roleConfig[role]!;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: cfg.bg,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(cfg.icon, size: 14, color: cfg.text),
                                            const SizedBox(width: 4),
                                            Text(cfg.label,
                                                style: TextStyle(
                                                    fontSize: 12, color: cfg.text)),
                                          ],
                                        ),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: config.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(config.icon, size: 14, color: config.text),
                          const SizedBox(width: 4),
                          Text(
                            config.label,
                            style: TextStyle(color: config.text, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

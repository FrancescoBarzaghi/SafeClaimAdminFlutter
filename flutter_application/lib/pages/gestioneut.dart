import 'package:flutter/material.dart';
import 'elenco.dart';

class GestioneUtPage extends StatefulWidget {
  final AppUser user;

  const GestioneUtPage({super.key, required this.user});

  @override
  State<GestioneUtPage> createState() => _GestioneUtPageState();
}

class _GestioneUtPageState extends State<GestioneUtPage> {
  late AppUser user;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  List<AppUser> get filteredUsers {
    if (searchQuery.isEmpty) {
      return mockUsers;
    }
    return mockUsers.where((u) {
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E66F5),
        title: const Text("Gestione Utenti",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.group, color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("${filteredUsers.length} utenti", style: TextStyle(color: Colors.grey[600])),
            ),
            // Card Utente Selezionato
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Sostituisci con user.imageUrl se presente
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(user.email, 
                            style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          // Badge Attivo / Disattivo Dinamico
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? "Attivo" : "Disattivo", 
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.red, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Seleziona Ruolo", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      onPressed: () {
                        // Logica eliminazione
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Elimina Utente", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Risultati ricerca",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...filteredUsers
                        .where((u) => u.id != user.id)
                        .take(5)
                        .map((u) => GestureDetector(
                              onTap: () => setState(() => user = u),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          'https://via.placeholder.com/150'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(u.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(u.email,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
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
          color: isSelected ? cfg.bg : cfg.bg.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : cfg.bg.withOpacity(0.3),
          ),
          // Ombra super accesa (Glow/Neon)
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cfg.bg,     // Usa il colore pieno del ruolo
                    blurRadius: 16,    // Sfocatura alta per l'effetto alone
                    spreadRadius: 5,   // Espansione fuori dal bottone
                    offset: const Offset(0, 5), // Leggermente verso il basso
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForRole(role),
              color: isSelected ? Colors.white : cfg.bg.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              cfg.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : cfg.bg.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.admin: return Icons.shield_outlined;
      case UserRole.automobilista: return Icons.directions_car_outlined;
      case UserRole.officina: return Icons.build_outlined;
      case UserRole.soccorso: return Icons.local_shipping_outlined;
      case UserRole.perito: return Icons.assignment_outlined;
      default: return Icons.person_outline;
    }
  }
}
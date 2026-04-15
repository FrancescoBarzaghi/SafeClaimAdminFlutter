import 'package:flutter/material.dart';

/// =====================
/// ENUM E CONFIG RUOLI
/// =====================

enum UserRole { perito, automobilista, officina, soccorso, admin, assicuratore, azienda }

/// Converte una stringa di ruolo API al corrispettivo enum
UserRole stringToUserRole(String roleString) {
  switch (roleString.toLowerCase()) {
    case 'perito':
      return UserRole.perito;
    case 'automobilista':
      return UserRole.automobilista;
    case 'officina':
      return UserRole.officina;
    case 'soccorso':
      return UserRole.soccorso;
    case 'admin':
      return UserRole.admin;
    case 'assicuratore':
      return UserRole.assicuratore;
    case 'azienda':
      return UserRole.azienda;
    default:
      return UserRole.automobilista; // Default fallback
  }
}

/// =====================
/// MODELLO UTENTE
/// =====================

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<UserRole> roles;
  final DateTime? registrationDate;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roles,
    this.registrationDate,
  });

  /// Crea un AppUser dai dati dell'API
  factory AppUser.fromApiResponse(Map<String, dynamic> json) {
    final nome = json['nome'] as String? ?? '';
    final cognome = json['cognome'] as String? ?? '';
    final name = '$nome $cognome'.trim();
    
    final rolesRaw = json['ruolo'];
    List<UserRole> roles = [];
    
    if (rolesRaw is List) {
      roles = rolesRaw
          .map((r) => stringToUserRole(r.toString()))
          .toList();
    } else if (rolesRaw is String) {
      roles = [stringToUserRole(rolesRaw)];
    }
    
    if (roles.isEmpty) {
      roles = [UserRole.automobilista]; // Default
    }

    return AppUser(
      id: json['id'].toString(),
      name: name,
      email: json['email'] as String? ?? '',
      phone: json['telefono'] as String? ?? '',
      roles: roles,
      registrationDate: json['data_registrazione'] != null 
        ? DateTime.tryParse(json['data_registrazione'])
        : null,
    );
  }
}

/// =====================
/// CONFIGURAZIONE RUOLI
/// =====================

class RoleConfig {
  final String label;
  final Color bg;
  final Color text;
  final IconData icon;

  const RoleConfig(this.label, this.bg, this.text, this.icon);
}

// Colori badge simili a Tailwind - VERSIONI MOLTO ACCESE
final roleConfig = {
  UserRole.perito: RoleConfig(
    "Perito",
    Color(0xFF1D4ED8), // bg-blue-700 - BLU MOLTO ACCESO
    Color(0xFFFFFFFF), // text-white
    Icons.help_outline,
  ),
  UserRole.automobilista: RoleConfig(
    "Automobilista",
    Color(0xFF15803D), // bg-green-700 - VERDE MOLTO ACCESO
    Color(0xFFFFFFFF), // text-white
    Icons.person,
  ),
  UserRole.officina: RoleConfig(
    "Officina",
    Color(0xFFC2410C), // bg-orange-700 - ARANCIONE MOLTO ACCESO
    Color(0xFFFFFFFF), // text-white
    Icons.build,
  ),
  UserRole.soccorso: RoleConfig(
    "Soccorso",
    Color(0xFF7C3AED), // bg-purple-700 - VIOLA MOLTO ACCESO
    Color(0xFFFFFFFF), // text-white
    Icons.local_taxi,
  ),
  UserRole.admin: RoleConfig(
    "Admin",
    Color(0xFFB91C1C), // bg-red-700 - ROSSO MOLTO ACCESO
    Color(0xFFFFFFFF), // text-white
    Icons.security,
  ),
  UserRole.assicuratore: RoleConfig(
    "Assicuratore",
    Color(0xFF0369A1), // bg-cyan-700 - AZZURRO
    Color(0xFFFFFFFF), // text-white
    Icons.shield,
  ),
  UserRole.azienda: RoleConfig(
    "Azienda",
    Color(0xFF7C2D12), // bg-orange-900 - MARRONE
    Color(0xFFFFFFFF), // text-white
    Icons.business,
  ),
};

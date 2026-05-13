import 'package:flutter/material.dart';

import '../app/theme.dart';

/// =====================
/// ENUM E CONFIG RUOLI
/// =====================

enum UserRole {
  perito,
  automobilista,
  officina,
  soccorso,
  admin,
  assicuratore,
  azienda,
}

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
      roles = rolesRaw.map((r) => stringToUserRole(r.toString())).toList();
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

final Map<UserRole, RoleConfig> roleConfig = {
  UserRole.perito: const RoleConfig(
    "Perito",
    SafeClaimColors.primaryLightest,
    SafeClaimColors.primaryDark,
    Icons.help_outline,
  ),
  UserRole.automobilista: const RoleConfig(
    "Automobilista",
    SafeClaimColors.neutral,
    SafeClaimColors.textStrong,
    Icons.person,
  ),
  UserRole.officina: const RoleConfig(
    "Officina",
    SafeClaimColors.primaryLightest,
    SafeClaimColors.primary,
    Icons.build,
  ),
  UserRole.soccorso: const RoleConfig(
    "Soccorso",
    Color(0x337AB2B2),
    SafeClaimColors.primaryDark,
    Icons.local_taxi,
  ),
  UserRole.admin: const RoleConfig(
    "Admin",
    SafeClaimColors.foreground,
    Colors.white,
    Icons.security,
  ),
  UserRole.assicuratore: const RoleConfig(
    "Assicuratore",
    SafeClaimColors.primaryLightest,
    SafeClaimColors.textStrong,
    Icons.shield,
  ),
  UserRole.azienda: const RoleConfig(
    "Azienda",
    SafeClaimColors.neutral,
    SafeClaimColors.primaryDark,
    Icons.business,
  ),
};

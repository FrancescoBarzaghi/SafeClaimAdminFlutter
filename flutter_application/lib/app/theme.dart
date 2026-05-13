import 'package:flutter/material.dart';

class SafeClaimColors {
  const SafeClaimColors._();

  static const Color primaryDark = Color(0xFF09637E);
  static const Color primary = Color(0xFF088395);
  static const Color primaryLight = Color(0xFF7AB2B2);
  static const Color primaryLightest = Color(0xFFEBF4F6);
  static const Color foreground = Color(0xFF061E29);
  static const Color textStrong = Color(0xFF10546D);
  static const Color textMuted = Color(0xFF5F9598);
  static const Color neutral = Color(0xFFF3F4F4);
  static const Color background = Color(0xFFF4F4F4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFFEDEA);
  static const Color warning = Color(0xFF9A6463);
}

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: SafeClaimColors.primary,
    brightness: Brightness.light,
    primary: SafeClaimColors.primary,
    secondary: SafeClaimColors.primaryLight,
    surface: SafeClaimColors.card,
    error: SafeClaimColors.danger,
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: SafeClaimColors.background,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: SafeClaimColors.foreground,
      displayColor: SafeClaimColors.foreground,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: SafeClaimColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SafeClaimColors.primaryLightest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: SafeClaimColors.textMuted,
      suffixIconColor: SafeClaimColors.textMuted,
      labelStyle: const TextStyle(color: SafeClaimColors.textStrong),
      hintStyle: const TextStyle(color: SafeClaimColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SafeClaimColors.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SafeClaimColors.primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SafeClaimColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SafeClaimColors.danger, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SafeClaimColors.danger, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SafeClaimColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: SafeClaimColors.primaryLight,
        disabledForegroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(46),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SafeClaimColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: SafeClaimColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SafeClaimColors.primaryLight),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: SafeClaimColors.card,
      selectedColor: SafeClaimColors.primary,
      secondarySelectedColor: SafeClaimColors.primaryLightest,
      side: const BorderSide(color: SafeClaimColors.primaryLight),
      labelStyle: const TextStyle(color: SafeClaimColors.textStrong),
      secondaryLabelStyle: const TextStyle(color: SafeClaimColors.textStrong),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: SafeClaimColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: SafeClaimColors.foreground,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: SafeClaimColors.primary,
    ),
    dividerTheme: const DividerThemeData(color: SafeClaimColors.primaryLight),
  );
}

ThemeData darkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: SafeClaimColors.primary,
    brightness: Brightness.dark,
    primary: SafeClaimColors.primaryLight,
    secondary: SafeClaimColors.primary,
    surface: SafeClaimColors.foreground,
    error: SafeClaimColors.danger,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: SafeClaimColors.foreground,
    appBarTheme: const AppBarTheme(
      backgroundColor: SafeClaimColors.primaryDark,
      foregroundColor: Colors.white,
    ),
  );
}

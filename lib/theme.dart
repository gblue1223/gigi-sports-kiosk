import 'package:flutter/material.dart';

abstract final class KioskColors {
  static const green = Color(0xFF2FA866);
  static const greenDark = Color(0xFF1F7A4A);
  static const greenSoft = Color(0xFFE9F5EE);
  static const cream = Color(0xFFF7F4EC);
  static const creamDark = Color(0xFFF1EEE3);
  static const gold = Color(0xFFC9A24B);
  static const black = Color(0xFF15140F);
  static const ink = Color(0xFF1C1D18);
  static const muted = Color(0xFF6B6B62);
  static const subtle = Color(0xFF9A9A8F);
  static const line = Color(0xFFE7E4D8);
  static const danger = Color(0xFFD9534F);
}

ThemeData buildKioskTheme() {
  const radius = 20.0;
  final scheme = ColorScheme.fromSeed(
    seedColor: KioskColors.green,
    primary: KioskColors.green,
    secondary: KioskColors.gold,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: KioskColors.cream,
    fontFamilyFallback: const [
      'Pretendard',
      'Noto Sans KR',
      'Malgun Gothic',
      'Arial',
    ],
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: KioskColors.black,
        fontSize: 42,
        height: 1.16,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      headlineMedium: TextStyle(
        color: KioskColors.black,
        fontSize: 30,
        height: 1.25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(
        color: KioskColors.black,
        fontSize: 23,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        color: KioskColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: KioskColors.ink,
        fontSize: 19,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: KioskColors.muted,
        fontSize: 17,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: KioskColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: KioskColors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: KioskColors.line,
        disabledForegroundColor: KioskColors.subtle,
        minimumSize: const Size(120, 72),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KioskColors.ink,
        minimumSize: const Size(120, 68),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: KioskColors.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: KioskColors.black,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    focusColor: KioskColors.greenSoft,
    splashColor: KioskColors.green.withValues(alpha: 0.10),
  );
}

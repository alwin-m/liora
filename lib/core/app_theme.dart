import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════
//  LIORA BRAND DESIGN SYSTEM
//  Inspired by: Black cat mascot on warm red
// ═══════════════════════════════════════════

class LioraColors {
  // Primary brand — Kitten Pink (playful and cute)
  static const primary = Color(0xFFF9A8D4); // Soft Pink
  static const primaryLight = Color(0xFFFCE7F3); // Very Light Pink
  static const primaryDark = Color(0xFFDB2777); // Deep Pink

  // Kitten Accent Colors
  static const kittenBlue = Color(0xFFBAE6FD); // Baby Blue
  static const kittenMint = Color(0xFFBBF7D0); // Mint Green
  static const kittenCream = Color(0xFFFEF9C3); // Soft Cream

  // Backgrounds — light (Pastel focus)
  static const bgLight = Color(0xFFFFF7F9); // Ultra Light Pinkish White
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFF1F5);

  // Backgrounds — dark (Deep Purple/Pinkish Dark)
  static const bgDark = Color(0xFF1E1116);
  static const surfaceDark = Color(0xFF2D1B22);
  static const cardDark = Color(0xFF3B252D);

  // Cycle-phase accent colors (Softer versions)
  static const periodRed = Color(0xFFFDA4AF); // Soft Rose
  static const periodRedBg = Color(0xFFFFF1F2);
  static const fertileGreen = Color(0xFF86EFAC); // Soft Green
  static const fertileGreenBg = Color(0xFFF0FDF4);
  static const ovulationPurple = Color(0xFFD8B4FE); // Soft Lavender
  static const ovulationPurpleBg = Color(0xFFF5F3FF);

  // Utility & Compatibility
  static const white = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF4C1D24); // Dark Brownish Maroon for softer contrast
  static const textMuted = Color(0xFF9F7279);
  static const divider = Color(0xFFFBCFE8);
  static const catBlack = Color(0xFF1E1116); // Compatibility with old code
}

class LioraTheme {
  // ── Light Theme ──────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: LioraColors.bgLight,
    colorScheme: ColorScheme.light(
      primary: LioraColors.primary,
      onPrimary: LioraColors.white,
      secondary: LioraColors.primaryLight,
      onSecondary: LioraColors.white,
      surface: LioraColors.surfaceLight,
      onSurface: LioraColors.textDark,
      error: LioraColors.primaryDark,
    ),
    textTheme: _buildTextTheme(LioraColors.textDark),
    appBarTheme: AppBarTheme(
      backgroundColor: LioraColors.bgLight,
      foregroundColor: LioraColors.textDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: LioraColors.primaryDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LioraColors.primary,
        foregroundColor: LioraColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LioraColors.primary,
        side: const BorderSide(color: LioraColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LioraColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: LioraColors.textMuted,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LioraColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LioraColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LioraColors.primary, width: 1.8),
      ),
      prefixIconColor: LioraColors.textMuted,
      suffixIconColor: LioraColors.primary,
    ),
    cardTheme: CardThemeData(
      color: LioraColors.surfaceLight,
      elevation: 6,
      shadowColor: LioraColors.primary.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? LioraColors.primary
            : Colors.grey.shade400,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? LioraColors.primary.withOpacity(0.4)
            : Colors.grey.shade300,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: LioraColors.primary,
      inactiveTrackColor: LioraColors.divider,
      thumbColor: LioraColors.primary,
      overlayColor: LioraColors.primary.withOpacity(0.2),
      trackHeight: 5,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: LioraColors.primary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: LioraColors.catBlack,
      contentTextStyle: GoogleFonts.poppins(
        color: LioraColors.white,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: LioraColors.surfaceLight,
    ),
    dividerTheme: const DividerThemeData(
      color: LioraColors.divider,
      thickness: 1,
    ),
  );

  // ── Dark Theme ────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: LioraColors.bgDark,
    colorScheme: ColorScheme.dark(
      primary: LioraColors.primary,
      onPrimary: LioraColors.white,
      secondary: LioraColors.primaryLight,
      onSecondary: LioraColors.white,
      surface: LioraColors.surfaceDark,
      onSurface: LioraColors.white,
      error: LioraColors.primaryLight,
    ),
    textTheme: _buildTextTheme(LioraColors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: LioraColors.bgDark,
      foregroundColor: LioraColors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: LioraColors.primaryLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LioraColors.primary,
        foregroundColor: LioraColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LioraColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LioraColors.primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LioraColors.primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LioraColors.primary, width: 1.8),
      ),
      prefixIconColor: Colors.white54,
      suffixIconColor: LioraColors.primaryLight,
    ),
    cardTheme: CardThemeData(
      color: LioraColors.cardDark,
      elevation: 6,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? LioraColors.primary
            : Colors.grey.shade600,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? LioraColors.primary.withOpacity(0.4)
            : Colors.grey.shade800,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: LioraColors.primary,
      inactiveTrackColor: LioraColors.surfaceDark,
      thumbColor: LioraColors.primary,
      overlayColor: LioraColors.primary.withOpacity(0.2),
      trackHeight: 5,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: LioraColors.primary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: LioraColors.surfaceDark,
      contentTextStyle: GoogleFonts.poppins(
        color: LioraColors.white,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: LioraColors.surfaceDark,
    ),
    dividerTheme: DividerThemeData(
      color: LioraColors.primary.withOpacity(0.2),
      thickness: 1,
    ),
  );

  static TextTheme _buildTextTheme(Color base) => TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: base,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: base,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: base,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: base,
    ),
    bodyLarge: GoogleFonts.poppins(fontSize: 15, color: base),
    bodyMedium: GoogleFonts.poppins(fontSize: 13, color: base),
    bodySmall: GoogleFonts.poppins(fontSize: 12, color: base.withOpacity(0.7)),
    labelLarge: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: LioraColors.primary,
    ),
  );
}

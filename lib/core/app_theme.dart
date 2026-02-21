import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Liora Luxury Minimalism Design System
/// Designed for psychological safety, trust, and premium comfort.
class LioraTheme {
  LioraTheme._();

  // ── Luxury Color Pavilion ──────────────────────────────────────
  static const Color blushRose = Color(0xFFF7C8D0); // Primary
  static const Color lavenderMuted = Color(0xFFE6E6FA); // Secondary
  static const Color coralSoft = Color(0xFFFFB3A7); // Accent
  static const Color sageGreen = Color(0xFFCFE8D5); // Success/Ovulation
  static const Color roseRedMuted = Color(0xFFE89CA9); // Warning/Period
  static const Color offWhiteWarm = Color(0xFFFAFAFA); // Background Base
  static const Color pureWhite = Color(0xFFFFFFFF); // Cards/Sections

  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF7A7A7A);

  // ── Geometry & Space ──────────────────────────────────────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusCard = 20;
  static const double radiusDialog = 24;
  static const double radiusSheet = 32;

  static const double spaceLarge = 24;
  static const double spaceMedium = 16;
  static const double spaceSmall = 8;

  // ── Motion ────────────────────────────────────────────────────
  static const Duration durationStandard = Duration(milliseconds: 300);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 450);

  static const Curve curveSoft = Curves.easeInOutCubic;
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  // ── Typography ────────────────────────────────────────────────
  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme();
    final display = GoogleFonts.playfairDisplayTextTheme();

    return base.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(color: textPrimary),
      labelLarge: base.labelLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Theme Construction ────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: blushRose,
      onPrimary: textPrimary,
      secondary: lavenderMuted,
      onSecondary: textPrimary,
      tertiary: coralSoft,
      surface: offWhiteWarm,
      onSurface: textPrimary,
      error: roseRedMuted,
      outlineVariant: lavenderMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: offWhiteWarm,

      appBarTheme: AppBarTheme(
        backgroundColor: offWhiteWarm,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        shadowColor: Colors.black.withAlpha(15),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blushRose,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: blushRose, width: 1.5),
        ),
        hintStyle: TextStyle(color: textSecondary.withAlpha(120)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: pureWhite,
        modalBackgroundColor: pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusSheet),
          ),
        ),
        elevation: 2,
      ),

      dividerTheme: DividerThemeData(
        color: textSecondary.withAlpha(30),
        thickness: 1,
      ),
    );
  }
}

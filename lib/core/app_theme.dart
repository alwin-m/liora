import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Liora — Performance-optimized Design System
/// Adaptive gradient theme with dark/light support.
/// All costs are computed once and cached as static constants.
class LioraTheme {
  LioraTheme._();

  // ── Luxury Color Pavilion ──────────────────────────────────────
  static const Color blushRose = Color(0xFFF7C8D0); // Primary
  static const Color blushRoseDark = Color(0xFFD4707F); // Primary Dark (deep)
  static const Color lavenderMuted = Color(0xFFE6E6FA); // Secondary
  static const Color coralSoft = Color(0xFFFFB3A7); // Accent
  static const Color sageGreen = Color(0xFFCFE8D5); // Success/Ovulation
  static const Color roseRedMuted = Color(0xFFE89CA9); // Warning/Period
  static const Color offWhiteWarm = Color(0xFFFAFAFA); // Light Background
  static const Color pureWhite = Color(0xFFFFFFFF); // Cards/Sections
  static const Color surfaceDark = Color(0xFF1C1520); // Dark Scaffold
  static const Color cardDark = Color(0xFF26202B); // Dark Card
  static const Color cardDarkElevated = Color(0xFF2E2636); // Dark Elevated Card

  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textPrimaryDark = Color(0xFFF0ECF4);
  static const Color textSecondaryDark = Color(0xFFB0A8BA);

  // ── Luxury Calendar Palette ──────────────────────────────────
  static const Color calendarBgIvoryMist = Color(0xFFF6F1EB);
  static const Color calendarBgDark = Color(0xFF221B27);
  static const Color calendarTextCharcoalPlum = Color(0xFF342A33);
  static const Color calendarBleedingRoyalBerry = Color(0xFFB04A5A);
  static const Color calendarOvulationSageEmerald = Color(0xFF7FA88B);
  static const Color calendarFertileSoftChampagne = Color(0xFFC9DDD3);
  static const Color calendarTodayRoyalMauve = Color(0xFFD8C3A5);

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

  // ── Motion (hardware-accelerated, capped at 300ms) ─────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 220);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 300);

  static const Curve curveSoft = Curves.easeInOutCubic;
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  // ── Typography ────────────────────────────────────────────────
  static TextTheme _buildTextTheme({required bool dark}) {
    final color = dark ? textPrimaryDark : textPrimary;
    final secondary = dark ? textSecondaryDark : textSecondary;
    final base = GoogleFonts.interTextTheme();
    final display = GoogleFonts.playfairDisplayTextTheme();

    return base.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: color),
      bodyMedium: base.bodyMedium?.copyWith(color: color),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(color: secondary),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: blushRose,
      onPrimary: textPrimary,
      secondary: lavenderMuted,
      onSecondary: textPrimary,
      tertiary: coralSoft,
      surface: offWhiteWarm,
      onSurface: textPrimary,
      error: roseRedMuted,
      outlineVariant: lavenderMuted,
      surfaceContainerHighest: Color(0xFFEDE8F2),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffold: offWhiteWarm,
      card: pureWhite,
      dark: false,
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: blushRoseDark,
      onPrimary: pureWhite,
      secondary: Color(0xFF7A78A8),
      onSecondary: pureWhite,
      tertiary: Color(0xFFAF7070),
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      error: Color(0xFFCF6679),
      outlineVariant: Color(0xFF3D3347),
      surfaceContainerHighest: Color(0xFF2A2333),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffold: surfaceDark,
      card: cardDark,
      dark: true,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffold,
    required Color card,
    required bool dark,
  }) {
    final textTheme = _buildTextTheme(dark: dark);
    final onSurface = dark ? textPrimaryDark : textPrimary;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffold,

      // Page transition optimization
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(
            allowEnterRouteSnapshotting: false,
          ),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        shadowColor: Colors.black.withAlpha(dark ? 30 : 15),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? cardDarkElevated : pureWhite,
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
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: (dark ? textSecondaryDark : textSecondary).withAlpha(120),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? cardDark : pureWhite,
        modalBackgroundColor: dark ? cardDark : pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusSheet),
          ),
        ),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: (dark ? textSecondaryDark : textSecondary).withAlpha(30),
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        backgroundColor: dark ? cardDarkElevated : const Color(0xFF2D2030),
        contentTextStyle: GoogleFonts.inter(color: pureWhite, fontSize: 13),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? (dark ? blushRoseDark : blushRose)
              : colorScheme.surfaceContainerHighest,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? (dark ? blushRoseDark : blushRose).withAlpha(80)
              : colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

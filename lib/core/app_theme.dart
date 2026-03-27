import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Liora — Luxury Minimal Design System (White Mode Only)
///
/// Design Philosophy:
///   Safe, private, elegant, emotionally supportive.
///   Feels like an Apple-designed menstrual wellness app —
///   calm, emotionally intelligent, minimalist, luxurious, deeply personal.
///
/// Color Strategy:
///   80% neutral off-white / cream base
///   15% muted primary brand tone (Rose Clay)
///   5%  accent color for emotional highlights
///
/// No dark mode. No harsh saturation. Tonal layering over color blocks.
class LioraTheme {
  LioraTheme._();

  // ── Base / Background Colors ──────────────────────────────────
  /// Primary background — warm off-white, never pure white or grey
  static const Color primaryBackground = Color(0xFFFAF7F5);

  /// Secondary background — slightly deeper warmth for sections
  static const Color secondaryBackground = Color(0xFFF2ECE8);

  /// Card surfaces — pure white for elevation contrast
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Subtle section divider — gentle warm separator
  static const Color sectionDivider = Color(0xFFE8DFD9);

  // ── Primary Brand Color ───────────────────────────────────────
  /// Muted Rose Clay — warmth, femininity, safety, emotional softness
  static const Color roseClay = Color(0xFFC58C85);

  /// Rose Clay light variant for subtle backgrounds
  static const Color roseClayLight = Color(0xFFE6C5C0);

  /// Rose Clay dark variant for pressed states
  static const Color roseClayDark = Color(0xFFAA706A);

  // ── Secondary Brand Color ─────────────────────────────────────
  /// Dusty Mauve — calm introspection, hormonal balance feeling
  static const Color dustyMauve = Color(0xFFBFA2C7);

  /// Dusty Mauve light for prediction tints
  static const Color dustyMauveLight = Color(0xFFDFCFE3);

  // ── Trust Accent Color ────────────────────────────────────────
  /// Soft Sage — healing, stability, reassurance, natural rhythm
  static const Color softSage = Color(0xFFA8C3A0);

  /// Soft Sage light for subtle backgrounds
  static const Color softSageLight = Color(0xFFD4E4D0);

  // ── Highlight Color ───────────────────────────────────────────
  /// Champagne Beige — subtle hover, calendar highlights
  static const Color champagneBeige = Color(0xFFE6CFC4);

  // ── Text Colors ───────────────────────────────────────────────
  /// Primary text — deep warm charcoal, never pure black
  static const Color textPrimary = Color(0xFF3E3A39);

  /// Secondary text — muted warm grey for supporting content
  static const Color textSecondary = Color(0xFF6B6461);

  /// Tertiary text — lightest readable warm grey
  static const Color textTertiary = Color(0xFF9A908C);

  // ── Functional Colors ─────────────────────────────────────────
  /// Error — desaturated warm coral, not bright red
  static const Color errorColor = Color(0xFFD88C8C);

  /// Success — soft sage (reuse trust accent)
  static const Color successColor = softSage;

  // ── Calendar Palette (Emotional Color Psychology) ─────────────
  /// Calendar background — warm ivory
  static const Color calendarBackground = Color(0xFFFFFCFA);

  /// Calendar text — charcoal plum
  static const Color calendarText = Color(0xFF3E3A39);

  /// Period / Bleeding days — Rose Clay with 20% transparency feel
  static const Color calendarPeriod = Color(0xFFC58C85);

  /// Ovulation day — Dusty Mauve with 15% transparency feel
  static const Color calendarOvulation = Color(0xFFBFA2C7);

  /// Fertile window — Soft Sage gradient base
  static const Color calendarFertile = Color(0xFFD4E4D0);

  /// Today indicator — Champagne Beige ring
  static const Color calendarToday = Color(0xFFD4B5A7);

  /// Selected day — Rose Clay filled
  static const Color calendarSelected = Color(0xFFC58C85);

  // ── Geometry & Space ──────────────────────────────────────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  /// Luxury minimal methodology: 18px rounded corners for softness
  static const double radiusSmall = 14;
  static const double radiusMedium = 18;
  static const double radiusCard = 22;
  static const double radiusDialog = 26;
  static const double radiusSheet = 32;

  static const double spaceLarge = 24;
  static const double spaceMedium = 16;
  static const double spaceSmall = 8;

  // ── Warm Shadow ───────────────────────────────────────────────
  /// Warm shadow color (rgba(197, 140, 133, 0.08))
  static const Color warmShadow = Color(0x14C58C85);

  // ── Motion (soft fade transitions, 250ms ease-in-out) ─────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 220);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 300);

  static const Curve curveSoft = Curves.easeInOutCubic;
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  // ── Typography ────────────────────────────────────────────────
  static TextTheme _buildTextTheme() {
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
      headlineSmall: base.headlineSmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(color: textPrimary),
      bodySmall: base.bodySmall?.copyWith(color: textSecondary),
      labelLarge: base.labelLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(color: textSecondary),
    );
  }

  // ── Light Theme (the only theme) ─────────────────────────────
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: roseClay,
      onPrimary: Colors.white,
      secondary: dustyMauve,
      onSecondary: Colors.white,
      tertiary: softSage,
      surface: primaryBackground,
      onSurface: textPrimary,
      error: errorColor,
      onError: Colors.white,
      outlineVariant: sectionDivider,
      surfaceContainerHighest: secondaryBackground,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: primaryBackground,
      brightness: Brightness.light,

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
        backgroundColor: primaryBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        shadowColor: warmShadow,
      ),

      // Primary buttons: Rose Clay background with white text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: roseClay,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      // Secondary buttons: Outlined with Rose Clay border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: roseClay, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
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
          borderSide: const BorderSide(color: roseClay, width: 1.5),
        ),
        hintStyle: TextStyle(color: textTertiary.withAlpha(120)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBackground,
        modalBackgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusSheet),
          ),
        ),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: sectionDivider.withAlpha(80),
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      ),

      // Profile toggle: Soft Sage active, beige-grey inactive
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? softSage
              : secondaryBackground,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? softSage.withAlpha(80)
              : secondaryBackground,
        ),
      ),

      // Date picker theme to match palette
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cardBackground,
        headerBackgroundColor: roseClay,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : textPrimary,
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? roseClay : null,
        ),
        todayForegroundColor: WidgetStateProperty.all(roseClay),
        todayBorder: const BorderSide(color: roseClay),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDialog),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDialog),
        ),
        elevation: 4,
        shadowColor: warmShadow,
      ),

      // FilledButton tonal
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: roseClayLight,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: roseClay,
        linearTrackColor: secondaryBackground,
      ),
    );
  }

  // ── Legacy Aliases (backward compatibility) ───────────────────
  // These map old names to new design tokens for files not yet migrated.
  @Deprecated('Use roseClay instead')
  static const Color blushRose = roseClay;
  @Deprecated('Use roseClayDark instead')
  static const Color blushRoseDark = roseClayDark;
  @Deprecated('Use dustyMauveLight instead')
  static const Color lavenderMuted = dustyMauveLight;
  @Deprecated('Use champagneBeige instead')
  static const Color coralSoft = champagneBeige;
  @Deprecated('Use softSageLight instead')
  static const Color sageGreen = softSageLight;
  @Deprecated('Use errorColor instead')
  static const Color roseRedMuted = errorColor;
  @Deprecated('Use primaryBackground instead')
  static const Color offWhiteWarm = primaryBackground;
  @Deprecated('Use cardBackground instead')
  static const Color pureWhite = cardBackground;

  // Calendar legacy aliases
  @Deprecated('Use calendarBackground instead')
  static const Color calendarBgIvoryMist = calendarBackground;
  @Deprecated('Use calendarText instead')
  static const Color calendarTextCharcoalPlum = calendarText;
  @Deprecated('Use calendarPeriod instead')
  static const Color calendarBleedingRoyalBerry = calendarPeriod;
  @Deprecated('Use calendarOvulation instead')
  static const Color calendarOvulationSageEmerald = calendarOvulation;
  @Deprecated('Use calendarFertile instead')
  static const Color calendarFertileSoftChampagne = calendarFertile;
  @Deprecated('Use calendarToday instead')
  static const Color calendarTodayRoyalMauve = calendarToday;

  // Dark-only fields removed — no dark mode
  @Deprecated('Dark mode removed — use primaryBackground')
  static const Color surfaceDark = primaryBackground;
  @Deprecated('Dark mode removed — use cardBackground')
  static const Color cardDark = cardBackground;
  @Deprecated('Dark mode removed — use cardBackground')
  static const Color cardDarkElevated = cardBackground;
  @Deprecated('Dark mode removed — use textPrimary')
  static const Color textPrimaryDark = textPrimary;
  @Deprecated('Dark mode removed — use textSecondary')
  static const Color textSecondaryDark = textSecondary;
  @Deprecated('Dark mode removed — use calendarBackground')
  static const Color calendarBgDark = calendarBackground;
}

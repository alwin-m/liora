import 'package:flutter/material.dart';

/// Android 16-Inspired Design System
/// Minimal, calm, iOS-smooth visual language
class AppTheme {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COLOR SYSTEM (Material You Adaptive)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Primary palette - Warm, calm tones
  static const Color primary = Color(0xFFD64B76); // Soft rose
  static const Color primaryLight = Color(0xFFEA94AC);
  static const Color primaryDark = Color(0xFFB8346B);

  // System colors - Low contrast, soft tones
  static const Color surface = Color(0xFFFAFAFA); // Almost white
  static const Color surfaceContainer = Color(0xFFF3F3F3);
  static const Color surfaceContainerHigh = Color(0xFFEEEEEE);

  // Text colors - High readability, soft opacity
  static const Color textPrimary = Color(0xFF1A1A1A); // Near black, not harsh
  static const Color textSecondary = Color(0xFF6B6B6B); // Soft gray
  static const Color textTertiary = Color(0xFFB0B0B0); // Light gray

  // Accent colors - Used sparingly
  static const Color accent = Color(0xFF7C3AED); // Gentle purple
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color success = Color(0xFF10B981); // Soft green
  static const Color warning = Color(0xFFF59E0B); // Soft amber
  static const Color error = Color(0xFFEF4444); // Soft red

  // Backgrounds
  static const Color background = Color(0xFFFEFEFE);
  static const Color scrim = Color(0x00000000); // Transparent

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SPACING SYSTEM
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BORDER RADIUS (Soft, organic curves)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Radius radiusSm = Radius.circular(8);
  static const Radius radiusMd = Radius.circular(16);
  static const Radius radiusLg = Radius.circular(24);
  static const Radius radiusXl = Radius.circular(32);

  static const BorderRadius roundedSm = BorderRadius.all(radiusSm);
  static const BorderRadius roundedMd = BorderRadius.all(radiusMd);
  static const BorderRadius roundedLg = BorderRadius.all(radiusLg);
  static const BorderRadius roundedXl = BorderRadius.all(radiusXl);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ELEVATION & SHADOW (Soft diffusion, not harsh)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MOTION CURVES (Calm, smooth, iOS-like)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Curve easeOutSmooth = Curves.easeOutCubic;
  static const Curve easeInOutSmooth = Curves.easeInOutCubic;

  static const Duration durationXs = Duration(milliseconds: 150);
  static const Duration durationSm = Duration(milliseconds: 250);
  static const Duration durationMd = Duration(milliseconds: 400);
  static const Duration durationLg = Duration(milliseconds: 600);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TYPOGRAPHY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
    color: textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
    color: textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.5,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.5,
    color: textTertiary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
    color: textSecondary,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // THEME DATA
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: roundedMd),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: lg,
          vertical: lg,
        ),
        border: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: bodyMedium,
        hintStyle: bodySmall.copyWith(color: textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: xl,
            vertical: lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: roundedMd),
          textStyle: labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: xl,
            vertical: lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: roundedMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: labelLarge,
        ),
      ),
      iconTheme: const IconThemeData(color: primary),
      dividerColor: surfaceContainerHigh,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
    );
  }
}

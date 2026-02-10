import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LIORA Color Palette - Calm, feminine, emotionally safe
class LioraColors {
  LioraColors._();

  // Primary Colors
  static const Color primaryPink = Color(0xFFFDE2EA);
  static const Color backgroundWhite = Color(0xFFFFF6F9);
  static const Color accentRose = Color(0xFFF7B2C4);
  static const Color deepRose = Color(0xFFE8849A);

  // Semantic Colors for Calendar
  static const Color periodDay = Color(0xFFFFB5C2); // Soft Rose - Period days
  static const Color fertileWindow =
      Color(0xFFE8D5F2); // Lavender - Fertile window
  static const Color predictedPeriod =
      Color(0xFFFFCDD2); // Light Coral - Predicted period
  static const Color ovulationDay =
      Color(0xFFD4B5FF); // Soft Purple - Ovulation

  // Text Colors
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textOnPink = Color(0xFF5C4A50);

  // UI Elements
  static const Color shadow = Color(0x14000000);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFF5E6EA);
  static const Color inputBackground = Color(0xFFFFF0F3);
  static const Color inputBorder = Color(0xFFFFD6E0);

  // Status Colors (Gentle)
  static const Color success = Color(0xFFA8E6CF);
  static const Color warning = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFFFCDD2);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF6F9), Color(0xFFFDE2EA)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF8FA)],
  );
}

/// LIORA Text Styles - Using Google Fonts for proper font loading
class LioraTextStyles {
  LioraTextStyles._();

  // Headings - Using Outfit font
  static TextStyle get h1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: LioraColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: LioraColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: LioraColors.textPrimary,
      );

  // Body Text - Using Inter font
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: LioraColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: LioraColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: LioraColors.textMuted,
        height: 1.4,
      );

  // Labels - Using Outfit font
  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: LioraColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: LioraColors.textSecondary,
        letterSpacing: 0.2,
      );

  // Button Text
  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: LioraColors.textPrimary,
        letterSpacing: 0.5,
      );

  // Calendar
  static TextStyle get calendarDay => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: LioraColors.textPrimary,
      );

  static TextStyle get calendarHeader => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: LioraColors.textPrimary,
      );
}

/// LIORA Theme Configuration
class LioraTheme {
  LioraTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LioraColors.backgroundWhite,
      primaryColor: LioraColors.accentRose,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: LioraColors.accentRose,
        secondary: LioraColors.deepRose,
        surface: LioraColors.cardBackground,
        error: LioraColors.error,
        onPrimary: LioraColors.textPrimary,
        onSecondary: Colors.white,
        onSurface: LioraColors.textPrimary,
        onError: LioraColors.textPrimary,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: LioraTextStyles.h3,
        iconTheme: const IconThemeData(color: LioraColors.textPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: LioraColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: LioraColors.shadow,
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LioraColors.accentRose,
          foregroundColor: LioraColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: LioraTextStyles.button,
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LioraColors.deepRose,
          textStyle: LioraTextStyles.label,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LioraColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: LioraColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LioraColors.accentRose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LioraColors.error, width: 1),
        ),
        labelStyle: LioraTextStyles.label,
        hintStyle:
            LioraTextStyles.bodyMedium.copyWith(color: LioraColors.textMuted),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LioraColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: LioraColors.divider,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: LioraColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: LioraTextStyles.h3,
        contentTextStyle: LioraTextStyles.bodyMedium,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: LioraColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Shadow Styles
class LioraShadows {
  LioraShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: LioraColors.shadow,
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: LioraColors.shadow.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: LioraColors.accentRose.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ];
}

/// Border Radius Constants
class LioraRadius {
  LioraRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double round = 100;
}

/// Spacing Constants
class LioraSpacing {
  LioraSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

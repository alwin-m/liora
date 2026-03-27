import 'package:flutter/material.dart';

/// Liora is White Mode Only — luxury minimal design.
/// This provider is kept for compatibility but forces light mode.
class ThemeProvider with ChangeNotifier {
  // Always light mode — no dark mode per design system
  ThemeMode get themeMode => ThemeMode.light;

  bool get isDark => false;

  ThemeProvider();

  /// No-op: dark mode is disabled in the luxury minimal design system.
  Future<void> setMode(ThemeMode mode) async {
    // Force light mode always
    notifyListeners();
  }

  /// No-op: dark mode toggle disabled.
  Future<void> toggleDark() async {
    // Intentionally empty — white mode only
  }
}

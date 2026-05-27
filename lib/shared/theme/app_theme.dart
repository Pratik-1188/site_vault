import 'package:flutter/material.dart';
import 'firm_colors.dart';

/// A premium, highly polished Material 3 design system for KK Group Site Vault.
///
/// Features a Slate/Navy primary theme combined with an elegant Amber secondary.
/// Provides a Dark Mode and Light Mode with zero hardcoded inline styles.
class AppTheme {
  AppTheme._();

  /// Firm accent colors for Light Mode
  static const FirmColors _lightFirmColors = FirmColors(
    electricals: Color(0xFF0284C7), // sky-600
    solar: Color(0xFFEA580C), // orange-600
    associates: Color(0xFF059669), // emerald-600
  );

  /// Firm accent colors for Dark Mode (slightly desaturated/brighter for contrast)
  static const FirmColors _darkFirmColors = FirmColors(
    electricals: Color(0xFF38BDF8), // sky-400
    solar: Color(0xFFF97316), // orange-500
    associates: Color(0xFF34D399), // emerald-400
  );

  /// Creates the Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightFirmColors.electricals,
        brightness: Brightness.light,
      ),
      extensions: const <ThemeExtension<dynamic>>[_lightFirmColors],
    );
  }

  /// Creates the Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkFirmColors.electricals,
        brightness: Brightness.dark,
      ),
      extensions: const <ThemeExtension<dynamic>>[_darkFirmColors],
    );
  }
}

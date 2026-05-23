import 'package:flutter/material.dart';
import 'firm_colors.dart';

/// A premium, highly polished Material 3 design system for KK Group Site Vault.
///
/// Features a Slate/Navy primary theme combined with an elegant Amber secondary.
/// Provides a Dark Mode and Light Mode with zero hardcoded inline styles.
class AppTheme {
  AppTheme._();

  // Primary colors
  static const Color _lightPrimary = Color(0xFF0F172A); // Slate 900
  static const Color _lightSecondary = Color(0xFFD97706); // Amber 600
  static const Color _lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFE2E8F0); // Slate 200

  static const Color _darkPrimary = Color(0xFF38BDF8); // Sky 400
  static const Color _darkSecondary = Color(0xFFFBBF24); // Amber 400
  static const Color _darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color _darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color _darkBorder = Color(0xFF334155); // Slate 700

  /// Firm accent colors for Light Mode
  static const FirmColors _lightFirmColors = FirmColors(
    electricals: Color(0xFF0284C7), // sky-600
    solar: Color(0xFFEA580C),       // orange-600
    associates: Color(0xFF059669),  // emerald-600
  );

  /// Firm accent colors for Dark Mode (slightly desaturated/brighter for contrast)
  static const FirmColors _darkFirmColors = FirmColors(
    electricals: Color(0xFF38BDF8), // sky-400
    solar: Color(0xFFF97316),       // orange-500
    associates: Color(0xFF34D399),  // emerald-400
  );

  /// Standard border radius values for consistency
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  /// Creates the Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        primary: _lightPrimary,
        secondary: _lightSecondary,
        surface: _lightBackground,
        outline: _lightBorder,
      ),
      scaffoldBackgroundColor: _lightBackground,

      // Typography
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
          color: _lightPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: _lightPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: Color(0xFF334155), // Slate 700
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: Color(0xFF475569), // Slate 600
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),

      // App Bar styling
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: _lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _lightBorder,
        iconTheme: IconThemeData(color: _lightPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _lightPrimary,
        ),
      ),

      // Card styling
      cardTheme: const CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _lightBorder, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
      ),

      // Text Fields (Input) styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F5F9), // Slate 100
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: _lightPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF94A3B8), // Slate 400
        ),
      ),

      // Selection Chips styling
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFFF1F5F9), // Slate 100
        disabledColor: Color(0xFFE2E8F0),
        selectedColor: _lightPrimary.withValues(alpha: 0.08),
        secondarySelectedColor: _lightPrimary.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          side: BorderSide(color: Colors.transparent),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569), // Slate 600
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _lightPrimary,
        ),
      ),

      // Buttons styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Extensions
      extensions: const <ThemeExtension<dynamic>>[
        _lightFirmColors,
      ],
    );
  }

  /// Creates the Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimary,
        brightness: Brightness.dark,
        primary: _darkPrimary,
        secondary: _darkSecondary,
        surface: _darkBackground,
        outline: _darkBorder,
      ),
      scaffoldBackgroundColor: _darkBackground,

      // Typography
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: Color(0xFFCBD5E1), // Slate 300
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: Color(0xFF94A3B8), // Slate 400
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),

      // App Bar styling
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: _darkSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card styling
      cardTheme: const CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _darkBorder, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
      ),

      // Text Fields (Input) styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: _darkPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B), // Slate 500
        ),
      ),

      // Selection Chips styling
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurface,
        disabledColor: Color(0xFF1E293B),
        selectedColor: _darkPrimary.withValues(alpha: 0.15),
        secondarySelectedColor: _darkPrimary.withValues(alpha: 0.25),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          side: BorderSide(color: Colors.transparent),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8), // Slate 400
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Buttons styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _darkBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Extensions
      extensions: const <ThemeExtension<dynamic>>[
        _darkFirmColors,
      ],
    );
  }
}

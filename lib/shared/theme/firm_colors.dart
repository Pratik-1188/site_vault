import 'package:flutter/material.dart';

/// A [ThemeExtension] to provide clean, consistent visual cues for the
/// three distinct firms in the KK Group.
///
/// This avoids local color hardcoding and keeps styling strictly in the theme.
class FirmColors extends ThemeExtension<FirmColors> {
  final Color electricals;
  final Color solar;
  final Color associates;

  const FirmColors({
    required this.electricals,
    required this.solar,
    required this.associates,
  });

  @override
  FirmColors copyWith({
    Color? electricals,
    Color? solar,
    Color? associates,
  }) {
    return FirmColors(
      electricals: electricals ?? this.electricals,
      solar: solar ?? this.solar,
      associates: associates ?? this.associates,
    );
  }

  @override
  FirmColors lerp(ThemeExtension<FirmColors>? other, double t) {
    if (other is! FirmColors) return this;
    return FirmColors(
      electricals: Color.lerp(electricals, other.electricals, t)!,
      solar: Color.lerp(solar, other.solar, t)!,
      associates: Color.lerp(associates, other.associates, t)!,
    );
  }

  /// Maps a firm name or UUID to its corresponding brand color
  Color getFirmColor(String firmIdOrName) {
    final key = firmIdOrName.toLowerCase();
    
    // Check by standard hardcoded IDs from setup/seed or names
    if (key.contains('electricals') || key.contains('0f140f6f')) {
      return electricals;
    } else if (key.contains('solar') || key.contains('4e01a36a')) {
      return solar;
    } else if (key.contains('associates') || key.contains('169eceeb')) {
      return associates;
    }
    
    // Default fallback (first firm)
    return electricals;
  }

  /// Maps a firm name or UUID to a light background version of its brand color
  /// useful for soft card surfaces, borders, or chip backgrounds.
  Color getFirmSurfaceColor(String firmIdOrName, bool isDarkMode) {
    final baseColor = getFirmColor(firmIdOrName);
    return isDarkMode 
        ? baseColor.withValues(alpha: 0.15) 
        : baseColor.withValues(alpha: 0.08);
  }
}

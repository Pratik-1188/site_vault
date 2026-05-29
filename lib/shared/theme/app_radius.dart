import 'package:flutter/material.dart';

/// Centralized border radius design tokens for the application.
/// Provides a consistent, modular visual language across all features.
abstract final class AppRadius {
  /// Extra small radius (4.0) - ideal for badges, small cards, and internal item elements.
  static const double xs = 4.0;
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));

  /// Small radius (8.0) - ideal for bento grids, main cards, text fields, and selectors.
  static const double sm = 8.0;
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));

  /// Medium radius (12.0) - ideal for bottom sheets and large container elements.
  static const double md = 12.0;
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));

  /// Large radius (16.0)
  static const double lg = 16.0;
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));

  /// Extra large radius (24.0)
  static const double xl = 24.0;
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));

  /// Vertical configurations specifically optimized for sheet headers
  static const BorderRadius verticalSm = BorderRadius.vertical(top: Radius.circular(sm));
  static const BorderRadius verticalMd = BorderRadius.vertical(top: Radius.circular(md));
  static const BorderRadius verticalLg = BorderRadius.vertical(top: Radius.circular(lg));
}

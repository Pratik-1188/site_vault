import 'package:flutter/material.dart';

/// Centralized padding design tokens for the application.
/// Provides a consistent, modular visual language across all features.
abstract final class AppPadding {
  /// Bottom sheet header padding: `EdgeInsets.fromLTRB(24, 16, 24, 0)`
  static const EdgeInsets sheetHeader = EdgeInsets.fromLTRB(24, 16, 24, 0);

  /// Bottom sheet body padding: `EdgeInsets.fromLTRB(24, 0, 24, 24)`
  static const EdgeInsets sheetBody = EdgeInsets.fromLTRB(24, 0, 24, 24);

  /// Panel padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`
  static const EdgeInsets panel = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Search/filter row padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`
  static const EdgeInsets searchFilterRow = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
}

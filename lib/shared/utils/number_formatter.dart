import 'package:flutter/material.dart';

/// A lightweight numeric and currency formatting utility for KK Group Site Vault.
///
/// Keeps formatting clean and consistent across the UI without bringing in
/// heavy external dependencies like 'intl' if only basic formatting is needed.
extension NumberFormatter on num {
  /// Formats the number as Indian Rupee currency (e.g. ₹12,34,567.89).
  /// Standardizes on the rupee symbol '₹', 2 decimal places, and Indian numbering grouping.
  String toCurrency() {
    final isNegative = this < 0;
    final absoluteValue = abs();
    
    // Split into integer and decimal parts
    final parts = absoluteValue.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '.00';
    
    // Apply Indian grouping
    String formattedInteger;
    if (integerPart.length <= 3) {
      formattedInteger = integerPart;
    } else {
      final lastThree = integerPart.substring(integerPart.length - 3);
      final remaining = integerPart.substring(0, integerPart.length - 3);
      
      final List<String> chunks = [];
      int i = remaining.length;
      while (i > 0) {
        if (i >= 2) {
          chunks.insert(0, remaining.substring(i - 2, i));
          i -= 2;
        } else {
          chunks.insert(0, remaining.substring(0, i));
          i = 0;
        }
      }
      formattedInteger = '${chunks.join(',')},$lastThree';
    }
    
    return '${isNegative ? '-' : ''}₹$formattedInteger$decimalPart';
  }

  /// Returns a [TextSpan] representing the formatted currency, where the
  /// decimal part (paise) is rendered in a smaller size than the main part.
  TextSpan toCurrencySpan({
    TextStyle? style,
    double decimalScale = 0.75,
  }) {
    final formatted = toCurrency();
    final parts = formatted.split('.');
    if (parts.length < 2) {
      return TextSpan(text: formatted, style: style);
    }
    
    final mainPart = parts[0];
    final decimalPart = '.${parts[1]}';
    
    final double baseSize = style?.fontSize ?? 14.0;
    final decStyle = (style ?? const TextStyle()).copyWith(
      fontSize: baseSize * decimalScale,
    );
    
    return TextSpan(
      children: [
        TextSpan(text: mainPart, style: style),
        TextSpan(text: decimalPart, style: decStyle),
      ],
    );
  }
}

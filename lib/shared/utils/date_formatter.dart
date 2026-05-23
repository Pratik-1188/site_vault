/// A lightweight date formatting utility for KK Group Site Vault.
///
/// Keeps formatting clean and consistent across the UI without bringing in
/// heavy external dependencies like 'intl' if only basic formatting is needed.
extension DateTimeFormatter on DateTime {
  /// Returns a formatted date string like "Jan 15, 2026"
  String toReadableString() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final dayStr = day.toString().padLeft(2, '0');
    final monthStr = months[month - 1];
    
    return '$monthStr $dayStr, $year';
  }

  /// Returns a short date string like "15/01/26"
  String toShortString() {
    final dayStr = day.toString().padLeft(2, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final yearShort = year.toString().substring(year.toString().length - 2);
    
    return '$dayStr/$monthStr/$yearShort';
  }
}

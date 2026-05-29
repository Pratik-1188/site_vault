/// A lightweight date formatting utility for KK Group Site Vault.
///
/// Keeps formatting clean and consistent across the UI without bringing in
/// heavy external dependencies like 'intl' if only basic formatting is needed.
extension DateTimeFormatter on DateTime {
  /// Returns a formatted date string like "Jan 15, 2026"
  String toReadableString() {
    final local = toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final dayStr = local.day.toString().padLeft(2, '0');
    final monthStr = months[local.month - 1];
    
    return '$monthStr $dayStr, ${local.year}';
  }

  /// Returns a short date string like "15/01/26"
  String toShortString() {
    final local = toLocal();
    final dayStr = local.day.toString().padLeft(2, '0');
    final monthStr = local.month.toString().padLeft(2, '0');
    final yearShort = local.year.toString().substring(local.year.toString().length - 2);
    
    return '$dayStr/$monthStr/$yearShort';
  }

  /// Returns a formatted date and time string like "Jan 15, 2026 • 02:30 PM"
  String toReadableDateTimeString() {
    final local = toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final dayStr = local.day.toString().padLeft(2, '0');
    final monthStr = months[local.month - 1];
    
    final hourNum = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final hourStr = hourNum.toString().padLeft(2, '0');
    final minuteStr = local.minute.toString().padLeft(2, '0');
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    
    return '$monthStr $dayStr, ${local.year} • $hourStr:$minuteStr $amPm';
  }
}

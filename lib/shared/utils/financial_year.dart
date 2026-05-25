class FinancialYear {
  final int startYear;

  const FinancialYear(this.startYear);

  /// Returns the [FinancialYear] corresponding to the current system date.
  factory FinancialYear.current() => FinancialYear.fromDate(DateTime.now());

  /// Returns the [FinancialYear] containing the given [date].
  ///
  /// In India, the financial year runs from April 1st to March 31st.
  factory FinancialYear.fromDate(DateTime date) {
    if (date.month >= 4) {
      return FinancialYear(date.year);
    } else {
      return FinancialYear(date.year - 1);
    }
  }

  /// The year in which this financial year ends.
  int get endYear => startYear + 1;

  /// The start date of this financial year (April 1st, 00:00:00).
  DateTime get startDate => DateTime(startYear, 4, 1);

  /// The end date of this financial year (March 31st, 23:59:59.999).
  DateTime get endDate => DateTime(endYear, 3, 31, 23, 59, 59, 999);

  /// A clean string representation of the financial year (e.g., "FY 2026-27").
  String get label {
    final endYearStr = endYear.toString();
    final endYearShort = endYearStr.substring(endYearStr.length - 2);
    return 'FY $startYear-$endYearShort';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialYear &&
          runtimeType == other.runtimeType &&
          startYear == other.startYear;

  @override
  int get hashCode => startYear.hashCode;

  @override
  String toString() => label;
}

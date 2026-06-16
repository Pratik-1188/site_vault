/// Represents the firm spending summaries from view_firm_analytics view.
class FirmAnalyticsSummary {
  final String firmId;
  final double totalSpend;
  final int expenseCount;

  FirmAnalyticsSummary({
    required this.firmId,
    required this.totalSpend,
    required this.expenseCount,
  });

  factory FirmAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return FirmAnalyticsSummary(
      firmId: json['firm_id'] as String,
      totalSpend: (json['total_spend'] as num).toDouble(),
      expenseCount: json['expense_count'] as int,
    );
  }
}

/// Represents the site spending summaries from view_site_analytics view.
class SiteAnalyticsSummary {
  final String siteId;
  final String firmId;
  final double totalSpend;
  final int expenseCount;

  SiteAnalyticsSummary({
    required this.siteId,
    required this.firmId,
    required this.totalSpend,
    required this.expenseCount,
  });

  factory SiteAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return SiteAnalyticsSummary(
      siteId: json['site_id'] as String,
      firmId: json['firm_id'] as String,
      totalSpend: (json['total_spend'] as num).toDouble(),
      expenseCount: json['expense_count'] as int,
    );
  }
}

/// Represents the category splits from view_category_analytics view.
class CategorySpendSummary {
  final String? siteId;
  final String firmId;
  final String? categoryId;
  final String categoryName;
  final double totalSpend;

  CategorySpendSummary({
    this.siteId,
    required this.firmId,
    this.categoryId,
    required this.categoryName,
    required this.totalSpend,
  });

  factory CategorySpendSummary.fromJson(Map<String, dynamic> json) {
    return CategorySpendSummary(
      siteId: json['site_id'] as String?,
      firmId: json['firm_id'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String? ?? 'Other',
      totalSpend: (json['total_spend'] as num).toDouble(),
    );
  }
}

/// Represents the monthly trends from view_monthly_analytics view.
class MonthlySpendTrend {
  final String? siteId;
  final String firmId;
  final DateTime monthDate;
  final double totalSpend;

  MonthlySpendTrend({
    this.siteId,
    required this.firmId,
    required this.monthDate,
    required this.totalSpend,
  });

  factory MonthlySpendTrend.fromJson(Map<String, dynamic> json) {
    return MonthlySpendTrend(
      siteId: json['site_id'] as String?,
      firmId: json['firm_id'] as String,
      monthDate: DateTime.parse(json['month_date'] as String),
      totalSpend: (json['total_spend'] as num).toDouble(),
    );
  }
}

/// Represents the vendor splits from view_vendor_analytics view.
class VendorSpendSummary {
  final String siteId;
  final String? vendorId;
  final String vendorName;
  final double totalSpend;

  VendorSpendSummary({
    required this.siteId,
    this.vendorId,
    required this.vendorName,
    required this.totalSpend,
  });

  factory VendorSpendSummary.fromJson(Map<String, dynamic> json) {
    return VendorSpendSummary(
      siteId: json['site_id'] as String,
      vendorId: json['vendor_id'] as String?,
      vendorName: json['vendor_name'] as String? ?? 'Other',
      totalSpend: (json['total_spend'] as num).toDouble(),
    );
  }
}

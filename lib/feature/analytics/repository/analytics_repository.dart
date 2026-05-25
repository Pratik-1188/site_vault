import 'package:site_vault/shared/repository/base_repository.dart';
import '../model/analytics_models.dart';

/// Database repository managing server-side aggregated query fetches from database Views.
class AnalyticsRepository extends BaseRepository {
  AnalyticsRepository(super.client);

  /// Fetch executive firm summaries (All firms comparative metrics)
  Future<List<FirmAnalyticsSummary>> fetchFirmSummaries() {
    return safeCall('AnalyticsRepository.fetchFirmSummaries', () async {
      final response = await client.from('view_firm_analytics').select();
      return (response as List).map((e) => FirmAnalyticsSummary.fromJson(e)).toList();
    });
  }

  /// Fetch single site summary (site total spent, GST split, count)
  Future<SiteAnalyticsSummary?> fetchSiteSummary(String siteId) {
    return safeCall('AnalyticsRepository.fetchSiteSummary', () async {
      final response = await client
          .from('view_site_analytics')
          .select()
          .eq('site_id', siteId)
          .maybeSingle();

      if (response == null) return null;
      return SiteAnalyticsSummary.fromJson(response);
    });
  }

  /// Fetch category spend distribution (supports Group, Firm, and Site levels)
  Future<List<CategorySpendSummary>> fetchCategorySpend({
    String? siteId,
    String? firmId,
  }) {
    return safeCall('AnalyticsRepository.fetchCategorySpend', () async {
      var query = client.from('view_category_analytics').select();

      if (siteId != null) {
        query = query.eq('site_id', siteId);
      } else if (firmId != null) {
        query = query.eq('firm_id', firmId);
      }

      final response = await query;
      return (response as List).map((e) => CategorySpendSummary.fromJson(e)).toList();
    });
  }

  /// Fetch monthly cashflow trend list (supports Group, Firm, and Site levels)
  Future<List<MonthlySpendTrend>> fetchMonthlySpend({
    String? siteId,
    String? firmId,
  }) {
    return safeCall('AnalyticsRepository.fetchMonthlySpend', () async {
      dynamic query = client.from('view_monthly_analytics').select();

      if (siteId != null) {
        query = query.eq('site_id', siteId);
      } else if (firmId != null) {
        query = query.eq('firm_id', firmId);
      }

      query = query.order('month_date', ascending: true);

      final response = await query;
      return (response as List).map((e) => MonthlySpendTrend.fromJson(e)).toList();
    });
  }

  /// Fetch site-specific vendor spending splits
  Future<List<VendorSpendSummary>> fetchVendorSpend(String siteId) {
    return safeCall('AnalyticsRepository.fetchVendorSpend', () async {
      final response = await client
          .from('view_vendor_analytics')
          .select()
          .eq('site_id', siteId)
          .order('total_spend', ascending: false);

      return (response as List).map((e) => VendorSpendSummary.fromJson(e)).toList();
    });
  }
}

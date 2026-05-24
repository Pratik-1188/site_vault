import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/analytics_models.dart';

/// Database repository managing server-side aggregated query fetches from database Views.
class AnalyticsRepository {
  final SupabaseClient _client;

  AnalyticsRepository(this._client);

  /// Fetch executive firm summaries (All firms comparative metrics)
  Future<List<FirmAnalyticsSummary>> fetchFirmSummaries() async {
    try {
      final response = await _client.from('view_firm_analytics').select();
      return (response as List).map((e) => FirmAnalyticsSummary.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchFirmSummaries: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetch single site summary (site total spent, GST split, count)
  Future<SiteAnalyticsSummary?> fetchSiteSummary(String siteId) async {
    try {
      final response = await _client
          .from('view_site_analytics')
          .select()
          .eq('site_id', siteId)
          .maybeSingle();

      if (response == null) return null;
      return SiteAnalyticsSummary.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchSiteSummary: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetch category spend distribution (supports Group, Firm, and Site levels)
  Future<List<CategorySpendSummary>> fetchCategorySpend({
    String? siteId,
    String? firmId,
  }) async {
    try {
      var query = _client.from('view_category_analytics').select();
      
      if (siteId != null) {
        query = query.eq('site_id', siteId);
      } else if (firmId != null) {
        query = query.eq('firm_id', firmId);
      }
      
      final response = await query;
      return (response as List).map((e) => CategorySpendSummary.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchCategorySpend: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetch monthly cashflow trend list (supports Group, Firm, and Site levels)
  Future<List<MonthlySpendTrend>> fetchMonthlySpend({
    String? siteId,
    String? firmId,
  }) async {
    try {
      dynamic query = _client.from('view_monthly_analytics').select();
      
      if (siteId != null) {
        query = query.eq('site_id', siteId);
      } else if (firmId != null) {
        query = query.eq('firm_id', firmId);
      }
      
      query = query.order('month_date', ascending: true);
      
      final response = await query;
      return (response as List).map((e) => MonthlySpendTrend.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchMonthlySpend: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetch site-specific vendor spending splits
  Future<List<VendorSpendSummary>> fetchVendorSpend(String siteId) async {
    try {
      final response = await _client
          .from('view_vendor_analytics')
          .select()
          .eq('site_id', siteId)
          .order('total_spend', ascending: false);

      return (response as List).map((e) => VendorSpendSummary.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchVendorSpend: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }
}

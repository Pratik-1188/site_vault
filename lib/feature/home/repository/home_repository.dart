import 'package:site_vault/shared/repository/base_repository.dart';

class HomeRepository extends BaseRepository {
  HomeRepository(super.client);

  Future<double> fetchCurrentMonthExpenseTotal() {
    return safeCall('HomeRepository.fetchCurrentMonthExpenseTotal', () async {
      final response = await client
          .from('view_homescreen_analytics')
          .select('current_year_expense_total')
          .single();

      final val = response['current_year_expense_total'];
      return val is num ? val.toDouble() : 0.0;
    });
  }

  Future<int> fetchActiveSitesForCurrentFinancialYear() {
    return safeCall(
      'HomeRepository.fetchActiveSitesForCurrentFinancialYear',
      () async {
        final response = await client
            .from('view_homescreen_analytics')
            .select('active_sites_count')
            .single();

        final val = response['active_sites_count'];
        return val is int ? val : 0;
      },
    );
  }

  Future<double> fetchMissingBillExpensesForCurrentFinancialYear() {
    return safeCall(
      'HomeRepository.fetchMissingBillExpensesForCurrentFinancialYear',
      () async {
        final response = await client
            .from('view_homescreen_analytics')
            .select('missing_bill_expense_total')
            .single();

        final val = response['missing_bill_expense_total'];
        return val is num ? val.toDouble() : 0.0;
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchRecentAuditLogs() {
    return safeCall('HomeRepository.fetchRecentAuditLogs', () async {
      final response = await client
          .from('audit_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(4);

      return (response as List).cast<Map<String, dynamic>>();
    });
  }

}

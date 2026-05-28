import 'package:site_vault/shared/repository/base_repository.dart';
import 'package:site_vault/shared/utils/financial_year.dart';

class HomeRepository extends BaseRepository {
  HomeRepository(super.client);

  Future<double> fetchCurrentMonthExpenseTotal() {
    return safeCall('HomeRepository.fetchCurrentMonthExpenseTotal', () async {
      final currentFinancialYear = FinancialYear.current();

      final response = await client
          .from('expenses')
          .select('total:amount.sum()')
          .gte('expense_date', _dateOnly(currentFinancialYear.startDate))
          .lte('expense_date', _dateOnly(currentFinancialYear.endDate))
          .isFilter('soft_deleted_at', null);

      return _readAggregateDouble(response, 'total');
    });
  }

  Future<int> fetchActiveSitesForCurrentFinancialYear() {
    return safeCall(
      'HomeRepository.fetchActiveSitesForCurrentFinancialYear',
      () async {
        final currentFinancialYear = FinancialYear.current();

        return client
            .from('sites')
            .count()
            .eq('status', 'active')
            .gte('started_on', _dateOnly(currentFinancialYear.startDate))
            .lte('started_on', _dateOnly(currentFinancialYear.endDate));
      },
    );
  }

  Future<double> fetchMissingBillExpensesForCurrentFinancialYear() {
    return safeCall(
      'HomeRepository.fetchMissingBillExpensesForCurrentFinancialYear',
      () async {
        final currentFinancialYear = FinancialYear.current();

        final response = await client
            .from('expenses')
            .select('total:amount.sum()')
            .isFilter('attachment_path', null)
            .gte('expense_date', _dateOnly(currentFinancialYear.startDate))
            .lte('expense_date', _dateOnly(currentFinancialYear.endDate))
            .isFilter('soft_deleted_at', null);

        return _readAggregateDouble(response, 'total');
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

  double _readAggregateDouble(Object response, String key) {
    if (response is! List || response.isEmpty) {
      return 0;
    }

    final row = response.first;
    if (row is! Map<String, dynamic>) {
      return 0;
    }

    final value = row[key];
    return value is num ? value.toDouble() : 0;
  }

  String _dateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

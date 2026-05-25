import 'package:site_vault/shared/repository/base_repository.dart';
import 'package:site_vault/shared/model/profile.dart';
import '../model/expense.dart';

/// Database repository class managing all database reads, writes, and mutations
/// for the Expense feature using Supabase.
class ExpenseRepository extends BaseRepository {
  ExpenseRepository(super.client);

  /// Fetches all active (non-soft-deleted) expenses for a specific site.
  /// Joins nested categories and vendors directly from the database.
  Future<List<Expense>> fetchExpensesForSite(String siteId) {
    return safeCall('ExpenseRepository.fetchExpensesForSite', () async {
      final response = await client
          .from('expenses')
          .select('*, expense_categories(*), vendors(*)')
          .eq('site_id', siteId)
          .isFilter('soft_deleted_at', null)
          .order('expense_date', ascending: false);

      return (response as List).map((e) => Expense.fromJson(e)).toList();
    });
  }

  /// Inserts a new expense record in the database.
  Future<Expense> createExpense(Expense expense) {
    return safeCall('ExpenseRepository.createExpense', () async {
      final data = expense.toJson();

      if (expense.id.isEmpty) {
        data.remove('id');
      }

      final response = await client
          .from('expenses')
          .insert(data)
          .select('*, expense_categories(*), vendors(*)')
          .single();

      return Expense.fromJson(response);
    });
  }

  /// Updates an existing expense row matching the ID.
  Future<Expense> updateExpense(Expense expense) {
    return safeCall('ExpenseRepository.updateExpense', () async {
      final response = await client
          .from('expenses')
          .update(expense.toJson())
          .eq('id', expense.id)
          .select('*, expense_categories(*), vendors(*)')
          .single();

      return Expense.fromJson(response);
    });
  }

  /// Soft deletes an expense by setting its [soft_deleted_at] timestamp to NOW.
  Future<void> softDeleteExpense(String expenseId) {
    return safeCall('ExpenseRepository.softDeleteExpense', () async {
      await client
          .from('expenses')
          .update({
            'soft_deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', expenseId);
    });
  }

  /// Fetches active expense categories to populate form selections, ordered by name.
  Future<List<ExpenseCategory>> fetchCategories() {
    return safeCall('ExpenseRepository.fetchCategories', () async {
      final response = await client
          .from('expense_categories')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    });
  }

  /// Fetches active vendors to populate form selections, ordered by name.
  Future<List<Vendor>> fetchVendors() {
    return safeCall('ExpenseRepository.fetchVendors', () async {
      final response = await client
          .from('vendors')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List).map((e) => Vendor.fromJson(e)).toList();
    });
  }

  /// Fetches active user profiles from the database, ordered by display name.
  Future<List<Profile>> fetchProfiles() {
    return safeCall('ExpenseRepository.fetchProfiles', () async {
      final response = await client
          .from('profiles')
          .select()
          .eq('is_active', true)
          .order('display_name', ascending: true);

      return (response as List).map((e) => Profile.fromJson(e)).toList();
    });
  }

  /// Inserts a new expense attachment record.
  Future<void> addAttachment(String expenseId, String fileUrl) {
    return safeCall('ExpenseRepository.addAttachment', () async {
      await client.from('expense_attachments').insert({
        'expense_id': expenseId,
        'file_url': fileUrl,
      });
    });
  }

  /// Fetches attachments for a specific expense.
  Future<List<String>> fetchAttachmentsForExpense(String expenseId) {
    return safeCall('ExpenseRepository.fetchAttachmentsForExpense', () async {
      final response = await client
          .from('expense_attachments')
          .select('file_url')
          .eq('expense_id', expenseId);
      return (response as List).map((e) => e['file_url'] as String).toList();
    });
  }
}

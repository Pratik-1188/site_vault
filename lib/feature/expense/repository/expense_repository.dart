import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:site_vault/shared/model/profile.dart';
import '../model/expense.dart';

/// Database repository class managing all database reads, writes, and mutations
/// for the Expense feature using Supabase.
class ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepository(this._client);

  /// Fetches all active (non-soft-deleted) expenses for a specific site.
  /// Joins nested categories and vendors directly from the database.
  Future<List<Expense>> fetchExpensesForSite(String siteId) async {
    try {
      final response = await _client
          .from('expenses')
          .select('*, expense_categories(*), vendors(*)')
          .eq('site_id', siteId)
          .isFilter('soft_deleted_at', null)
          .order('expense_date', ascending: false);

      return (response as List).map((e) => Expense.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchExpensesForSite: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Inserts a new expense record in the database.
  Future<Expense> createExpense(Expense expense) async {
    try {
      // Convert to JSON and remove ID so Supabase triggers auto UUID if not present
      final data = expense.toJson();
      
      // Let DB handle auto UUID or use client-generated
      if (expense.id.isEmpty) {
        data.remove('id');
      }
      
      final response = await _client
          .from('expenses')
          .insert(data)
          .select('*, expense_categories(*), vendors(*)')
          .single();

      return Expense.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in createExpense: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Updates an existing expense row matching the ID.
  Future<Expense> updateExpense(Expense expense) async {
    try {
      final response = await _client
          .from('expenses')
          .update(expense.toJson())
          .eq('id', expense.id)
          .select('*, expense_categories(*), vendors(*)')
          .single();

      return Expense.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in updateExpense: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Soft deletes an expense by setting its [soft_deleted_at] timestamp to NOW.
  Future<void> softDeleteExpense(String expenseId) async {
    try {
      await _client
          .from('expenses')
          .update({
            'soft_deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', expenseId);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in softDeleteExpense: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetches active expense categories to populate form selections, ordered by name.
  Future<List<ExpenseCategory>> fetchCategories() async {
    try {
      final response = await _client
          .from('expense_categories')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchCategories: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetches active vendors to populate form selections, ordered by name.
  Future<List<Vendor>> fetchVendors() async {
    try {
      final response = await _client
          .from('vendors')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List).map((e) => Vendor.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchVendors: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetches active user profiles from the database, ordered by display name.
  Future<List<Profile>> fetchProfiles() async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('is_active', true)
          .order('display_name', ascending: true);

      return (response as List).map((e) => Profile.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchProfiles: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Inserts a new expense attachment record.
  Future<void> addAttachment(String expenseId, String fileUrl) async {
    try {
      await _client.from('expense_attachments').insert({
        'expense_id': expenseId,
        'file_url': fileUrl,
      });
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in addAttachment: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Fetches attachments for a specific expense.
  Future<List<String>> fetchAttachmentsForExpense(String expenseId) async {
    try {
      final response = await _client
          .from('expense_attachments')
          .select('file_url')
          .eq('expense_id', expenseId);
      return (response as List).map((e) => e['file_url'] as String).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchAttachmentsForExpense: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }
}

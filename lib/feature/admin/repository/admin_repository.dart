import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/shared/model/profile.dart';

/// Database repository managing administrative updates to core master tables in Supabase.
class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  // ==========================================
  // VENDORS MANAGEMENT
  // ==========================================

  /// Fetches all registered vendors ordered alphabetically.
  Future<List<Vendor>> fetchAllVendors() async {
    try {
      final response = await _client
          .from('vendors')
          .select()
          .order('name', ascending: true);

      return (response as List).map((e) => Vendor.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchAllVendors: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Inserts a new vendor row in the database.
  Future<Vendor> createVendor({
    required String name,
    required String? contactInfo,
  }) async {
    try {
      final response = await _client
          .from('vendors')
          .insert({
            'name': name,
            'contact_info': contactInfo?.trim().isEmpty == true ? null : contactInfo?.trim(),
            'is_active': true,
          })
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in createVendor: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Updates details and operational status of a vendor.
  Future<Vendor> updateVendor({
    required String id,
    required String name,
    required String? contactInfo,
    required bool isActive,
  }) async {
    try {
      final response = await _client
          .from('vendors')
          .update({
            'name': name,
            'contact_info': contactInfo?.trim().isEmpty == true ? null : contactInfo?.trim(),
            'is_active': isActive,
          })
          .eq('id', id)
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in updateVendor: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  // ==========================================
  // EXPENSE CATEGORIES MANAGEMENT
  // ==========================================

  /// Fetches all expense categories ordered alphabetically.
  Future<List<ExpenseCategory>> fetchAllCategories() async {
    try {
      final response = await _client
          .from('expense_categories')
          .select()
          .order('name', ascending: true);

      return (response as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchAllCategories: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Inserts a new expense category row.
  Future<ExpenseCategory> createCategory({required String name}) async {
    try {
      final response = await _client
          .from('expense_categories')
          .insert({
            'name': name,
            'is_active': true,
          })
          .select()
          .single();

      return ExpenseCategory.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in createCategory: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Updates details and status of a category.
  Future<ExpenseCategory> updateCategory({
    required String id,
    required String name,
    required bool isActive,
  }) async {
    try {
      final response = await _client
          .from('expense_categories')
          .update({
            'name': name,
            'is_active': isActive,
          })
          .eq('id', id)
          .select()
          .single();

      return ExpenseCategory.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in updateCategory: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  // ==========================================
  // STAFF PROFILES MANAGEMENT
  // ==========================================

  /// Fetches all staff/user profiles ordered alphabetically.
  Future<List<Profile>> fetchAllProfiles() async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .order('display_name', ascending: true);

      return (response as List).map((e) => Profile.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchAllProfiles: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Updates a user's display name and active status.
  Future<Profile> updateProfile({
    required String id,
    required String displayName,
    required bool isActive,
  }) async {
    try {
      final response = await _client
          .from('profiles')
          .update({
            'display_name': displayName.trim(),
            'is_active': isActive,
          })
          .eq('id', id)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in updateProfile: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }
}

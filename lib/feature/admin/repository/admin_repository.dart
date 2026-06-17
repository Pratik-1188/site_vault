import 'package:site_vault/shared/repository/base_repository.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/shared/model/profile.dart';

/// Database repository managing administrative updates to core master tables in Supabase.
class AdminRepository extends BaseRepository {
  AdminRepository(super.client);

  // ==========================================
  // VENDORS MANAGEMENT
  // ==========================================

  /// Fetches all registered vendors ordered alphabetically.
  Future<List<Vendor>> fetchAllVendors() {
    return safeCall('AdminRepository.fetchAllVendors', () async {
      final response = await client
          .from('vendors')
          .select()
          .order('name', ascending: true);

      return (response as List).map((e) => Vendor.fromJson(e)).toList();
    });
  }

  /// Inserts a new vendor row in the database.
  Future<Vendor> createVendor({
    required String name,
    required String? contactInfo,
  }) {
    return safeCall('AdminRepository.createVendor', () async {
      final response = await client
          .from('vendors')
          .insert({
            'name': name,
            'contact_info': contactInfo?.trim().isEmpty == true ? null : contactInfo?.trim(),
            'is_active': true,
          })
          .select()
          .single();

      return Vendor.fromJson(response);
    });
  }

  /// Updates details and operational status of a vendor.
  Future<Vendor> updateVendor({
    required String id,
    required String name,
    required String? contactInfo,
    required bool isActive,
  }) {
    return safeCall('AdminRepository.updateVendor', () async {
      final response = await client
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
    });
  }

  // ==========================================
  // EXPENSE CATEGORIES MANAGEMENT
  // ==========================================

  /// Fetches all expense categories ordered alphabetically.
  Future<List<ExpenseCategory>> fetchAllCategories() {
    return safeCall('AdminRepository.fetchAllCategories', () async {
      final response = await client
          .from('expense_categories')
          .select()
          .order('name', ascending: true);

      return (response as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    });
  }

  /// Inserts a new expense category row.
  Future<ExpenseCategory> createCategory({required String name}) {
    return safeCall('AdminRepository.createCategory', () async {
      final response = await client
          .from('expense_categories')
          .insert({
            'name': name,
            'is_active': true,
          })
          .select()
          .single();

      return ExpenseCategory.fromJson(response);
    });
  }

  /// Updates details and status of a category.
  Future<ExpenseCategory> updateCategory({
    required String id,
    required String name,
    required bool isActive,
  }) {
    return safeCall('AdminRepository.updateCategory', () async {
      final response = await client
          .from('expense_categories')
          .update({
            'name': name,
            'is_active': isActive,
          })
          .eq('id', id)
          .select()
          .single();

      return ExpenseCategory.fromJson(response);
    });
  }

  // ==========================================
  // STAFF PROFILES MANAGEMENT
  // ==========================================

  /// Fetches all staff/user profiles ordered alphabetically.
  Future<List<Profile>> fetchAllProfiles() {
    return safeCall('AdminRepository.fetchAllProfiles', () async {
      final response = await client
          .from('profiles')
          .select()
          .order('display_name', ascending: true);

      return (response as List).map((e) => Profile.fromJson(e)).toList();
    });
  }

}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/admin/repository/admin_repository.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/feature/expense/provider/expense_provider.dart'; // To invalidate dropdown caches
import 'package:site_vault/shared/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_provider.g.dart';

/// Provides the AdminRepository singleton.
@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) {
  final client = Supabase.instance.client;
  return AdminRepository(client);
}

// ==========================================
// SEARCH FILTERS STATE
// ==========================================

@riverpod
class AdminVendorsSearchQuery extends _$AdminVendorsSearchQuery {
  @override
  String build() => "";
  void update(String value) => state = value;
}

@riverpod
class AdminCategoriesSearchQuery extends _$AdminCategoriesSearchQuery {
  @override
  String build() => "";
  void update(String value) => state = value;
}

@riverpod
class AdminProfilesSearchQuery extends _$AdminProfilesSearchQuery {
  @override
  String build() => "";
  void update(String value) => state = value;
}

// ==========================================
// NOTIFIER CONTROLLERS (MUTATORS)
// ==========================================

@riverpod
class AdminVendors extends _$AdminVendors {
  @override
  Future<List<Vendor>> build() async {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.fetchAllVendors();
  }

  /// Inserts a new vendor row in Supabase and invalidates dropdown selections.
  Future<void> addVendor({
    required String name,
    required String? contactInfo,
  }) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.createVendor(name: name, contactInfo: contactInfo);
    
    // Invalidate local list and expense module cached dropdowns
    ref.invalidateSelf();
    ref.invalidate(vendorsProvider);
  }

  /// Modifies vendor details and invalidates dropdown selections.
  Future<void> editVendor({
    required String id,
    required String name,
    required String? contactInfo,
    required bool isActive,
  }) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateVendor(id: id, name: name, contactInfo: contactInfo, isActive: isActive);
    
    // Invalidate local list and expense module cached dropdowns
    ref.invalidateSelf();
    ref.invalidate(vendorsProvider);
  }
}

@riverpod
class AdminCategories extends _$AdminCategories {
  @override
  Future<List<ExpenseCategory>> build() async {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.fetchAllCategories();
  }

  /// Inserts a new category row in Supabase and invalidates dropdown selections.
  Future<void> addCategory({required String name}) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.createCategory(name: name);
    
    ref.invalidateSelf();
    ref.invalidate(expenseCategoriesProvider);
  }

  /// Modifies category status and invalidates dropdown selections.
  Future<void> editCategory({
    required String id,
    required String name,
    required bool isActive,
  }) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateCategory(id: id, name: name, isActive: isActive);
    
    ref.invalidateSelf();
    ref.invalidate(expenseCategoriesProvider);
  }
}

@riverpod
class AdminProfiles extends _$AdminProfiles {
  @override
  Future<List<Profile>> build() async {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.fetchAllProfiles();
  }

  /// Securely creates a new user and invalidates relevant caches.
  Future<void> addUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.createAppUser(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    
    // Invalidate local admin profiles list and dropdown selections cache
    ref.invalidateSelf();
    ref.invalidate(profilesProvider);
  }

  /// Securely deletes a user and invalidates relevant caches.
  Future<void> deleteUser(String userId) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.deleteAppUser(userId);
    
    // Invalidate local admin profiles list and dropdown selections cache
    ref.invalidateSelf();
    ref.invalidate(profilesProvider);
  }
}

// ==========================================
// SEARCH FILTERING SELECTORS
// ==========================================

@riverpod
Future<List<Vendor>> filteredAdminVendors(Ref ref) async {
  final vendors = await ref.watch(adminVendorsProvider.future);
  final query = ref.watch(adminVendorsSearchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return vendors;

  return vendors.where((v) {
    return v.name.toLowerCase().contains(query) || 
           (v.contactInfo?.toLowerCase().contains(query) ?? false);
  }).toList();
}

@riverpod
Future<List<ExpenseCategory>> filteredAdminCategories(Ref ref) async {
  final categories = await ref.watch(adminCategoriesProvider.future);
  final query = ref.watch(adminCategoriesSearchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return categories;

  return categories.where((c) {
    return c.name.toLowerCase().contains(query);
  }).toList();
}

@riverpod
Future<List<Profile>> filteredAdminProfiles(Ref ref) async {
  final profiles = await ref.watch(adminProfilesProvider.future);
  final query = ref.watch(adminProfilesSearchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return profiles;

  return profiles.where((p) {
    return p.displayName.toLowerCase().contains(query);
  }).toList();
}

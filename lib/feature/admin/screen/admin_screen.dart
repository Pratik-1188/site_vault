import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/admin/provider/admin_provider.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/widget/app_bottom_sheet.dart';
import 'package:site_vault/shared/widget/custom_search_bar.dart';
import 'package:site_vault/shared/widget/button_group.dart';
import 'package:site_vault/shared/widget/status_badge.dart';
import 'package:site_vault/shared/widget/confirmation_dialogs.dart';
import 'package:site_vault/shared/widget/sign_out_menu_button.dart';
import 'package:site_vault/shared/mixin/form_submit_mixin.dart';
import 'package:site_vault/shared/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';

/// Central administration settings panel managing Vendors, Categories, and Profiles.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _vendorSearchController = TextEditingController();
  final _categorySearchController = TextEditingController();
  final _profileSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to toggle Floating Action Button based on tab index
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vendorSearchController.dispose();
    _categorySearchController.dispose();
    _profileSearchController.dispose();
    super.dispose();
  }



  /// Opens the modal bottom sheet to create or edit a vendor
  void _openVendorForm(BuildContext context, [Vendor? vendor]) {
    showAppBottomSheet(
      context: context,
      child: _VendorFormSheet(vendorToEdit: vendor),
    );
  }

  /// Opens the modal bottom sheet to create or edit an expense category
  void _openCategoryForm(BuildContext context, [ExpenseCategory? category]) {
    showAppBottomSheet(
      context: context,
      child: _CategoryFormSheet(categoryToEdit: category),
    );
  }

  /// Opens the modal bottom sheet to create a new user
  void _openUserForm(BuildContext context) {
    showAppBottomSheet(
      context: context,
      child: const _UserFormSheet(),
    );
  }

  void _confirmDeleteUser(BuildContext context, Profile profile) async {
    final confirmed = await ConfirmationDialogs.confirmStrong(
      context,
      title: 'Delete User Account',
      message: 'Are you sure you want to delete ${profile.displayName}?\n\n'
          'This will delete their auth login credentials immediately and set their status to inactive. '
          'Their historical records (expenses, documents) will remain associated with their inactive profile.',
      expectedMatch: profile.displayName,
      confirmLabel: 'DELETE',
    );

    if (confirmed) {
      _deleteUserAction(profile.id);
    }
  }

  Future<void> _deleteUserAction(String userId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Deleting user...'),
          ],
        ),
        duration: Duration(days: 1),
      ),
    );

    try {
      await ref.read(adminProfilesProvider.notifier).deleteUser(userId);
      if (mounted) {
        AppSnackBar.showSuccess(context, 'User deleted successfully!');
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        AppSnackBar.showError(context, cleanMessage);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar.medium(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              scrolledUnderElevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => context.go('/'),
                tooltip: 'Back to Dashboard',
              ),
              title: Text(
                'Administrative Hub',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              actions: const [
                SignOutMenuButton(),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(62),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ButtonGroup<int>(
                    options: const [
                      ButtonGroupOption(value: 0, label: 'Vendors'),
                      ButtonGroupOption(value: 1, label: 'Categories'),
                      ButtonGroupOption(value: 2, label: 'Users'),
                    ],
                    selectedValue: _tabController.index,
                    onSelected: (index) {
                      _tabController.animateTo(index);
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVendorsPanel(),
            _buildCategoriesPanel(),
            _buildProfilesPanel(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _openVendorForm(context);
          } else if (_tabController.index == 1) {
            _openCategoryForm(context);
          } else if (_tabController.index == 2) {
            _openUserForm(context);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _tabController.index == 0
              ? 'ADD VENDOR'
              : _tabController.index == 1
                  ? 'ADD CATEGORY'
                  : 'ADD USER',
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.go('/sites');
          } else if (index == 2) {
            context.go('/analytics');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Sites',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VENDORS PANEL TABS
  // ==========================================
  Widget _buildVendorsPanel() {
    final vendorsAsync = ref.watch(filteredAdminVendorsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Search Field
          CustomSearchBar(
            controller: _vendorSearchController,
            onChanged: (val) {
              ref.read(adminVendorsSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search vendors by name or contact...',
            showClearButton: _vendorSearchController.text.isNotEmpty,
            onClear: () {
              _vendorSearchController.clear();
              ref.read(adminVendorsSearchQueryProvider.notifier).update("");
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Vendors list
          Expanded(
            child: vendorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading vendors: $e')),
              data: (vendors) {
                if (vendors.isEmpty) {
                  return const Center(
                    child: Text('No vendors found.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  );
                }

                return ListView.builder(
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.brMd,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.store_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                        title: Text(
                          vendor.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          vendor.contactInfo ?? 'No contact info provided',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge(status: vendor.isActive ? 'active' : 'inactive'),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, size: 20),
                              splashRadius: 20,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  _openVendorForm(context, vendor);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORIES PANEL TABS
  // ==========================================
  Widget _buildCategoriesPanel() {
    final categoriesAsync = ref.watch(filteredAdminCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Search Field
          CustomSearchBar(
            controller: _categorySearchController,
            onChanged: (val) {
              ref.read(adminCategoriesSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search categories by name...',
            showClearButton: _categorySearchController.text.isNotEmpty,
            onClear: () {
              _categorySearchController.clear();
              ref.read(adminCategoriesSearchQueryProvider.notifier).update("");
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Categories list
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading categories: $e')),
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Text('No categories found.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  );
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.brMd,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.category_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge(status: category.isActive ? 'active' : 'inactive'),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, size: 20),
                              splashRadius: 20,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  _openCategoryForm(context, category);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STAFF PROFILES PANEL TABS
  // ==========================================
  Widget _buildProfilesPanel() {
    final profilesAsync = ref.watch(filteredAdminProfilesProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Search Field
          CustomSearchBar(
            controller: _profileSearchController,
            onChanged: (val) {
              ref.read(adminProfilesSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search users by display name...',
            showClearButton: _profileSearchController.text.isNotEmpty,
            onClear: () {
              _profileSearchController.clear();
              ref.read(adminProfilesSearchQueryProvider.notifier).update("");
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Users list
          Expanded(
            child: profilesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading users: $e')),
              data: (profiles) {
                if (profiles.isEmpty) {
                  return const Center(
                    child: Text('No users found.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  );
                }

                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final isSelf = profile.id == currentUserId;
                    final isActive = profile.isActive;

                    return Opacity(
                      opacity: isActive ? 1.0 : 0.5,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.brMd,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: ListTile(
                          enabled: isActive,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            profile.displayName + (isSelf ? ' (You)' : ''),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              StatusBadge(status: isActive ? 'active' : 'inactive'),
                            ],
                          ),
                          trailing: isSelf
                              ? null
                              : PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                                  splashRadius: 20,
                                  onSelected: (action) {
                                    if (action == 'delete' && isActive) {
                                      _confirmDeleteUser(context, profile);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      enabled: isActive,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: isActive
                                                ? Theme.of(context).colorScheme.error
                                                : Theme.of(context).disabledColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: isActive
                                                  ? Theme.of(context).colorScheme.error
                                                  : Theme.of(context).disabledColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

// ============================================================================
// 1. VENDOR BOTTOM SHEET FORM EDITOR
// ============================================================================
class _VendorFormSheet extends ConsumerStatefulWidget {
  final Vendor? vendorToEdit;

  const _VendorFormSheet({this.vendorToEdit});

  @override
  ConsumerState<_VendorFormSheet> createState() => _VendorFormSheetState();
}

class _VendorFormSheetState extends ConsumerState<_VendorFormSheet> with FormSubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vendorToEdit?.name ?? '');
    _contactController = TextEditingController(text: widget.vendorToEdit?.contactInfo ?? '');
    _isActive = widget.vendorToEdit?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();

    await runFormSubmit(
      action: () async {
        if (widget.vendorToEdit == null) {
          await ref.read(adminVendorsProvider.notifier).addVendor(name: name, contactInfo: contact);
        } else {
          await ref.read(adminVendorsProvider.notifier).editVendor(
                id: widget.vendorToEdit!.id,
                name: name,
                contactInfo: contact,
                isActive: _isActive,
              );
        }
      },
      successMessage: widget.vendorToEdit == null
          ? 'Vendor created successfully!'
          : 'Vendor updated successfully!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: widget.vendorToEdit == null ? 'Add Vendor' : 'Edit Vendor Details',
      formKey: _formKey,
      canClose: !isSubmitting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Vendor Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Vendor Business Name *',
              prefixIcon: Icon(Icons.store_rounded),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact / Phone Info',
              prefixIcon: Icon(Icons.phone_rounded),
              hintText: 'e.g. +91 98765 43210',
            ),
          ),
          if (widget.vendorToEdit != null) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.check_circle_outline_rounded),
              title: const Text('Active Status'),
              subtitle: const Text('Allow selecting this vendor in new expenses'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
          ],
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        widget.vendorToEdit == null
                            ? 'Create Vendor'
                            : 'Save Changes',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. CATEGORY BOTTOM SHEET FORM EDITOR
// ============================================================================
class _CategoryFormSheet extends ConsumerStatefulWidget {
  final ExpenseCategory? categoryToEdit;

  const _CategoryFormSheet({this.categoryToEdit});

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> with FormSubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name ?? '');
    _isActive = widget.categoryToEdit?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    await runFormSubmit(
      action: () async {
        if (widget.categoryToEdit == null) {
          await ref.read(adminCategoriesProvider.notifier).addCategory(name: name);
        } else {
          await ref.read(adminCategoriesProvider.notifier).editCategory(
                id: widget.categoryToEdit!.id,
                name: name,
                isActive: _isActive,
              );
        }
      },
      successMessage: widget.categoryToEdit == null
          ? 'Category created successfully!'
          : 'Category updated successfully!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: widget.categoryToEdit == null ? 'Add Category' : 'Edit Category Details',
      formKey: _formKey,
      canClose: !isSubmitting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Category Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Expense Category Name *',
              prefixIcon: Icon(Icons.category_rounded),
              hintText: 'e.g. Electric Cables, Concrete Foundation',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a category name' : null,
          ),
          if (widget.categoryToEdit != null) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.check_circle_outline_rounded),
              title: const Text('Active Status'),
              subtitle: const Text('Allow selecting this category in new expenses'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
          ],
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        widget.categoryToEdit == null
                            ? 'Create Category'
                            : 'Save Changes',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. USER BOTTOM SHEET FORM EDITOR
// ============================================================================
class _UserFormSheet extends ConsumerStatefulWidget {
  const _UserFormSheet();

  @override
  ConsumerState<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<_UserFormSheet> with FormSubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  String _selectedRole = 'staff';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

    final confirmed = await ConfirmationDialogs.confirmReview(
      context,
      title: 'Review User Details',
      message: 'Please verify the details below before creating the user account.',
      fields: {
        'Email': email,
        'Display Name': displayName,
        'Role': _selectedRole,
        'Password': '•' * password.length,
      },
      confirmLabel: 'Create',
    );

    if (!confirmed) return;

    await runFormSubmit(
      action: () async {
        await ref.read(adminProfilesProvider.notifier).addUser(
          email: email,
          password: password,
          displayName: displayName,
          role: _selectedRole,
        );
      },
      successMessage: 'User created successfully!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Add User',
      formKey: _formKey,
      canClose: !isSubmitting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Login Credentials & Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name *',
              prefixIcon: Icon(Icons.person_rounded),
              hintText: 'e.g. JohnDoe (No spaces)',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter a display name';
              }
              if (val.trim().length < 3) {
                return 'Display name must be at least 3 characters';
              }
              if (RegExp(r'\s').hasMatch(val)) {
                return 'Display name cannot contain spaces';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              prefixIcon: Icon(Icons.email_rounded),
              hintText: 'e.g. user@kkgroup.com',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter an email';
              }
              if (!val.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password *',
              prefixIcon: Icon(Icons.lock_rounded),
              hintText: 'Minimum 6 characters',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter a password';
              }
              if (val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'User Role *',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
            items: const [
              DropdownMenuItem(
                value: 'staff',
                child: Text('staff'),
              ),
              DropdownMenuItem(
                value: 'admin',
                child: Text('admin'),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedRole = val);
              }
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Create User'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



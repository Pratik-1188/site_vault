import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/admin/provider/admin_provider.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/shared/model/profile.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/widget/custom_search_bar.dart';
import 'package:site_vault/shared/widget/button_group.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';

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

  /// Confirms and handles user sign out
  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of KK Group Site Vault?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(authActionsProvider).signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Opens the modal bottom sheet to create or edit a vendor
  void _openVendorForm(BuildContext context, [Vendor? vendor]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VendorFormSheet(vendorToEdit: vendor),
    );
  }

  /// Opens the modal bottom sheet to create or edit an expense category
  void _openCategoryForm(BuildContext context, [ExpenseCategory? category]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormSheet(categoryToEdit: category),
    );
  }

  /// Opens the modal bottom sheet to edit a user/staff profile
  void _openProfileForm(BuildContext context, Profile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileFormSheet(profileToEdit: profile),
    );
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
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.account_circle_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'User Profile Options',
                  onSelected: (val) {
                    if (val == 'signout') {
                      _handleSignOut();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'signout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(62),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ButtonGroup<int>(
                    options: const [
                      ButtonGroupOption(value: 0, label: 'Vendors'),
                      ButtonGroupOption(value: 1, label: 'Categories'),
                      ButtonGroupOption(value: 2, label: 'Staff Profiles'),
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
      floatingActionButton: _tabController.index == 2
          ? null // Staff are manually added via backend dashboard, admin can only edit/disable
          : FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  _openVendorForm(context);
                } else if (_tabController.index == 1) {
                  _openCategoryForm(context);
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(_tabController.index == 0 ? 'ADD VENDOR' : 'ADD CATEGORY'),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.store_rounded, color: Theme.of(context).colorScheme.primary),
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
                              _statusChip(vendor.isActive),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 22),
                                onPressed: () => _openVendorForm(context, vendor),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.category_rounded, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _statusChip(category.isActive),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 22),
                                onPressed: () => _openCategoryForm(context, category),
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

  // ==========================================
  // STAFF PROFILES PANEL TABS
  // ==========================================
  Widget _buildProfilesPanel() {
    final profilesAsync = ref.watch(filteredAdminProfilesProvider);

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
            hintText: 'Search staff profiles by name...',
            showClearButton: _profileSearchController.text.isNotEmpty,
            onClear: () {
              _profileSearchController.clear();
              ref.read(adminProfilesSearchQueryProvider.notifier).update("");
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Profiles list
          Expanded(
            child: profilesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading profiles: $e')),
              data: (profiles) {
                if (profiles.isEmpty) {
                  return const Center(
                    child: Text('No staff profiles found.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  );
                }

                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(
                            profile.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Staff ID: ${profile.id.substring(0, 8)}...',
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _statusChip(profile.isActive),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 22),
                                onPressed: () => _openProfileForm(context, profile),
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

  /// Small beautiful M3 active/inactive status chip
  Widget _statusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
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

class _VendorFormSheetState extends ConsumerState<_VendorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  bool _isActive = true;
  bool _isSaving = false;

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

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final contact = _contactController.text.trim();

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

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor details saved successfully!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanMessage), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.verticalMd,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pinned Sticky Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.vendorToEdit == null ? 'Add New Vendor' : 'Edit Vendor Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24, indent: 24, endIndent: 24),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                borderRadius: AppRadius.brXs,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
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
                                        title: const Text('Operational Status'),
                                        subtitle: const Text('Toggle between Active and Inactive availability'),
                                        value: _isActive,
                                        activeThumbColor: Theme.of(context).colorScheme.primary,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (val) => setState(() => _isActive = val),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _submit,
                                child: _isSaving
                                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                                    : const Text('SAVE VENDOR RECORD'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isActive = true;
  bool _isSaving = false;

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

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();

      if (widget.categoryToEdit == null) {
        await ref.read(adminCategoriesProvider.notifier).addCategory(name: name);
      } else {
        await ref.read(adminCategoriesProvider.notifier).editCategory(
              id: widget.categoryToEdit!.id,
              name: name,
              isActive: _isActive,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category saved successfully!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanMessage), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.verticalMd,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pinned Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.categoryToEdit == null ? 'Add Expense Category' : 'Edit Category Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24, indent: 24, endIndent: 24),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                borderRadius: AppRadius.brXs,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
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
                                        title: const Text('Category Availability'),
                                        subtitle: const Text('Toggle between Active and Inactive (hides from dropdowns)'),
                                        value: _isActive,
                                        activeThumbColor: Theme.of(context).colorScheme.primary,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (val) => setState(() => _isActive = val),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _submit,
                                child: _isSaving
                                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                                    : const Text('SAVE EXPENSE CATEGORY'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. STAFF PROFILE BOTTOM SHEET FORM EDITOR
// ============================================================================
class _ProfileFormSheet extends ConsumerStatefulWidget {
  final Profile profileToEdit;

  const _ProfileFormSheet({required this.profileToEdit});

  @override
  ConsumerState<_ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends ConsumerState<_ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileToEdit.displayName);
    _isActive = widget.profileToEdit.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();

      await ref.read(adminProfilesProvider.notifier).editProfile(
            id: widget.profileToEdit.id,
            displayName: name,
            isActive: _isActive,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff profile saved successfully!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.verticalMd,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pinned Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Staff Profile',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24, indent: 24, endIndent: 24),

                    // Scrollable Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                borderRadius: AppRadius.brXs,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Staff Profile Details',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Staff Display Name * (NO SPACES)',
                                        prefixIcon: Icon(Icons.person_outline_rounded),
                                        hintText: 'e.g. RameshPatel (letters/numbers only)',
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter a display name';
                                        }
                                        if (val.trim().contains(' ')) {
                                          return 'Spaces are NOT allowed (Database requirement)';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    SwitchListTile(
                                      title: const Text('Staff Activity'),
                                      subtitle: const Text('Toggle to enable/disable staff transaction log access'),
                                      value: _isActive,
                                      activeThumbColor: Theme.of(context).colorScheme.primary,
                                      contentPadding: EdgeInsets.zero,
                                      onChanged: (val) => setState(() => _isActive = val),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _submit,
                                child: _isSaving
                                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                                    : const Text('SAVE PROFILE DETAILS'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

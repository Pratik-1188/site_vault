// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides ExpenseRepository singleton

@ProviderFor(expenseRepository)
final expenseRepositoryProvider = ExpenseRepositoryProvider._();

/// Provides ExpenseRepository singleton

final class ExpenseRepositoryProvider
    extends
        $FunctionalProvider<
          ExpenseRepository,
          ExpenseRepository,
          ExpenseRepository
        >
    with $Provider<ExpenseRepository> {
  /// Provides ExpenseRepository singleton
  ExpenseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpenseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpenseRepository create(Ref ref) {
    return expenseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseRepository>(value),
    );
  }
}

String _$expenseRepositoryHash() => r'f154bd4452384266c36318d0a05718c2de641625';

/// Dynamic categories list fetch from database

@ProviderFor(expenseCategories)
final expenseCategoriesProvider = ExpenseCategoriesProvider._();

/// Dynamic categories list fetch from database

final class ExpenseCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseCategory>>,
          List<ExpenseCategory>,
          FutureOr<List<ExpenseCategory>>
        >
    with
        $FutureModifier<List<ExpenseCategory>>,
        $FutureProvider<List<ExpenseCategory>> {
  /// Dynamic categories list fetch from database
  ExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExpenseCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseCategory>> create(Ref ref) {
    return expenseCategories(ref);
  }
}

String _$expenseCategoriesHash() => r'3276d17f1ca46eab4a032a7c47c9dce125716184';

/// Dynamic vendors list fetch from database

@ProviderFor(vendors)
final vendorsProvider = VendorsProvider._();

/// Dynamic vendors list fetch from database

final class VendorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vendor>>,
          List<Vendor>,
          FutureOr<List<Vendor>>
        >
    with $FutureModifier<List<Vendor>>, $FutureProvider<List<Vendor>> {
  /// Dynamic vendors list fetch from database
  VendorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vendorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vendorsHash();

  @$internal
  @override
  $FutureProviderElement<List<Vendor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vendor>> create(Ref ref) {
    return vendors(ref);
  }
}

String _$vendorsHash() => r'74178d29653eb9fa84d9d29bd479cb36ed83826b';

/// Dynamic user profiles list fetch from database (for created_by & paid_by linking)

@ProviderFor(profiles)
final profilesProvider = ProfilesProvider._();

/// Dynamic user profiles list fetch from database (for created_by & paid_by linking)

final class ProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          FutureOr<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $FutureProvider<List<Profile>> {
  /// Dynamic user profiles list fetch from database (for created_by & paid_by linking)
  ProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesHash();

  @$internal
  @override
  $FutureProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Profile>> create(Ref ref) {
    return profiles(ref);
  }
}

String _$profilesHash() => r'f31f89b80b2d96ec462690e12d4cde212077dc1f';

/// Selected category filter (null = All)

@ProviderFor(ExpenseCategoryFilter)
final expenseCategoryFilterProvider = ExpenseCategoryFilterProvider._();

/// Selected category filter (null = All)
final class ExpenseCategoryFilterProvider
    extends $NotifierProvider<ExpenseCategoryFilter, String?> {
  /// Selected category filter (null = All)
  ExpenseCategoryFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoryFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoryFilterHash();

  @$internal
  @override
  ExpenseCategoryFilter create() => ExpenseCategoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$expenseCategoryFilterHash() =>
    r'97860a05f69ce56008d40ed652c2dcc0d2491ad7';

/// Selected category filter (null = All)

abstract class _$ExpenseCategoryFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Selected vendor filter (null = All)

@ProviderFor(ExpenseVendorFilter)
final expenseVendorFilterProvider = ExpenseVendorFilterProvider._();

/// Selected vendor filter (null = All)
final class ExpenseVendorFilterProvider
    extends $NotifierProvider<ExpenseVendorFilter, String?> {
  /// Selected vendor filter (null = All)
  ExpenseVendorFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseVendorFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseVendorFilterHash();

  @$internal
  @override
  ExpenseVendorFilter create() => ExpenseVendorFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$expenseVendorFilterHash() =>
    r'70c571d5598c1c5b18753336d9f6ae517a8e9f17';

/// Selected vendor filter (null = All)

abstract class _$ExpenseVendorFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Active text search query filter

@ProviderFor(ExpenseSearchQuery)
final expenseSearchQueryProvider = ExpenseSearchQueryProvider._();

/// Active text search query filter
final class ExpenseSearchQueryProvider
    extends $NotifierProvider<ExpenseSearchQuery, String> {
  /// Active text search query filter
  ExpenseSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseSearchQueryHash();

  @$internal
  @override
  ExpenseSearchQuery create() => ExpenseSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$expenseSearchQueryHash() =>
    r'1d3f19e47571be694695c62d8aea044d57cb4373';

/// Active text search query filter

abstract class _$ExpenseSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Async controller for managing all active site-specific expenses.
///
/// Implements database read, write, update, and soft-delete operations
/// while reactively notifying dependent widgets.

@ProviderFor(SiteExpenses)
final siteExpensesProvider = SiteExpensesFamily._();

/// Async controller for managing all active site-specific expenses.
///
/// Implements database read, write, update, and soft-delete operations
/// while reactively notifying dependent widgets.
final class SiteExpensesProvider
    extends $AsyncNotifierProvider<SiteExpenses, List<Expense>> {
  /// Async controller for managing all active site-specific expenses.
  ///
  /// Implements database read, write, update, and soft-delete operations
  /// while reactively notifying dependent widgets.
  SiteExpensesProvider._({
    required SiteExpensesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteExpensesHash();

  @override
  String toString() {
    return r'siteExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SiteExpenses create() => SiteExpenses();

  @override
  bool operator ==(Object other) {
    return other is SiteExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteExpensesHash() => r'36d2a41a8e110f766323fe8a3a9ea6115070267a';

/// Async controller for managing all active site-specific expenses.
///
/// Implements database read, write, update, and soft-delete operations
/// while reactively notifying dependent widgets.

final class SiteExpensesFamily extends $Family
    with
        $ClassFamilyOverride<
          SiteExpenses,
          AsyncValue<List<Expense>>,
          List<Expense>,
          FutureOr<List<Expense>>,
          String
        > {
  SiteExpensesFamily._()
    : super(
        retry: null,
        name: r'siteExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Async controller for managing all active site-specific expenses.
  ///
  /// Implements database read, write, update, and soft-delete operations
  /// while reactively notifying dependent widgets.

  SiteExpensesProvider call(String siteId) =>
      SiteExpensesProvider._(argument: siteId, from: this);

  @override
  String toString() => r'siteExpensesProvider';
}

/// Async controller for managing all active site-specific expenses.
///
/// Implements database read, write, update, and soft-delete operations
/// while reactively notifying dependent widgets.

abstract class _$SiteExpenses extends $AsyncNotifier<List<Expense>> {
  late final _$args = ref.$arg as String;
  String get siteId => _$args;

  FutureOr<List<Expense>> build(String siteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Expense>>, List<Expense>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Expense>>, List<Expense>>,
              AsyncValue<List<Expense>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Filtered expenses selector combining data lists with active searches and tags

@ProviderFor(filteredSiteExpenses)
final filteredSiteExpensesProvider = FilteredSiteExpensesFamily._();

/// Filtered expenses selector combining data lists with active searches and tags

final class FilteredSiteExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expense>>,
          List<Expense>,
          FutureOr<List<Expense>>
        >
    with $FutureModifier<List<Expense>>, $FutureProvider<List<Expense>> {
  /// Filtered expenses selector combining data lists with active searches and tags
  FilteredSiteExpensesProvider._({
    required FilteredSiteExpensesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredSiteExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredSiteExpensesHash();

  @override
  String toString() {
    return r'filteredSiteExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Expense>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Expense>> create(Ref ref) {
    final argument = this.argument as String;
    return filteredSiteExpenses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredSiteExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredSiteExpensesHash() =>
    r'1befa4ca75f8abb9d17246866cfbfe17b9cff55c';

/// Filtered expenses selector combining data lists with active searches and tags

final class FilteredSiteExpensesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Expense>>, String> {
  FilteredSiteExpensesFamily._()
    : super(
        retry: null,
        name: r'filteredSiteExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filtered expenses selector combining data lists with active searches and tags

  FilteredSiteExpensesProvider call(String siteId) =>
      FilteredSiteExpensesProvider._(argument: siteId, from: this);

  @override
  String toString() => r'filteredSiteExpensesProvider';
}

/// Reactive aggregate summation calculator that watches the site's cached expenses list
/// and computes the total invoice sum in-memory for instant visual responsiveness.

@ProviderFor(siteTotalExpenses)
final siteTotalExpensesProvider = SiteTotalExpensesFamily._();

/// Reactive aggregate summation calculator that watches the site's cached expenses list
/// and computes the total invoice sum in-memory for instant visual responsiveness.

final class SiteTotalExpensesProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Reactive aggregate summation calculator that watches the site's cached expenses list
  /// and computes the total invoice sum in-memory for instant visual responsiveness.
  SiteTotalExpensesProvider._({
    required SiteTotalExpensesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteTotalExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteTotalExpensesHash();

  @override
  String toString() {
    return r'siteTotalExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return siteTotalExpenses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteTotalExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteTotalExpensesHash() => r'34d28b7c13fe323e02e31f315b3dbca2a57d88e1';

/// Reactive aggregate summation calculator that watches the site's cached expenses list
/// and computes the total invoice sum in-memory for instant visual responsiveness.

final class SiteTotalExpensesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  SiteTotalExpensesFamily._()
    : super(
        retry: null,
        name: r'siteTotalExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reactive aggregate summation calculator that watches the site's cached expenses list
  /// and computes the total invoice sum in-memory for instant visual responsiveness.

  SiteTotalExpensesProvider call(String siteId) =>
      SiteTotalExpensesProvider._(argument: siteId, from: this);

  @override
  String toString() => r'siteTotalExpensesProvider';
}

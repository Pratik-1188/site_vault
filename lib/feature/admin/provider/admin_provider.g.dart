// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the AdminRepository singleton.

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

/// Provides the AdminRepository singleton.

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  /// Provides the AdminRepository singleton.
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'c63131b371feee7f33b1353999fea8c5d201a4a8';

@ProviderFor(AdminVendorsSearchQuery)
final adminVendorsSearchQueryProvider = AdminVendorsSearchQueryProvider._();

final class AdminVendorsSearchQueryProvider
    extends $NotifierProvider<AdminVendorsSearchQuery, String> {
  AdminVendorsSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminVendorsSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminVendorsSearchQueryHash();

  @$internal
  @override
  AdminVendorsSearchQuery create() => AdminVendorsSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$adminVendorsSearchQueryHash() =>
    r'b3e4574a30370a1dbedde35a8dc386a1680effc9';

abstract class _$AdminVendorsSearchQuery extends $Notifier<String> {
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

@ProviderFor(AdminCategoriesSearchQuery)
final adminCategoriesSearchQueryProvider =
    AdminCategoriesSearchQueryProvider._();

final class AdminCategoriesSearchQueryProvider
    extends $NotifierProvider<AdminCategoriesSearchQuery, String> {
  AdminCategoriesSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminCategoriesSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminCategoriesSearchQueryHash();

  @$internal
  @override
  AdminCategoriesSearchQuery create() => AdminCategoriesSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$adminCategoriesSearchQueryHash() =>
    r'fe7338964c2ac8fb21cb0a7592b8690db587cf1e';

abstract class _$AdminCategoriesSearchQuery extends $Notifier<String> {
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

@ProviderFor(AdminProfilesSearchQuery)
final adminProfilesSearchQueryProvider = AdminProfilesSearchQueryProvider._();

final class AdminProfilesSearchQueryProvider
    extends $NotifierProvider<AdminProfilesSearchQuery, String> {
  AdminProfilesSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminProfilesSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminProfilesSearchQueryHash();

  @$internal
  @override
  AdminProfilesSearchQuery create() => AdminProfilesSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$adminProfilesSearchQueryHash() =>
    r'9ed21f88e3e8356aeaf2a979027779992189fe56';

abstract class _$AdminProfilesSearchQuery extends $Notifier<String> {
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

@ProviderFor(AdminVendors)
final adminVendorsProvider = AdminVendorsProvider._();

final class AdminVendorsProvider
    extends $AsyncNotifierProvider<AdminVendors, List<Vendor>> {
  AdminVendorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminVendorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminVendorsHash();

  @$internal
  @override
  AdminVendors create() => AdminVendors();
}

String _$adminVendorsHash() => r'06a2972f000807c069637dd13a381a6965c13f14';

abstract class _$AdminVendors extends $AsyncNotifier<List<Vendor>> {
  FutureOr<List<Vendor>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Vendor>>, List<Vendor>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Vendor>>, List<Vendor>>,
              AsyncValue<List<Vendor>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminCategories)
final adminCategoriesProvider = AdminCategoriesProvider._();

final class AdminCategoriesProvider
    extends $AsyncNotifierProvider<AdminCategories, List<ExpenseCategory>> {
  AdminCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminCategoriesHash();

  @$internal
  @override
  AdminCategories create() => AdminCategories();
}

String _$adminCategoriesHash() => r'4eff7b08dc25b17729c79f6ccbdbf1750beb8cd3';

abstract class _$AdminCategories extends $AsyncNotifier<List<ExpenseCategory>> {
  FutureOr<List<ExpenseCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ExpenseCategory>>, List<ExpenseCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExpenseCategory>>,
                List<ExpenseCategory>
              >,
              AsyncValue<List<ExpenseCategory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminProfiles)
final adminProfilesProvider = AdminProfilesProvider._();

final class AdminProfilesProvider
    extends $AsyncNotifierProvider<AdminProfiles, List<Profile>> {
  AdminProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminProfilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminProfilesHash();

  @$internal
  @override
  AdminProfiles create() => AdminProfiles();
}

String _$adminProfilesHash() => r'19f6d135866e404694b5d3d95fe2f2b17c9c8920';

abstract class _$AdminProfiles extends $AsyncNotifier<List<Profile>> {
  FutureOr<List<Profile>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Profile>>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Profile>>, List<Profile>>,
              AsyncValue<List<Profile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredAdminVendors)
final filteredAdminVendorsProvider = FilteredAdminVendorsProvider._();

final class FilteredAdminVendorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vendor>>,
          List<Vendor>,
          FutureOr<List<Vendor>>
        >
    with $FutureModifier<List<Vendor>>, $FutureProvider<List<Vendor>> {
  FilteredAdminVendorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredAdminVendorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredAdminVendorsHash();

  @$internal
  @override
  $FutureProviderElement<List<Vendor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vendor>> create(Ref ref) {
    return filteredAdminVendors(ref);
  }
}

String _$filteredAdminVendorsHash() =>
    r'1c6c1d499e2b06474b930530e6938903b094ffd7';

@ProviderFor(filteredAdminCategories)
final filteredAdminCategoriesProvider = FilteredAdminCategoriesProvider._();

final class FilteredAdminCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseCategory>>,
          List<ExpenseCategory>,
          FutureOr<List<ExpenseCategory>>
        >
    with
        $FutureModifier<List<ExpenseCategory>>,
        $FutureProvider<List<ExpenseCategory>> {
  FilteredAdminCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredAdminCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredAdminCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExpenseCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseCategory>> create(Ref ref) {
    return filteredAdminCategories(ref);
  }
}

String _$filteredAdminCategoriesHash() =>
    r'aaccd1b7fa1b4be124c3e1f4ce87666036094552';

@ProviderFor(filteredAdminProfiles)
final filteredAdminProfilesProvider = FilteredAdminProfilesProvider._();

final class FilteredAdminProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          FutureOr<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $FutureProvider<List<Profile>> {
  FilteredAdminProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredAdminProfilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredAdminProfilesHash();

  @$internal
  @override
  $FutureProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Profile>> create(Ref ref) {
    return filteredAdminProfiles(ref);
  }
}

String _$filteredAdminProfilesHash() =>
    r'7162e7cb1a300b23c6e7b51603a24f2df169c1d6';

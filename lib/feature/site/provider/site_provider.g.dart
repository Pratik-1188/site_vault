// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides SiteRepository

@ProviderFor(siteRepository)
final siteRepositoryProvider = SiteRepositoryProvider._();

/// Provides SiteRepository

final class SiteRepositoryProvider
    extends $FunctionalProvider<SiteRepository, SiteRepository, SiteRepository>
    with $Provider<SiteRepository> {
  /// Provides SiteRepository
  SiteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteRepositoryHash();

  @$internal
  @override
  $ProviderElement<SiteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SiteRepository create(Ref ref) {
    return siteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiteRepository>(value),
    );
  }
}

String _$siteRepositoryHash() => r'6a9018dfcd34695d925af7a8f16737d31f702b2f';

/// Selected firm filter (null = none selected on startup)

@ProviderFor(SelectedFirm)
final selectedFirmProvider = SelectedFirmProvider._();

/// Selected firm filter (null = none selected on startup)
final class SelectedFirmProvider
    extends $NotifierProvider<SelectedFirm, String?> {
  /// Selected firm filter (null = none selected on startup)
  SelectedFirmProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFirmProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFirmHash();

  @$internal
  @override
  SelectedFirm create() => SelectedFirm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedFirmHash() => r'51f395f00147d3ed6380d69ba5ac177561753904';

/// Selected firm filter (null = none selected on startup)

abstract class _$SelectedFirm extends $Notifier<String?> {
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

/// Selected status filter (defaults to 'active')

@ProviderFor(SelectedStatus)
final selectedStatusProvider = SelectedStatusProvider._();

/// Selected status filter (defaults to 'active')
final class SelectedStatusProvider
    extends $NotifierProvider<SelectedStatus, String?> {
  /// Selected status filter (defaults to 'active')
  SelectedStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedStatusHash();

  @$internal
  @override
  SelectedStatus create() => SelectedStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedStatusHash() => r'dc38bee129dcd30862bba8cce83652417033c455';

/// Selected status filter (defaults to 'active')

abstract class _$SelectedStatus extends $Notifier<String?> {
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

/// Started date range filter (defaults to current financial year)

@ProviderFor(StartedDateRange)
final startedDateRangeProvider = StartedDateRangeProvider._();

/// Started date range filter (defaults to current financial year)
final class StartedDateRangeProvider
    extends $NotifierProvider<StartedDateRange, DateRange> {
  /// Started date range filter (defaults to current financial year)
  StartedDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startedDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startedDateRangeHash();

  @$internal
  @override
  StartedDateRange create() => StartedDateRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRange>(value),
    );
  }
}

String _$startedDateRangeHash() => r'bed0397cb2f917974d760c0e1be041aa9a3d73d4';

/// Started date range filter (defaults to current financial year)

abstract class _$StartedDateRange extends $Notifier<DateRange> {
  DateRange build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateRange, DateRange>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateRange, DateRange>,
              DateRange,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Search query for filtering sites by name (case-insensitive)

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// Search query for filtering sites by name (case-insensitive)
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Search query for filtering sites by name (case-insensitive)
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'cc991e509db94af944af1c6eb376eae17fbca4c0';

/// Search query for filtering sites by name (case-insensitive)

abstract class _$SearchQuery extends $Notifier<String> {
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

/// Fetches sites matching the current filters directly from Supabase (Server-side)

@ProviderFor(sites)
final sitesProvider = SitesProvider._();

/// Fetches sites matching the current filters directly from Supabase (Server-side)

final class SitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Site>>,
          List<Site>,
          FutureOr<List<Site>>
        >
    with $FutureModifier<List<Site>>, $FutureProvider<List<Site>> {
  /// Fetches sites matching the current filters directly from Supabase (Server-side)
  SitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sitesHash();

  @$internal
  @override
  $FutureProviderElement<List<Site>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Site>> create(Ref ref) {
    return sites(ref);
  }
}

String _$sitesHash() => r'859dd9f367f8e7cb19e3bd229e3474d17deb02a9';

/// Fetches details for a single site by its unique ID

@ProviderFor(siteDetails)
final siteDetailsProvider = SiteDetailsFamily._();

/// Fetches details for a single site by its unique ID

final class SiteDetailsProvider
    extends $FunctionalProvider<AsyncValue<Site>, Site, FutureOr<Site>>
    with $FutureModifier<Site>, $FutureProvider<Site> {
  /// Fetches details for a single site by its unique ID
  SiteDetailsProvider._({
    required SiteDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteDetailsHash();

  @override
  String toString() {
    return r'siteDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Site> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Site> create(Ref ref) {
    final argument = this.argument as String;
    return siteDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteDetailsHash() => r'e824e89c0d720f1031e71c512ecad30b36fa0996';

/// Fetches details for a single site by its unique ID

final class SiteDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Site>, String> {
  SiteDetailsFamily._()
    : super(
        retry: null,
        name: r'siteDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches details for a single site by its unique ID

  SiteDetailsProvider call(String siteId) =>
      SiteDetailsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'siteDetailsProvider';
}

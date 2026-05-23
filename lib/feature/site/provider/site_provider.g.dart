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

/// Fetches all sites from DB

@ProviderFor(sites)
final sitesProvider = SitesProvider._();

/// Fetches all sites from DB

final class SitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Site>>,
          List<Site>,
          FutureOr<List<Site>>
        >
    with $FutureModifier<List<Site>>, $FutureProvider<List<Site>> {
  /// Fetches all sites from DB
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

String _$sitesHash() => r'12f49fe2b7d30795414afb4de0b551a9b205ab1d';

/// Selected firm filter (null = All)

@ProviderFor(SelectedFirm)
final selectedFirmProvider = SelectedFirmProvider._();

/// Selected firm filter (null = All)
final class SelectedFirmProvider
    extends $NotifierProvider<SelectedFirm, String?> {
  /// Selected firm filter (null = All)
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

/// Selected firm filter (null = All)

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

/// Selected status filter (null = All)

@ProviderFor(SelectedStatus)
final selectedStatusProvider = SelectedStatusProvider._();

/// Selected status filter (null = All)
final class SelectedStatusProvider
    extends $NotifierProvider<SelectedStatus, String?> {
  /// Selected status filter (null = All)
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

String _$selectedStatusHash() => r'8faad3cfad967f4d3f27614a72364bc080182ede';

/// Selected status filter (null = All)

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

/// Started date range filter

@ProviderFor(StartedDateRange)
final startedDateRangeProvider = StartedDateRangeProvider._();

/// Started date range filter
final class StartedDateRangeProvider
    extends $NotifierProvider<StartedDateRange, DateRange> {
  /// Started date range filter
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

String _$startedDateRangeHash() => r'0fda43a095c69a5cc35538353e484fe7bcaeae3d';

/// Started date range filter

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

/// Visible count for pagination (infinite scroll)

@ProviderFor(VisibleCount)
final visibleCountProvider = VisibleCountProvider._();

/// Visible count for pagination (infinite scroll)
final class VisibleCountProvider extends $NotifierProvider<VisibleCount, int> {
  /// Visible count for pagination (infinite scroll)
  VisibleCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleCountHash();

  @$internal
  @override
  VisibleCount create() => VisibleCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$visibleCountHash() => r'40f1119199a1f27a738a48479181ce3a68aeb7dc';

/// Visible count for pagination (infinite scroll)

abstract class _$VisibleCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Combines data + filters + search and returns final list

@ProviderFor(filteredSites)
final filteredSitesProvider = FilteredSitesProvider._();

/// Combines data + filters + search and returns final list

final class FilteredSitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Site>>,
          List<Site>,
          FutureOr<List<Site>>
        >
    with $FutureModifier<List<Site>>, $FutureProvider<List<Site>> {
  /// Combines data + filters + search and returns final list
  FilteredSitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSitesHash();

  @$internal
  @override
  $FutureProviderElement<List<Site>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Site>> create(Ref ref) {
    return filteredSites(ref);
  }
}

String _$filteredSitesHash() => r'03d2ebd07e1493b8f6ad31502efe548f0ef70c10';

/// Slices the filtered sites for UI pagination

@ProviderFor(paginatedSites)
final paginatedSitesProvider = PaginatedSitesProvider._();

/// Slices the filtered sites for UI pagination

final class PaginatedSitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Site>>,
          List<Site>,
          FutureOr<List<Site>>
        >
    with $FutureModifier<List<Site>>, $FutureProvider<List<Site>> {
  /// Slices the filtered sites for UI pagination
  PaginatedSitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSitesHash();

  @$internal
  @override
  $FutureProviderElement<List<Site>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Site>> create(Ref ref) {
    return paginatedSites(ref);
  }
}

String _$paginatedSitesHash() => r'71a633e80222c9abcd72593ae7b35f445a6bbec5';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the AnalyticsRepository instance.

@ProviderFor(analyticsRepository)
final analyticsRepositoryProvider = AnalyticsRepositoryProvider._();

/// Provides the AnalyticsRepository instance.

final class AnalyticsRepositoryProvider
    extends
        $FunctionalProvider<
          AnalyticsRepository,
          AnalyticsRepository,
          AnalyticsRepository
        >
    with $Provider<AnalyticsRepository> {
  /// Provides the AnalyticsRepository instance.
  AnalyticsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnalyticsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalyticsRepository create(Ref ref) {
    return analyticsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRepository>(value),
    );
  }
}

String _$analyticsRepositoryHash() =>
    r'8a4202bbd186c4ac383eb1c754065e04be7f354c';

/// Provides a list of pre-aggregated firm summaries (Group-wide comparative totals).

@ProviderFor(groupFirmSummaries)
final groupFirmSummariesProvider = GroupFirmSummariesProvider._();

/// Provides a list of pre-aggregated firm summaries (Group-wide comparative totals).

final class GroupFirmSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FirmAnalyticsSummary>>,
          List<FirmAnalyticsSummary>,
          FutureOr<List<FirmAnalyticsSummary>>
        >
    with
        $FutureModifier<List<FirmAnalyticsSummary>>,
        $FutureProvider<List<FirmAnalyticsSummary>> {
  /// Provides a list of pre-aggregated firm summaries (Group-wide comparative totals).
  GroupFirmSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupFirmSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupFirmSummariesHash();

  @$internal
  @override
  $FutureProviderElement<List<FirmAnalyticsSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FirmAnalyticsSummary>> create(Ref ref) {
    return groupFirmSummaries(ref);
  }
}

String _$groupFirmSummariesHash() =>
    r'2c3cf4a56908ebfc300d1b93a5d2da0f5fd77f9a';

/// Provides a single pre-aggregated site summary (total spent, expense count, etc.).

@ProviderFor(siteSummary)
final siteSummaryProvider = SiteSummaryFamily._();

/// Provides a single pre-aggregated site summary (total spent, expense count, etc.).

final class SiteSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SiteAnalyticsSummary?>,
          SiteAnalyticsSummary?,
          FutureOr<SiteAnalyticsSummary?>
        >
    with
        $FutureModifier<SiteAnalyticsSummary?>,
        $FutureProvider<SiteAnalyticsSummary?> {
  /// Provides a single pre-aggregated site summary (total spent, expense count, etc.).
  SiteSummaryProvider._({
    required SiteSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteSummaryHash();

  @override
  String toString() {
    return r'siteSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SiteAnalyticsSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SiteAnalyticsSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return siteSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteSummaryHash() => r'f48aa78ef03e816350389e0b8423243002b049c0';

/// Provides a single pre-aggregated site summary (total spent, expense count, etc.).

final class SiteSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SiteAnalyticsSummary?>, String> {
  SiteSummaryFamily._()
    : super(
        retry: null,
        name: r'siteSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a single pre-aggregated site summary (total spent, expense count, etc.).

  SiteSummaryProvider call(String siteId) =>
      SiteSummaryProvider._(argument: siteId, from: this);

  @override
  String toString() => r'siteSummaryProvider';
}

/// Provides pre-aggregated category spending splits (supports optional filters by site or firm).

@ProviderFor(categorySpend)
final categorySpendProvider = CategorySpendFamily._();

/// Provides pre-aggregated category spending splits (supports optional filters by site or firm).

final class CategorySpendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategorySpendSummary>>,
          List<CategorySpendSummary>,
          FutureOr<List<CategorySpendSummary>>
        >
    with
        $FutureModifier<List<CategorySpendSummary>>,
        $FutureProvider<List<CategorySpendSummary>> {
  /// Provides pre-aggregated category spending splits (supports optional filters by site or firm).
  CategorySpendProvider._({
    required CategorySpendFamily super.from,
    required ({String? siteId, String? firmId}) super.argument,
  }) : super(
         retry: null,
         name: r'categorySpendProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categorySpendHash();

  @override
  String toString() {
    return r'categorySpendProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<CategorySpendSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategorySpendSummary>> create(Ref ref) {
    final argument = this.argument as ({String? siteId, String? firmId});
    return categorySpend(ref, siteId: argument.siteId, firmId: argument.firmId);
  }

  @override
  bool operator ==(Object other) {
    return other is CategorySpendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categorySpendHash() => r'1662cdfc47134b57746b440f49eba9fa88c71b2f';

/// Provides pre-aggregated category spending splits (supports optional filters by site or firm).

final class CategorySpendFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CategorySpendSummary>>,
          ({String? siteId, String? firmId})
        > {
  CategorySpendFamily._()
    : super(
        retry: null,
        name: r'categorySpendProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides pre-aggregated category spending splits (supports optional filters by site or firm).

  CategorySpendProvider call({String? siteId, String? firmId}) =>
      CategorySpendProvider._(
        argument: (siteId: siteId, firmId: firmId),
        from: this,
      );

  @override
  String toString() => r'categorySpendProvider';
}

/// Provides pre-aggregated chronological monthly cashflow trends.

@ProviderFor(monthlySpend)
final monthlySpendProvider = MonthlySpendFamily._();

/// Provides pre-aggregated chronological monthly cashflow trends.

final class MonthlySpendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlySpendTrend>>,
          List<MonthlySpendTrend>,
          FutureOr<List<MonthlySpendTrend>>
        >
    with
        $FutureModifier<List<MonthlySpendTrend>>,
        $FutureProvider<List<MonthlySpendTrend>> {
  /// Provides pre-aggregated chronological monthly cashflow trends.
  MonthlySpendProvider._({
    required MonthlySpendFamily super.from,
    required ({String? siteId, String? firmId}) super.argument,
  }) : super(
         retry: null,
         name: r'monthlySpendProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlySpendHash();

  @override
  String toString() {
    return r'monthlySpendProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<MonthlySpendTrend>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MonthlySpendTrend>> create(Ref ref) {
    final argument = this.argument as ({String? siteId, String? firmId});
    return monthlySpend(ref, siteId: argument.siteId, firmId: argument.firmId);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySpendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlySpendHash() => r'95500e7f76a5e712a7d0419b926080ffc850eba6';

/// Provides pre-aggregated chronological monthly cashflow trends.

final class MonthlySpendFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<MonthlySpendTrend>>,
          ({String? siteId, String? firmId})
        > {
  MonthlySpendFamily._()
    : super(
        retry: null,
        name: r'monthlySpendProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides pre-aggregated chronological monthly cashflow trends.

  MonthlySpendProvider call({String? siteId, String? firmId}) =>
      MonthlySpendProvider._(
        argument: (siteId: siteId, firmId: firmId),
        from: this,
      );

  @override
  String toString() => r'monthlySpendProvider';
}

/// Provides site-specific pre-aggregated vendor spending splits.

@ProviderFor(siteVendorSpend)
final siteVendorSpendProvider = SiteVendorSpendFamily._();

/// Provides site-specific pre-aggregated vendor spending splits.

final class SiteVendorSpendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VendorSpendSummary>>,
          List<VendorSpendSummary>,
          FutureOr<List<VendorSpendSummary>>
        >
    with
        $FutureModifier<List<VendorSpendSummary>>,
        $FutureProvider<List<VendorSpendSummary>> {
  /// Provides site-specific pre-aggregated vendor spending splits.
  SiteVendorSpendProvider._({
    required SiteVendorSpendFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteVendorSpendProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteVendorSpendHash();

  @override
  String toString() {
    return r'siteVendorSpendProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VendorSpendSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VendorSpendSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return siteVendorSpend(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteVendorSpendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteVendorSpendHash() => r'f88d673a558e43b35a5dd1fd433874c3e8bc5665';

/// Provides site-specific pre-aggregated vendor spending splits.

final class SiteVendorSpendFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VendorSpendSummary>>, String> {
  SiteVendorSpendFamily._()
    : super(
        retry: null,
        name: r'siteVendorSpendProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides site-specific pre-aggregated vendor spending splits.

  SiteVendorSpendProvider call(String siteId) =>
      SiteVendorSpendProvider._(argument: siteId, from: this);

  @override
  String toString() => r'siteVendorSpendProvider';
}

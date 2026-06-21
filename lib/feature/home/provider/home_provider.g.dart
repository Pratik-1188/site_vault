// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the HomeRepository instance.

@ProviderFor(_homeRepository)
final _homeRepositoryProvider = _HomeRepositoryProvider._();

/// Provides the HomeRepository instance.

final class _HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  /// Provides the HomeRepository instance.
  _HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_homeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return _homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$_homeRepositoryHash() => r'773ee7227e2e63706ba3752baef94c1d8da633d8';

/// Provides total expenses for the current financial year.

@ProviderFor(currentFinancialYearExpenseTotal)
final currentFinancialYearExpenseTotalProvider =
    CurrentFinancialYearExpenseTotalProvider._();

/// Provides total expenses for the current financial year.

final class CurrentFinancialYearExpenseTotalProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Provides total expenses for the current financial year.
  CurrentFinancialYearExpenseTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentFinancialYearExpenseTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentFinancialYearExpenseTotalHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return currentFinancialYearExpenseTotal(ref);
  }
}

String _$currentFinancialYearExpenseTotalHash() =>
    r'cb2f6aa0197b3c9ed29a3e325b8cc92e828f6037';

/// Provides count of active sites in the current financial year.

@ProviderFor(activeSitesForCurrentFinancialYear)
final activeSitesForCurrentFinancialYearProvider =
    ActiveSitesForCurrentFinancialYearProvider._();

/// Provides count of active sites in the current financial year.

final class ActiveSitesForCurrentFinancialYearProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provides count of active sites in the current financial year.
  ActiveSitesForCurrentFinancialYearProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSitesForCurrentFinancialYearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$activeSitesForCurrentFinancialYearHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return activeSitesForCurrentFinancialYear(ref);
  }
}

String _$activeSitesForCurrentFinancialYearHash() =>
    r'f03092bae73ef945f87c86f4eca05e163252fdb9';

/// Provides sum of expenses with missing bill attachments in the current financial year.

@ProviderFor(missingBillExpenseTotalForCurrentFinancialYear)
final missingBillExpenseTotalForCurrentFinancialYearProvider =
    MissingBillExpenseTotalForCurrentFinancialYearProvider._();

/// Provides sum of expenses with missing bill attachments in the current financial year.

final class MissingBillExpenseTotalForCurrentFinancialYearProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Provides sum of expenses with missing bill attachments in the current financial year.
  MissingBillExpenseTotalForCurrentFinancialYearProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missingBillExpenseTotalForCurrentFinancialYearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$missingBillExpenseTotalForCurrentFinancialYearHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return missingBillExpenseTotalForCurrentFinancialYear(ref);
  }
}

String _$missingBillExpenseTotalForCurrentFinancialYearHash() =>
    r'31cebd9d3ddd4e3ed501b115063453816c1f5d59';

/// Provides latest 4 audit log entries.

@ProviderFor(recentAuditLogs)
final recentAuditLogsProvider = RecentAuditLogsProvider._();

/// Provides latest 4 audit log entries.

final class RecentAuditLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Provides latest 4 audit log entries.
  RecentAuditLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentAuditLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentAuditLogsHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return recentAuditLogs(ref);
  }
}

String _$recentAuditLogsHash() => r'0bb94a53b6b0ce40429ed9f4f97a59dd79882731';

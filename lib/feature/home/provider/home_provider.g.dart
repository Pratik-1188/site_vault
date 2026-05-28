// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the HomeRepository instance.

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

/// Provides the HomeRepository instance.

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  /// Provides the HomeRepository instance.
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'6457281048293a3fab3fdbf608cddcb6728ae405';

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
    r'1ec9b872583e7aa1d8b0003aca727c848b1f061f';

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
    r'bc938c79735b94509548741ebaa7db2ac4a52273';

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
    r'062181e28869bd9f314b7375a1be56a90410a0f9';

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

String _$recentAuditLogsHash() => r'1dcd80d8e3def3903f39969855c3e0911712894a';

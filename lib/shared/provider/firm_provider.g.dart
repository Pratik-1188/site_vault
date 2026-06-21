// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides FirmRepository

@ProviderFor(_firmRepository)
final _firmRepositoryProvider = _FirmRepositoryProvider._();

/// Provides FirmRepository

final class _FirmRepositoryProvider
    extends $FunctionalProvider<FirmRepository, FirmRepository, FirmRepository>
    with $Provider<FirmRepository> {
  /// Provides FirmRepository
  _FirmRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_firmRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_firmRepositoryHash();

  @$internal
  @override
  $ProviderElement<FirmRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirmRepository create(Ref ref) {
    return _firmRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirmRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirmRepository>(value),
    );
  }
}

String _$_firmRepositoryHash() => r'cfc6f8d22b4de9a50067e97de9913fa42bb04b76';

/// Fetches all firms

@ProviderFor(firms)
final firmsProvider = FirmsProvider._();

/// Fetches all firms

final class FirmsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Firm>>,
          List<Firm>,
          FutureOr<List<Firm>>
        >
    with $FutureModifier<List<Firm>>, $FutureProvider<List<Firm>> {
  /// Fetches all firms
  FirmsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firmsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firmsHash();

  @$internal
  @override
  $FutureProviderElement<List<Firm>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Firm>> create(Ref ref) {
    return firms(ref);
  }
}

String _$firmsHash() => r'9f5a7f842e384be3b1cd32620e606a47d9a4d45a';

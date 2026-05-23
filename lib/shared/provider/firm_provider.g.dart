// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides FirmRepository

@ProviderFor(firmRepository)
final firmRepositoryProvider = FirmRepositoryProvider._();

/// Provides FirmRepository

final class FirmRepositoryProvider
    extends $FunctionalProvider<FirmRepository, FirmRepository, FirmRepository>
    with $Provider<FirmRepository> {
  /// Provides FirmRepository
  FirmRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firmRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firmRepositoryHash();

  @$internal
  @override
  $ProviderElement<FirmRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirmRepository create(Ref ref) {
    return firmRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirmRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirmRepository>(value),
    );
  }
}

String _$firmRepositoryHash() => r'fa4657a0a98ace450be78bdd9bafc9b012a798fc';

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

String _$firmsHash() => r'3f7065447633133a7d45af819da9b24f5f0e3de5';

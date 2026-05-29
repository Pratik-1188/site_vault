// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A reactive, Riverpod-generated GoRouter provider for the application.
///
/// Automatically guards routes:
/// - Redirects unauthenticated users to `/login`
/// - Redirects authenticated users away from `/login` to `/`

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// A reactive, Riverpod-generated GoRouter provider for the application.
///
/// Automatically guards routes:
/// - Redirects unauthenticated users to `/login`
/// - Redirects authenticated users away from `/login` to `/`

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// A reactive, Riverpod-generated GoRouter provider for the application.
  ///
  /// Automatically guards routes:
  /// - Redirects unauthenticated users to `/login`
  /// - Redirects authenticated users away from `/login` to `/`
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'ca0d4699a4f0e19fa2fb5f99a73f1e803eb8aed7';

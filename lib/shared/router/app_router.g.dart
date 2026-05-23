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

String _$appRouterHash() => r'dd759612c675472f9c9a83ebad6f5cdf7c9e3d34';

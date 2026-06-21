import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension on [WidgetRef] to support a unified, asynchronous refresh of multiple providers.
extension WidgetRefRefresh on WidgetRef {
  /// Invalidates the list of [providers] and awaits the completion of [futures] (if provided),
  /// ensuring that pull-to-refresh indicators remain active until reloading is complete.
  Future<void> refreshProviders({
    required List<dynamic> providers,
    List<Future<dynamic>> futures = const [],
  }) async {
    for (final provider in providers) {
      invalidate(provider);
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
}

/// Extension on [Ref] to support a unified, asynchronous refresh of multiple providers.
extension RefRefresh on Ref {
  /// Invalidates the list of [providers] and awaits the completion of [futures] (if provided),
  /// ensuring that pull-to-refresh indicators remain active until reloading is complete.
  Future<void> refreshProviders({
    required List<dynamic> providers,
    List<Future<dynamic>> futures = const [],
  }) async {
    for (final provider in providers) {
      invalidate(provider);
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
}

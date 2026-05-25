import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract base class for all Supabase repositories.
///
/// Provides a centralized [safeCall] runner that wraps every database
/// operation in consistent error handling and logging. To integrate a
/// crash-reporting service (e.g. Sentry, Crashlytics) in the future,
/// update this single method — no other files need to change.
abstract class BaseRepository {
  final SupabaseClient client;

  BaseRepository(this.client);

  /// Executes [action] and surfaces any exception back to the caller.
  ///
  /// [context] is a human-readable label (e.g. `'SiteRepository.fetchSites'`)
  /// used to identify the failing operation in logs.
  ///
  /// Uses [debugPrint] which is automatically suppressed in release builds,
  /// unlike raw [print].
  Future<T> safeCall<T>(String context, Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, stack) {
      debugPrint('[$context] Error: $e');
      debugPrint('[$context] Stack: $stack');
      rethrow;
    }
  }
}

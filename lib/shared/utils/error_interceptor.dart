import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';

/// Centralized interceptor for managing Supabase database exceptions.
///
/// Ensures unauthenticated/invalid sessions (401 status) trigger a global
/// sign-out, reactively redirecting users to the login screen.
class SupabaseErrorInterceptor {
  /// Analyzes the exception, triggers global sign-out if needed, and
  /// returns a user-friendly error message.
  static String handle(dynamic error, dynamic ref) {
    if (error is PostgrestException) {
      final code = error.code;
      final msg = error.message.toLowerCase();

      // 1. Unauthenticated or Dead Session (e.g. DB Reset, User Deleted, JWT expired)
      if (code == '401' || 
          code == 'PGRST301' || 
          msg.contains('jwt') || 
          msg.contains('unauthorized') || 
          msg.contains('invalid claim') ||
          msg.contains('user not found')) {
        // Kick the user out globally
        ref.read(authActionsProvider).signOut();
        return "Session expired or invalid. Please log in again.";
      }

      // 2. Insufficient Privileges (Authorization RLS checks)
      if (code == '42501') {
        return "Access Denied: You do not have permission to perform this action.";
      }

      // 3. Unique Constraint Violation (e.g., duplicate names)
      if (code == '23505') {
        return "This record already exists in the database.";
      }

      return error.message;
    }

    if (error is AuthException) {
      // Any session validation or refresh failure means the session is dead
      ref.read(authActionsProvider).signOut();
      return error.message;
    }

    return error?.toString() ?? "An unexpected error occurred.";
  }

  /// Overload for ProviderObserver which operates on ProviderContainer instead of Ref.
  static void handleWithContainer(dynamic error, ProviderContainer container) {
    if (error is PostgrestException) {
      final code = error.code;
      final msg = error.message.toLowerCase();

      if (code == '401' || 
          code == 'PGRST301' || 
          msg.contains('jwt') || 
          msg.contains('unauthorized') || 
          msg.contains('invalid claim') ||
          msg.contains('user not found')) {
        container.read(authActionsProvider).signOut();
      }
    } else if (error is AuthException) {
      container.read(authActionsProvider).signOut();
    }
  }
}

/// A global Riverpod observer that intercepts any AsyncError in any provider,
/// automatically signing the user out if an auth/session failure is detected.
base class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError) {
      SupabaseErrorInterceptor.handleWithContainer(newValue.error, context.container);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';

/// A centralized handler for clean intercepting, formatting, and displaying
/// errors to users via consistent UI/UX overlays.
class AppErrorHandler {
  AppErrorHandler._();

  /// Intercepts [error], parses it into a user-friendly text message, and
  /// displays an error snackbar overlay.
  ///
  /// Passes the [ref] (which can be WidgetRef or Ref) down to the interceptor
  /// to trigger automatic logout/redirection in case of expired authentication sessions.
  static void show(BuildContext context, Object error, dynamic ref) {
    final cleanMessage = SupabaseErrorInterceptor.handle(error, ref);
    AppSnackBar.showError(context, cleanMessage);
  }
}

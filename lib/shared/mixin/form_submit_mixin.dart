import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';

/// A mixin that provides standardized form submission state management and error handling
/// for Riverpod ConsumerState classes.
mixin FormSubmitMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isSubmitting = false;

  /// Exposes the current submission status of the form.
  bool get isSubmitting => _isSubmitting;

  /// Runs the provided asynchronous [action] with a loading state, catch-block interceptor
  /// for Supabase/network errors, and success messaging.
  ///
  /// Automatically calls [setState] to update the [isSubmitting] status.
  /// Pops the navigation route upon successful completion, unless [popOnSuccess] is false.
  Future<void> runFormSubmit({
    required Future<void> Function() action,
    required String successMessage,
    bool popOnSuccess = true,
    VoidCallback? onSuccess,
  }) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await action();
      if (mounted) {
        if (popOnSuccess) {
          Navigator.pop(context);
        }
        if (onSuccess != null) {
          onSuccess();
        }
        AppSnackBar.showSuccess(context, successMessage);
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        AppSnackBar.showError(context, cleanMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';
import 'package:site_vault/shared/widget/confirmation_dialogs.dart';

/// A self-contained popup menu button for user profile options (specifically Sign Out),
/// which handles confirmation, signing out via Riverpod provider, and error handling.
class SignOutMenuButton extends ConsumerWidget {
  const SignOutMenuButton({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialogs.confirm(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of KK Group Site Vault?',
      confirmLabel: 'SIGN OUT',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      try {
        await ref.read(authActionsProvider).signOut();
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.showError(context, 'Error signing out: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.account_circle_rounded,
        size: 28,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      tooltip: 'User Profile Options',
      onSelected: (val) {
        if (val == 'signout') {
          _handleSignOut(context, ref);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Sign Out'),
            ],
          ),
        ),
      ],
    );
  }
}

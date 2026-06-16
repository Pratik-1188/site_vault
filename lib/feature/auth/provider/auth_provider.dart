import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/auth/repository/auth_repository.dart';
import 'package:site_vault/shared/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Provides the AuthRepository instance.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final client = Supabase.instance.client;
  return AuthRepository(client);
}

/// Provides a real-time stream of the current Supabase AuthState.
@riverpod
Stream<AuthState> authState(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateStream;
}

/// Returns the currently authenticated Supabase user, if any.
final currentAuthUserProvider = Provider<User?>((ref) {
  final authStateVal = ref.watch(authStateProvider);

  return authStateVal.value?.session?.user ??
      ref.watch(authRepositoryProvider).currentUser;
});

/// Auth actions exposed to the UI through Riverpod.
class AuthActions {
  AuthActions(this.ref);
  final Ref ref;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    return repo.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
  }
}

final authActionsProvider = Provider<AuthActions>((ref) => AuthActions(ref));

/// Fetches the profile record of the currently logged-in user.
@riverpod
Future<Profile?> currentUserProfile(Ref ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return null;

  final client = Supabase.instance.client;
  try {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return Profile.fromJson(response);
  } catch (e) {
    // ignore: avoid_print
    print('Error loading currentUserProfile: $e');
    return null;
  }
}

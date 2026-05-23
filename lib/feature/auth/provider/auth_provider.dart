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

/// Fetches the profile record of the currently logged-in user.
@riverpod
Future<Profile?> currentUserProfile(Ref ref) async {
  final authStateVal = ref.watch(authStateProvider);
  
  // Use session user or fallback to repository current user
  final user = authStateVal.value?.session?.user ?? ref.read(authRepositoryProvider).currentUser;
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

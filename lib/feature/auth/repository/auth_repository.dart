import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:site_vault/shared/repository/base_repository.dart';

/// Database repository managing Supabase client authentication calls.
class AuthRepository extends BaseRepository {
  AuthRepository(super.client);

  /// Authenticate credentials using Supabase password verification.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return safeCall('AuthRepository.signIn', () async {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    });
  }

  /// Signs out of the current Supabase session.
  Future<void> signOut() {
    return safeCall('AuthRepository.signOut', () async {
      await client.auth.signOut();
    });
  }

  /// Retrieves the currently authenticated Supabase user metadata, if any.
  User? get currentUser => client.auth.currentUser;

  /// Stream of Supabase Auth state modifications (token updates, sign ins, logouts).
  Stream<AuthState> get authStateStream => client.auth.onAuthStateChange;
}

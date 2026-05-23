import 'package:supabase_flutter/supabase_flutter.dart';

/// Database repository managing Supabase client authentication calls.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Authenticate credentials using Supabase password verification.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in AuthRepository.signIn: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Signs out of the current Supabase session.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in AuthRepository.signOut: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Retrieves the currently authenticated Supabase user metadata, if any.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of Supabase Auth state modifications (token updates, sign ins, logouts).
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;
}

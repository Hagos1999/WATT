import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase Auth for sign-in, sign-out, and session state.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Get the current authenticated user, or null.
  User? get currentUser => _client.auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes for reactive UI updates.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  /// Throws [AuthException] on failure.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get the current session (auto-persisted by supabase_flutter).
  Session? get currentSession => _client.auth.currentSession;
}

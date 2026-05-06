import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

/// Provides the AuthRepository singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

/// Stream of auth state changes (login/logout events).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
        data: (state) => state.session != null,
      ) ??
      false;
});

/// The current user's email, or null.
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser?.email;
});

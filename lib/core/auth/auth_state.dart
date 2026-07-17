import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scaffold placeholder for the eventual sign-in / sign-out flow. The
/// onboarding feature deliberately does not consume this (FR-013 — guest
/// browsing requires no auth). First real reader will be the Login feature.
sealed class AuthState {
  const AuthState();
}

class Guest extends AuthState {
  const Guest();
}

class SignedIn extends AuthState {
  const SignedIn({required this.userId, required this.displayName});

  final String userId;
  final String displayName;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const Guest();

  void signIn({required String userId, required String displayName}) {
    state = SignedIn(userId: userId, displayName: displayName);
  }

  void signOut() => state = const Guest();
}

final authStateProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

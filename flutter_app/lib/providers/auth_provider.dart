import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthStatus> {
  final _authService = AuthService();

  AuthNotifier() : super(AuthStatus.loading) {
    _init();
  }

  Future<void> _init() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  void onLoggedIn() {
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthStatus.unauthenticated;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../storage/secure_storage_service.dart';
import '../network/api_client.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await SecureStorageService.isAuthenticated();
      if (isAuthenticated) {
        final token = await SecureStorageService.getAccessToken();
        if (token != null) {
          ApiClient.setAuthToken(token);
          
          final userId = await SecureStorageService.getUserId();
          final userRole = await SecureStorageService.getUserRole();
          
          if (userId != null && userRole != null) {
            // Try to fetch current user data from API
            try {
              final user = await _authService.getCurrentUser();
              state = AuthState.authenticated(user);
            } catch (e) {
              // If API call fails, clear auth data
              await _authService.logout();
              state = AuthState.unauthenticated();
            }
          } else {
            await _authService.logout();
            state = AuthState.unauthenticated();
          }
        } else {
          state = AuthState.unauthenticated();
        }
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final response = await _authService.login(email, password);
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    try {
      await _authService.logout();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> refreshSession() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _authService.refreshToken(refreshToken);
        final user = await _authService.getCurrentUser();
        state = AuthState.authenticated(user);
      } catch (e) {
        await _authService.logout();
        state = AuthState.unauthenticated();
      }
    } else {
      await _authService.logout();
      state = AuthState.unauthenticated();
    }
  }
}

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user) => user.role,
    orElse: () => null,
  );
});

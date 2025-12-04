import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/constants.dart';
import '../../../data/models/user_model.dart';
import '../../../core/services/api_service.dart';

/// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth Provider - Handles authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.authTokenKey);
      final userDataJson = prefs.getString(AppConstants.userDataKey);

      if (token != null && userDataJson != null) {
        final userData = User.fromJson({
          ...jsonDecode(userDataJson),
          'token': token,
        });
        
        state = AuthState(
          user: userData,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      state = AuthState(error: 'Error checking auth status: $e');
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final user = User.fromJson(response);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, user.token ?? '');
      await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));

      state = AuthState(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: $e',
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      await prefs.remove(AppConstants.userDataKey);

      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: 'Logout failed: $e');
    }
  }
}

/// Global Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.read(apiServiceProvider);
  return AuthNotifier(api);
});

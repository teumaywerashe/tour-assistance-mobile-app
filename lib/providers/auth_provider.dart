import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/admin.dart';
import '../data/repositories/auth_repository.dart';
import '../core/constants.dart';
import '../core/dio_client.dart';

class AuthState {
  final String? token;
  final String? username;
  final String? email;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.username,
    this.email,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    String? username,
    String? email,
    bool? isLoading,
    String? error,
    bool clearToken = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      username: clearToken ? null : (username ?? this.username),
      email: clearToken ? null : (email ?? this.email),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final _repo = AuthRepository();

  @override
  AuthState build() {
    _loadFromPrefs();
    return const AuthState();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final username = prefs.getString(AppConstants.usernameKey);
    final email = prefs.getString(AppConstants.emailKey);
    if (token != null && token.isNotEmpty) {
      state = AuthState(token: token, username: username, email: email);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final admin = await _repo.login(email, password);
      await _saveToPrefs(admin);
      state = AuthState(
        token: admin.token,
        username: admin.username,
        email: admin.email,
      );
      DioClient.reset();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.usernameKey);
    await prefs.remove(AppConstants.emailKey);
    state = const AuthState();
    DioClient.reset();
  }

  Future<void> _saveToPrefs(Admin admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, admin.token);
    await prefs.setString(AppConstants.usernameKey, admin.username);
    await prefs.setString(AppConstants.emailKey, admin.email);
  }

  String _parseError(dynamic e) {
    if (e.toString().contains('401')) return 'Invalid email or password';
    if (e.toString().contains('SocketException')) return 'No internet connection';
    return 'Login failed. Please try again.';
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

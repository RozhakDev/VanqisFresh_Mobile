import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/auth_state.dart';
import '../../domain/models/user.dart';
import '../../data/repositories/auth_repository.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    Future.microtask(() => _init());
    return const AuthState();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      if (await _repository.hasToken()) {
        final user = await _repository.fetchProfile();
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      await _repository.clearTokens();
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await _repository.login(username, password);
      await _repository.saveTokens(tokens['access']!, tokens['refresh']!);
      final user = await _repository.fetchProfile();

      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.register(
        username: username,
        password: password,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await _repository.updateProfile(data);
      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.clearTokens();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
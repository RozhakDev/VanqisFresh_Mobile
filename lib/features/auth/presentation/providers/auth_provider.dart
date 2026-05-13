import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/auth_state.dart';
import '../../domain/models/user.dart';
import '../../data/repositories/auth_repository.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Mengelola state dan aksi untuk fitur terkait.
///
/// Notifier ini memperbarui state berdasarkan interaksi atau hasil request.
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    Future.microtask(() => _init());
    return const AuthState();
  }

  /// Menyiapkan sesi pengguna dari token yang tersimpan.
  ///
  /// Dipakai saat state autentikasi pertama kali dibuat.
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

  /// Memproses login pengguna dan mengembalikan hasilnya.
  ///
  /// Digunakan untuk membuka sesi pengguna di aplikasi.
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await _repository.login(email, password);
      await _repository.saveTokens(tokens['access']!, tokens['refresh']!);
      final user = await _repository.fetchProfile();

      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Mengirim data pendaftaran pengguna baru.
  ///
  /// Digunakan untuk membuat akun sebelum pengguna masuk.
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

  /// Memperbarui data profil pengguna.
  ///
  /// Digunakan setelah pengguna menyimpan perubahan profil.
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

  /// Mengakhiri sesi pengguna dan membersihkan state autentikasi.
  ///
  /// Dipakai saat pengguna keluar dari aplikasi.
  Future<void> logout() async {
    await _repository.clearTokens();
    state = const AuthState();
  }

  /// Membersihkan pesan error dari state saat ini.
  ///
  /// Dipakai setelah error tidak lagi perlu ditampilkan.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

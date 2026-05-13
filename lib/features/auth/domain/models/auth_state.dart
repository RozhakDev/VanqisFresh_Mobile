import 'user.dart';

/// Menyimpan state autentikasi pengguna.
///
/// State ini mencatat user, loading, dan error autentikasi.
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  bool get isAuthenticated => user != null;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat AuthState perlu dibuat dengan nilai awal.
  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  /// Membuat salinan data dengan nilai yang dapat diperbarui.
  ///
  /// Membantu menjaga perubahan state tetap aman dan terarah.
  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

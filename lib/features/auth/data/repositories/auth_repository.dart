import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      await _dio.post('/users/register/', data: {
        'username': username,
        'password': password,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'address': address,
      });
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        final errors = data.values.expand((v) => v is List ? v : [v]).join('\n');
        throw Exception(errors.isNotEmpty ? errors : 'Gagal mendaftar');
      }
      throw Exception('Kesalahan jaringan: ${e.message}');
    }
  }

  Future<Map<String, String>> login(String username, String password) async {
    try {
      final response = await _dio.post('/users/login/', data: {
        'username': username,
        'password': password,
      });

      return {
        'access': response.data['access'],
        'refresh': response.data['refresh'],
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Username atau password salah.');
      }
      throw Exception('Kesalahan jaringan saat login.');
    }
  }

  Future<User> fetchProfile() async {
    try {
      final response = await _dio.get('/users/profile/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Gagal memuat profil: ${e.message}');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/users/profile/', data: data);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final err = e.response!.data as Map;
        final errors = err.values.expand((v) => v is List ? v : [v]).join('\n');
        throw Exception(errors.isNotEmpty ? errors : 'Gagal memperbarui profil');
      }
      throw Exception('Kesalahan jaringan: ${e.message}');
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}
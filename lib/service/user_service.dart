import '../helpers/api_client.dart';
import '../model/user.dart';
import 'package:flutter/material.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // Ambil semua data user
  Future<List<User>> getAllUsers() async {
    final response = await _apiClient.get('users');
    if (response.statusCode == 200) {
      List data = response.data;
      return data.map((item) => User.fromJson(item)).toList();
    }
    return [];
  }

  // Tambah user baru
// lib/service/user_service.dart
Future<bool> tambahUser(User user) async {
  try {
    // Pastikan endpoint 'register' sudah sesuai dengan routes/api.php di Laravel
    final response = await _apiClient.post('register', user.toJson());
    return response.statusCode == 201; // Laravel mengembalikan 201 untuk data baru
  } catch (e) {
    print("Error tambah karyawan: $e");
    return false;
  }
}

  // UPDATE USER (Fungsi yang kurang)
  // lib/service/user_service.dart
Future<bool> updateUser(User user) async {
  // TAMBAHKAN BARIS INI UNTUK DEBUGGING
  print("DEBUG: Mengirim Update untuk ID: ${user.id}");
  print("DEBUG: Data yang dikirim: ${user.toJson()}");

  try {
    final response = await _apiClient.put('users/${user.id}', user.toJson());
    return response.statusCode == 200;
  } catch (e) {
    print("Error Update: $e");
    return false;
  }
}

  // Hapus user
  Future<bool> hapusUser(String id) async {
    final response = await _apiClient.delete('users/$id');
    return response.statusCode == 200;
  }

Future resetJatah() async {
  try {
    // Pastikan path ini sama dengan yang ada di Route Laravel (users/reset-jatah)
    final response = await ApiClient().post('users/reset-jatah', {});
    return response;
  } catch (e) {
    throw Exception("Gagal Reset: $e");
  }
}

Future<Map<String, dynamic>> changePassword(String email, String oldPass, String newPass) async {
  try {
    final response = await ApiClient().post('change-password', {
      'email': email,
      'old_password': oldPass,
      'new_password': newPass,
    });
    return {'success': true, 'message': response.data['message']};
  } catch (e) {
    return {'success': false, 'message': 'Gagal ganti password'};
  }
}

Future<bool> resetPassword(String id) async {
  try {
    // Pastikan endpoint menggunakan reset-password (sesuai route Laravel)
    final response = await _apiClient.post('users/$id/reset-password', {});
    return response.statusCode == 200;
  } catch (e) {
    // Perhatikan tanda kutip di bawah ini
    debugPrint("Error Reset Password: $e"); 
    return false;
  }
}
}
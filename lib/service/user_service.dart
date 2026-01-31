import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/user.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart'; // Menghilangkan merah di XFile
import 'package:http_parser/http_parser.dart'; // Menghilangkan merah di MediaType

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Mengambil semua data user dari database
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiClient.get('users');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => User.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error getAllUsers: $e");
      return [];
    }
  }

  /// Menambah user baru (Register)
  Future<bool> tambahUser(User user) async {
    try {
      final response = await _apiClient.post('register', user.toJson());
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error tambahUser: $e");
      return false;
    }
  }

  /// Memperbarui data profile atau password user
  Future<bool> updateUser(User user) async {
    try {
      final response = await _apiClient.put('users/${user.id}', user.toJson());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error updateUser: $e");
      return false;
    }
  }

  /// Menghapus akun user beserta data terkait (riwayat cuti) di backend
  Future<bool> hapusUser(String id) async {
    try {
      final response = await _apiClient.delete('users/$id');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error hapusUser: $e");
      return false;
    }
  }

  /// Reset jatah cuti semua karyawan menjadi default (14 hari)
  Future resetJatah() async {
    try {
      final response = await _apiClient.post('users/reset-jatah', {});
      return response;
    } catch (e) {
      debugPrint("Error resetJatah: $e");
      throw Exception("Gagal Reset Jatah: $e");
    }
  }

  /// Mengganti password user (Memerlukan password lama)
  Future<Map<String, dynamic>> changePassword(String email, String oldPass, String newPass) async {
    try {
      final response = await _apiClient.post('change-password', {
        'email': email,
        'old_password': oldPass,
        'new_password': newPass,
      });
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      debugPrint("Error changePassword: $e");
      return {'success': false, 'message': 'Gagal ganti password'};
    }
  }

  /// Reset password user tertentu oleh Admin menjadi password default
  Future<bool> resetPassword(String id) async {
    try {
      final response = await _apiClient.post('users/$id/reset-password', {});
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error resetPassword: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> updateFoto(String userId, XFile imageFile) async {
  try {
    // Membaca file sebagai bytes agar support WEB & MOBILE
    List<int> imageBytes = await imageFile.readAsBytes();

    FormData formData = FormData.fromMap({
      "photo": MultipartFile.fromBytes(
        imageBytes,
        filename: imageFile.name,
        contentType: MediaType("image", "jpeg"), // Library http_parser
      ),
    });

    final response = await _apiClient.post('users/$userId/update-photo', formData);
    return {'success': true, 'photo_url': response.data['photo_url']};
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}
}
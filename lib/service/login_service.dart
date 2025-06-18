import 'package:dio/dio.dart';
import '../model/user.dart';

class LoginService {
  // Inisialisasi objek Dio untuk melakukan HTTP request
  final Dio _dio = Dio();

  // URL endpoint untuk mengambil data user dari MockAPI
  final String baseUrl = 'https://681b025517018fe5057980fa.mockapi.io/users'; // Ganti URL sesuai mockapi kamu

  // Fungsi untuk melakukan login berdasarkan username dan password
  Future<User?> login(String username, String password) async {
    try {
      // Kirim request GET ke endpoint dengan query parameter username dan password
      final response = await _dio.get(baseUrl, queryParameters: {
        'username': username,
        'password': password,
      });

      // Jika data ditemukan dan merupakan List, ambil user pertama
      if (response.data is List && response.data.isNotEmpty) {
        final userJson = response.data[0];
        return User.fromJson(userJson);
      } else {
        return null; // Login gagal jika data kosong
      }
    } catch (e) {
      // Tangani error jika terjadi saat login
      print("Login error: $e");
      return null;
    }
  }
}

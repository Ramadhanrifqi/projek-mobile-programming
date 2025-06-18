import 'package:dio/dio.dart';
import '../model/user.dart';
import '../helpers/api_client.dart';

class UserService {
  // Fungsi login untuk mencocokkan username dan password dari data user
  Future<User?> login(String username, String password) async {
    // Mengambil semua data user dari endpoint 'users'
    final Response response = await ApiClient().get('users');
    List data = response.data;

    // Melakukan pencarian user berdasarkan username dan password yang sesuai
    for (var json in data) {
      if (json['username'] == username && json['password'] == password) {
        return User.fromJson(json); // Mengembalikan objek User jika cocok
      }
    }

    // Jika tidak ditemukan user yang cocok, kembalikan null
    return null;
  }
}

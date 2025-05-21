import 'package:dio/dio.dart';
import '../model/user.dart';

class LoginService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://681b025517018fe5057980fa.mockapi.io/users'; // Ganti URL sesuai mockapi kamu

  Future<User?> login(String username, String password) async {
    try {
      final response = await _dio.get(baseUrl, queryParameters: {
        'username': username,
        'password': password,
      });

      if (response.data is List && response.data.isNotEmpty) {
        final userJson = response.data[0];
        return User.fromJson(userJson);
      } else {
        return null; // Login gagal
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}

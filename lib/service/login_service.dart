import '../helpers/api_client.dart';
import '../model/user.dart';

class LoginService {
  // TAMBAHKAN BARIS INI agar _apiClient tidak MERAH
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _apiClient.post('login', {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        // Mengembalikan Map yang berisi data user dan token dari Laravel
        return {
          'user': User.fromJson(response.data['user']),
          'token': response.data['token'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
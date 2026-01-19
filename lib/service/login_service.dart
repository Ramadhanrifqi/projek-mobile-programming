import '../helpers/api_client.dart';
import '../model/user.dart';

class LoginService {
  Future<User?> login(String email, String password) async {
    try {
      // Key harus 'email' agar terbaca oleh AuthController Laravel
      final response = await ApiClient().post('login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}
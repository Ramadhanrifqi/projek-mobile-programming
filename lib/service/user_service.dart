import 'package:dio/dio.dart';
import '../model/user.dart';
import '../helpers/api_client.dart';

class UserService {
  Future<User?> login(String username, String password) async {
    final Response response = await ApiClient().get('users');
    List data = response.data;
    for (var json in data) {
      if (json['username'] == username && json['password'] == password) {
        return User.fromJson(json);
      }
    }
    return null;
  }
}

import 'package:dio/dio.dart';
import '../model/user.dart';
import '../helpers/api_client.dart';

class UserService {
  // Fungsi login
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

  // Fungsi tambah user
  Future<void> tambahUser(User user) async {
    try {
      await ApiClient().post('users', user.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan user: $e');
    }
  }
  Future<List<User>> getAllUsers() async {
  final response = await ApiClient().get('users');
  List data = response.data;
  return data.map((e) => User.fromJson(e)).toList();
}

Future<void> hapusUser(String id) async {
  await ApiClient().delete('users/$id');
}

Future<void> updateUser(User user) async {
  await ApiClient().put('users/${user.id}', user.toJson());
}

}

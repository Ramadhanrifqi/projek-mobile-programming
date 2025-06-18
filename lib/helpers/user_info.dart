import '../model/user.dart';

class UserInfo {
  // Menyimpan data pengguna yang sedang login
  static User? loginUser;

  // Method untuk menyetel data user yang sedang login
  static void setUser(User user) {
    loginUser = user;
  }

  // Getter untuk mengambil objek User yang sedang login
  static User? get user => loginUser;

  // Getter untuk mengambil peran/role dari user
  static String? get role => loginUser?.role;

  // Getter untuk mengambil ID dari user
  static String? get userId => loginUser?.id;

  // Getter untuk mengambil username dari user
  static String? get username => loginUser?.username;
}

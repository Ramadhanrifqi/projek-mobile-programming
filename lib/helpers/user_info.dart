import '../model/user.dart';

class UserInfo {
  static User? loginUser;

  static void setUser(User user) {
    loginUser = user;
  }

  static User? get user => loginUser;
  static String? get role => loginUser?.role;
  static String? get userId => loginUser?.id;
}

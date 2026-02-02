import '../model/user.dart';

class UserInfo {
  static User? loginUser;
  static String? token; 

  static void setUser(User user, String userToken) {
    loginUser = user;
    token = userToken;
  }

  static bool get isAdmin => loginUser?.role?.toLowerCase() == 'admin';
  static String? get role => loginUser?.role;
  static String? get userId => loginUser?.id?.toString();
  static String? get name => loginUser?.name;
  static String? get email => loginUser?.email;
  static String? get username => loginUser?.email; 
  static String? get photoUrl => loginUser?.photoUrl;
  static int? pendingCutiCount = 0; 

  static void logout() {
    loginUser = null;
    token = null;
  }
}
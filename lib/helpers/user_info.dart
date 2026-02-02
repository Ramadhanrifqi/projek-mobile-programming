import 'package:flutter/material.dart';
import '../model/user.dart';

class UserInfo {
  static User? loginUser;
  static String? token;
  static int? pendingCutiCount = 0;

  // 1. NOTIFIER UNTUK SINKRONISASI: 
  // Digunakan agar Sidebar dan halaman lain bisa update otomatis saat data profil berubah.
  static ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);

  static void setUser(User user, String userToken) {
    loginUser = user;
    token = userToken;
    // Update notifier setiap kali user diset
    userNotifier.value = user;
  }

  // Getter data user
  static bool get isAdmin => loginUser?.role.toLowerCase() == 'admin';
  static String? get role => loginUser?.role;
  static String? get userId => loginUser?.id?.toString();
  static String? get name => loginUser?.name;
  static String? get email => loginUser?.email;
  static String? get username => loginUser?.email; 
  static String? get photoUrl => loginUser?.photoUrl;

  // Fungsi untuk update data user tanpa ganti token (misal: setelah ganti foto)
  static void updateUserData(User user) {
    loginUser = user;
    userNotifier.value = user;
  }

  static void logout() {
    loginUser = null;
    token = null;
    userNotifier.value = null;
    pendingCutiCount = 0;
  }
}
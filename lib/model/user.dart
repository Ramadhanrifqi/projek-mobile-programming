class User {
  // ID unik untuk setiap user (opsional, bisa null jika belum dibuat)
  String? id;

  // Nama pengguna yang digunakan untuk login
  String username;

  // Kata sandi untuk autentikasi pengguna
  String password;

  // Peran pengguna: bisa "admin" atau "user"
  String role;

  // Konstruktor utama untuk membuat objek User
  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Factory method untuk membuat objek User dari data JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        role: json['role'],
      );

  // Method untuk mengubah objek User menjadi format JSON (Map)
  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "role": role,
      };
}

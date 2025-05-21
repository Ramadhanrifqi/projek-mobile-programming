class User {
  String? id;
  String username;
  String password;
  String role; // admin / user

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        role: json['role'],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "role": role,
      };
}

class User {
  String? id;
  String? name;
  String email;
  String? password;
  String role;
  String? phone;
  String? bio;
  String? alamat;
  String? education;
  String? department;
  String? level;
  String? skills;
  String? joinDate;
  String? jobType;
  String? awards;
  int? jatahCuti;
  // --- TAMBAHKAN DUA FIELD INI ---
  String? image;     // Nama file di server
  String? photoUrl;  // URL lengkap untuk ditampilkan di UI

  User({
    this.id,
    this.name,
    required this.email,
    this.password,
    required this.role,
    this.phone,
    this.bio,
    this.alamat,
    this.education,
    this.department,
    this.level,
    this.skills,
    this.joinDate,
    this.jobType,
    this.awards,
    this.jatahCuti,
    this.image,      // Tambahkan di constructor
    this.photoUrl,   // Tambahkan di constructor
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString(),
        name: json['name'],
        email: json['email'] ?? '',
        role: json['role'] ?? 'user',
        phone: json['phone'],
        bio: json['bio'],
        alamat: json['alamat'],
        education: json['education'],
        department: json['department'],
        level: json['level'],
        skills: json['skills'],
        joinDate: json['joined_at'],
        jobType: json['job_descriptions'],
        awards: json['achievements'],
        jatahCuti: json['jatah_cuti'],
        // --- AMBIL DATA DARI JSON ---
        image: json['image'],
        photoUrl: json['photo_url'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "name": name,
      "email": email,
      "role": role,
      "phone": phone,
      "department": department,
      "level": level,
      "education": education,
      "skills": skills,
      "bio": bio,
      "alamat": alamat,
      "joined_at": joinDate,
      "job_descriptions": jobType,
      "achievements": awards,
      // Kirimkan kembali jika perlu update field lain tanpa merusak data foto
      "image": image,
      "photo_url": photoUrl,
    };

    if (jatahCuti != null) {
      data["jatah_cuti"] = jatahCuti;
    }

    if (password != null && password!.isNotEmpty) {
      data["password"] = password;
    }
    
    return data;
  }
}
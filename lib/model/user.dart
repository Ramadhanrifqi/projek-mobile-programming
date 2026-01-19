class User {
  String? id;
  String? name;
  String email;
  String? password; // Ubah jadi opsional (hapus required)
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

  User({
    this.id,
    this.name,
    required this.email,
    this.password, // Hapus required agar bisa update tanpa ganti password
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
  };

  // Jangan kirim jatah_cuti jika null, atau beri default 0
  if (jatahCuti != null) {
    data["jatah_cuti"] = jatahCuti;
  }

  if (password != null && password!.isNotEmpty) {
    data["password"] = password;
  }
  
  return data;
}


}
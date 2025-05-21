class Cuti {
  String? id;
  String ajukanCuti;
  String tanggalMulai;
  String tanggalSelesai;
  String alasan;
  String status; // "Pending", "Disetujui", "Ditolak"
  String userId;

  Cuti({
    this.id,
    required this.ajukanCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
    required this.status,
    required this.userId,
  });

  factory Cuti.fromJson(Map<String, dynamic> json) => Cuti(
        id: json['id'],
        ajukanCuti: json['ajukanCuti'],
        tanggalMulai: json['tanggalMulai'],
        tanggalSelesai: json['tanggalSelesai'],
        alasan: json['alasan'],
        status: json['status'],
        userId: json['userId'],
      );

  Map<String, dynamic> toJson() => {
        "ajukanCuti": ajukanCuti,
        "tanggalMulai": tanggalMulai,
        "tanggalSelesai": tanggalSelesai,
        "alasan": alasan,
        "status": status,
        "userId": userId,
      };
}

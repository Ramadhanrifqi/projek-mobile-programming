class Cuti {
  // ID unik untuk setiap cuti (opsional, bisa null jika belum dibuat)
  String? id;

  // Nama atau informasi pengajuan cuti
  String ajukanCuti;

  // Tanggal mulai cuti
  String tanggalMulai;

  // Tanggal selesai cuti
  String tanggalSelesai;

  // Alasan pengajuan cuti
  String alasan;

  // Status cuti: "Pending", "Disetujui", atau "Ditolak"
  String status;

  // ID user yang mengajukan cuti
  String userId;

  // Konstruktor utama untuk membuat objek Cuti
  Cuti({
    this.id,
    required this.ajukanCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
    required this.status,
    required this.userId,
  });

  // Factory method untuk membuat objek Cuti dari data JSON
  factory Cuti.fromJson(Map<String, dynamic> json) => Cuti(
        id: json['id'],
        ajukanCuti: json['ajukanCuti'],
        tanggalMulai: json['tanggalMulai'],
        tanggalSelesai: json['tanggalSelesai'],
        alasan: json['alasan'],
        status: json['status'],
        userId: json['userId'],
      );

  // Method untuk mengubah objek Cuti menjadi format JSON (Map)
  Map<String, dynamic> toJson() => {
        "ajukanCuti": ajukanCuti,
        "tanggalMulai": tanggalMulai,
        "tanggalSelesai": tanggalSelesai,
        "alasan": alasan,
        "status": status,
        "userId": userId,
      };
}

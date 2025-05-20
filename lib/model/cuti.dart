class Cuti {
  String? id;
  String ajukanCuti;
  String? tanggalMulai;
  String? tanggalSelesai;
  String? alasan;

  Cuti({
    this.id,
    required this.ajukanCuti,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.alasan,
  });

  factory Cuti.fromJson(Map<String, dynamic> json) => Cuti(
        id: json['id'],
        ajukanCuti: json['nama'],
        tanggalMulai: json['tanggalMulai'],
        tanggalSelesai: json['tanggalSelesai'],
        alasan: json['alasan'],
      );

  Map<String, dynamic> toJson() => {
        "nama": ajukanCuti,
        "tanggalMulai": tanggalMulai,
        "tanggalSelesai": tanggalSelesai,
        "alasan": alasan,
      };
}

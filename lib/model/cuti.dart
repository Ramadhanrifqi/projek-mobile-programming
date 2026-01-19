class Cuti {
  String? id;
  String? ajukanCuti;
  String? tanggalMulai;
  String? tanggalSelesai;
  String? alasan;
  String? status;

  Cuti({this.id, this.ajukanCuti, this.tanggalMulai, this.tanggalSelesai, this.alasan, this.status});

  // lib/model/cuti.dart

  factory Cuti.fromJson(Map<String, dynamic> json) {
    return Cuti(
      // Mengambil id_cuti karena di database Anda menggunakan id_cuti
      id: json['id_cuti']?.toString(), 
      ajukanCuti: json['nama'], 
      tanggalMulai: json['tanggalMulai'] ?? json['tanggal_mulai'],
      tanggalSelesai: json['tanggalSelesai'] ?? json['tanggal_selesai'],
      alasan: json['alasan'],
      // Mengantisipasi S besar atau s kecil dari API Laravel
      status: (json['Status'] ?? json['status'])?.toString(), 
    );
  }

  Map<String, dynamic> toJson() => {
        "nama": ajukanCuti, 
        "tanggalMulai": tanggalMulai,
        "tanggalSelesai": tanggalSelesai,
        "alasan": alasan,
        // PERBAIKAN: Gunakan "Status" (S besar) agar sesuai dengan kolom Database Anda
        "Status": status, 
      };
}
class Cuti {
  String? id;
  String? ajukanCuti;
  String? tanggalMulai;
  String? tanggalSelesai;
  String? alasan;
  String? status;

  Cuti({
    this.id,
    this.ajukanCuti,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.alasan,
    this.status,
  });

  // Digunakan untuk mengubah data dari API (Laravel) menjadi Object Flutter
  factory Cuti.fromJson(Map<String, dynamic> json) {
    return Cuti(
      // 1. Mengambil Primary Key id_cuti dari database
      id: json['id']?.toString(), 
      
      // 2. Mengambil data sesuai nama kolom snake_case di database
      ajukanCuti: json['ajukan_cuti']?.toString(), 
      tanggalMulai: json['tanggal_mulai']?.toString(),
      
      // 3. PERBAIKAN: Menggunakan 'i' (tanggal_selesai) sesuai database Anda
      tanggalSelesai: json['tanggal_selesai']?.toString(), 
      
      alasan: json['alasan']?.toString(),
      
      // 4. Menggunakan huruf kecil 'status' sesuai database
      status: json['status']?.toString(),
    );
  }

  // Digunakan untuk mengirim data dari Flutter ke API (Laravel)
  Map<String, dynamic> toJson() => {
    // Key di sini harus sama dengan yang dipanggil $request->... di Laravel
    "nama": ajukanCuti, 
    "tanggalMulai": tanggalMulai,
    "tanggalSelesai": tanggalSelesai,
    "alasan": alasan,
    "Status": status, 
  };
}
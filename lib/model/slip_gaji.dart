class SlipGaji {
  String? id;
  String? userId;
  String? bulan;
  String? tahun;
  int? gajiPokok;
  int? tunjangan;
  int? potongan;
  int? totalGaji;

  SlipGaji({
    this.id,
    this.userId,
    this.bulan,
    this.tahun,
    this.gajiPokok,
    this.tunjangan,
    this.potongan,
    this.totalGaji,
  });

  factory SlipGaji.fromJson(Map<String, dynamic> json) => SlipGaji(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        bulan: json["bulan"],
        tahun: json["tahun"].toString(),
        gajiPokok: json["gaji_pokok"],
        tunjangan: json["tunjangan"],
        potongan: json["potongan"],
        totalGaji: json["total_gaji"],
      );

  // TAMBAHKAN FUNGSI INI AGAR MERAHNYA HILANG:
  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "bulan": bulan,
        "tahun": tahun,
        "gaji_pokok": gajiPokok,
        "tunjangan": tunjangan,
        "potongan": potongan,
        "total_gaji": totalGaji,
      };
}
class SlipGaji {
  String? id;
  String? bulan;
  String? tahun;
  int? gajiPokok;
  int? tunjangan;
  int? potongan;
  int? totalGaji;

  SlipGaji({
    this.id,
    this.bulan,
    this.tahun,
    this.gajiPokok,
    this.tunjangan,
    this.potongan,
    this.totalGaji,
  });

  // Mengubah JSON dari API menjadi Objek Dart
  factory SlipGaji.fromJson(Map<String, dynamic> json) => SlipGaji(
        id: json["id"].toString(),
        bulan: json["bulan"],
        tahun: json["tahun"].toString(),
        gajiPokok: json["gaji_pokok"],
        tunjangan: json["tunjangan"],
        potongan: json["potongan"],
        totalGaji: json["total_gaji"],
      );

  // (Opsional) Mengubah Objek Dart kembali ke JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "bulan": bulan,
        "tahun": tahun,
        "gaji_pokok": gajiPokok,
        "tunjangan": tunjangan,
        "potongan": potongan,
        "total_gaji": totalGaji,
      };
}
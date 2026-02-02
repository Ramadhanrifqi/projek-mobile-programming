class SlipGaji {
  String? id;
  String? userId;
  String? bulan;
  String? tahun;
  int? gajiPokok;
  int? tunjanganTransport; // Baru
  int? tunjanganMakan;     // Baru
  int? potonganPph21;     // Baru
  int? potonganBpjsKes;   // Baru
  int? potonganBpjsTk;    // Baru
  int? totalGaji;

  SlipGaji({
    this.id,
    this.userId,
    this.bulan,
    this.tahun,
    this.gajiPokok,
    this.tunjanganTransport,
    this.tunjanganMakan,
    this.potonganPph21,
    this.potonganBpjsKes,
    this.potonganBpjsTk,
    this.totalGaji,
  });

  factory SlipGaji.fromJson(Map<String, dynamic> json) => SlipGaji(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        bulan: json["bulan"],
        tahun: json["tahun"].toString(),
        // Gunakan parsing num untuk menghindari error jika dari API tipenya double/string
        gajiPokok: _toInt(json["gaji_pokok"]),
        tunjanganTransport: _toInt(json["tunjangan_transport"]),
        tunjanganMakan: _toInt(json["tunjangan_makan"]),
        potonganPph21: _toInt(json["potongan_pph21"]),
        potonganBpjsKes: _toInt(json["potongan_bpjs_kes"]),
        potonganBpjsTk: _toInt(json["potongan_bpjs_tk"]),
        totalGaji: _toInt(json["total_gaji"]),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "bulan": bulan,
        "tahun": tahun,
        "gaji_pokok": gajiPokok,
        "tunjangan_transport": tunjanganTransport,
        "tunjangan_makan": tunjanganMakan,
        "potongan_pph21": potonganPph21,
        "potongan_bpjs_kes": potonganBpjsKes,
        "potongan_bpjs_tk": potonganBpjsTk,
        "total_gaji": totalGaji,
      };

  // Helper function untuk konversi tipe data apapun ke Integer secara aman
  static int? _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }
}
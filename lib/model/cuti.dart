class Cuti {
  String? id;
  String ajukanCuti;

  Cuti({this.id, required this.ajukanCuti});
  factory Cuti.fromJson(Map<String, dynamic> json) =>
      Cuti(id: json['id'], ajukanCuti: json['nama']);
  Map<String, dynamic> toJson() => {"nama": ajukanCuti,};
}

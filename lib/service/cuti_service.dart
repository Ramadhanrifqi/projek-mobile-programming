import 'package:dio/dio.dart';
import '/helpers/api_client.dart';
import '../model/cuti.dart';

class CutiService {
  // Mengambil semua data cuti dari API dan mengubahnya menjadi List<Cuti>
  Future<List<Cuti>> listData() async {
    final Response response = await ApiClient().get('cuti');
    final List data = response.data as List;
    List<Cuti> result = data.map((json) => Cuti.fromJson(json)).toList();
    return result;
  }

  // Menyimpan data cuti baru ke API
  Future<Cuti> simpan(Cuti cuti) async {
    var data = cuti.toJson();
    final Response response = await ApiClient().post('cuti', data);
    Cuti result = Cuti.fromJson(response.data);
    return result;
  }

  // Mengubah data cuti yang sudah ada berdasarkan ID
  Future<Cuti> ubah(Cuti cuti, String id) async {
    var data = cuti.toJson();
    final Response response = await ApiClient().put('cuti/${id}', data);
    print(response);
    Cuti result = Cuti.fromJson(response.data);
    return result;
  }

  // Mengambil detail data cuti berdasarkan ID
  Future<Cuti> getById(String id) async {
    final Response response = await ApiClient().get('cuti/${id}');
    Cuti result = Cuti.fromJson(response.data);
    return result;
  }

  // Menghapus data cuti berdasarkan ID
  Future<void> hapus(String id) async {
    final Response response = await ApiClient().delete('cuti/$id');
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data');
    }
  }
}

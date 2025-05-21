import 'package:dio/dio.dart';
import '/helpers/api_client.dart';
import '../model/cuti.dart';

class CutiService {
  Future<List<Cuti>> listData() async {
    final Response response = await ApiClient().get('cuti');
    final List data = response.data as List;
    List<Cuti> result = data.map((json) => Cuti.fromJson(json)).toList();
    return result;
  }

  Future<Cuti> simpan(Cuti cuti) async {
    var data = cuti.toJson();
    final Response response = await ApiClient().post('cuti', data);
    Cuti result = Cuti.fromJson(response.data);
    return result;
  }

  Future<Cuti> ubah(Cuti cuti, String id) async {
    var data = cuti.toJson();
    final Response response = await ApiClient().put('cuti/${id}', data);
    print(response);
    Cuti result = Cuti.fromJson(response.data);
    return result;
  }

  Future<Cuti> getById(String id) async {
    final Response response = await ApiClient().get('cuti/${id}');
    Cuti result = Cuti.fromJson(response.data);
    return result;
  }

  Future<void> hapus(String id) async {
  final Response response = await ApiClient().delete('cuti/$id');
  if (response.statusCode != 200) {
    throw Exception('Gagal menghapus data');
  }
}

}

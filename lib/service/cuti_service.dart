import '../helpers/api_client.dart';
import '../model/cuti.dart';

class CutiService {
  // Ambil semua data cuti
  Future<List<Cuti>> listData() async {
    final response = await ApiClient().get('cuti');
    final List data = response.data;
    return data.map((json) => Cuti.fromJson(json)).toList();
  }

Future simpan(Cuti cuti) async {
  // Pastikan path-nya benar (misal: 'cuti' atau 'api/cuti')
  // cuti.toJson() sekarang akan otomatis mengirim "Status": "Pending"
  final response = await ApiClient().post('cuti', cuti.toJson());
  return response;
}
// Pastikan fungsi menerima dua parameter: objek Cuti dan String id
Future ubah(Cuti cuti, String id) async {
  try {
    // Mengirim data ke endpoint Laravel api/cuti/{id}
    final response = await ApiClient().put('cuti/$id', cuti.toJson());
    return response;
  } catch (e) {
    throw Exception("Gagal update data: $e");
  }
}
  // ✅ Hapus pengajuan cuti
  Future hapus(String id) async {
    // Pastikan ID ini berisi nilai dari kolom id_cuti
    final response = await ApiClient().delete('cuti/$id');
    return response.data;
  }

  // ✅ FUNGSI RESET JATAH CUTI TAHUNAN (KHUSUS ADMIN)
  Future<bool> resetCutiSemua() async {
    try {
      final response = await ApiClient().get('cuti/reset-tahunan');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error Reset Cuti: $e");
      return false;
    }
  }
}
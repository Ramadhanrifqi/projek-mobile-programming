import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; 
import '../helpers/api_client.dart';
import '../model/cuti.dart';

class CutiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Cuti>> listData() async {
    try {
      final response = await _apiClient.get('cuti');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Cuti.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error listData Cuti: $e");
      return [];
    }
  }

  /// Mengirim pengajuan cuti baru ke server
  Future<Map<String, dynamic>> simpan(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('cuti', data);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      // Menangkap error dari Laravel (422, 400, dll)
      String msg = "Terjadi kesalahan";
      
      if (e.response != null && e.response!.data is Map) {
        // Mengambil pesan "Anda memiliki 2 pengajuan pending" dsb
        msg = e.response!.data['message'] ?? "Gagal memproses pengajuan";
      } else {
        msg = e.message ?? "Koneksi ke server terputus";
      }
      return {'success': false, 'message': msg};
    }catch (e) {
  // Ini akan menampilkan pesan error asli di layar HP Anda
  return {'success': false, 'message': "DETAIL ERROR: ${e.toString()}"};
}
  }

  Future ubah(Cuti cuti, String id) async {
    try {
      final response = await _apiClient.put('cuti/$id', cuti.toJson());
      return response;
    } catch (e) {
      debugPrint("Error ubah Cuti: $e");
      throw Exception("Gagal update data cuti");
    }
  }

  Future hapus(String id) async {
    try {
      final response = await _apiClient.delete('cuti/$id');
      return response.data;
    } catch (e) {
      debugPrint("Error hapus Cuti: $e");
      throw Exception("Gagal menghapus data cuti");
    }
  }

  Future<bool> resetCutiSemua() async {
    try {
      final response = await _apiClient.get('cuti/reset-tahunan');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Reset Cuti: $e");
      return false;
    }
  }
}
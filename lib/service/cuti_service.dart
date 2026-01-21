import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/cuti.dart';

class CutiService {
  final ApiClient _apiClient = ApiClient();

  /// Mengambil semua riwayat pengajuan cuti
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
  Future simpan(Cuti cuti) async {
    try {
      final response = await _apiClient.post('cuti', cuti.toJson());
      return response;
    } catch (e) {
      debugPrint("Error simpan Cuti: $e");
      throw Exception("Gagal menyimpan pengajuan: $e");
    }
  }

  /// Memperbarui data pengajuan (Status Disetujui/Ditolak oleh Admin)
  Future ubah(Cuti cuti, String id) async {
    try {
      final response = await _apiClient.put('cuti/$id', cuti.toJson());
      return response;
    } catch (e) {
      debugPrint("Error ubah Cuti: $e");
      throw Exception("Gagal update data cuti: $e");
    }
  }

  /// Menghapus satu data pengajuan cuti
  Future hapus(String id) async {
    try {
      final response = await _apiClient.delete('cuti/$id');
      return response.data;
    } catch (e) {
      debugPrint("Error hapus Cuti: $e");
      throw Exception("Gagal menghapus data cuti: $e");
    }
  }

  /// Fungsi Admin: Reset jatah cuti tahunan dan hapus semua riwayat
  Future<bool> resetCutiSemua() async {
    try {
      // Menggunakan GET sesuai dengan implementasi awal Anda
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
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

  Future<Map<String, dynamic>> simpan(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('cuti', data);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      String msg = "Terjadi kesalahan";
      if (e.response != null && e.response!.data is Map) {
        msg = e.response!.data['message'] ?? "Gagal memproses pengajuan";
      } else {
        msg = e.message ?? "Koneksi ke server terputus";
      }
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': "DETAIL ERROR: ${e.toString()}"};
    }
  }

  Future<Map<String, dynamic>> ubah(Cuti cuti, String id) async {
    try {
      final response = await _apiClient.put('cuti/${id.toString()}', cuti.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Status berhasil diperbarui'};
      }
      return {'success': false, 'message': 'Gagal memperbarui: Status ${response.statusCode}'};
    } on DioException catch (e) {
      return {'success': false, 'message': _parseError(e)};
    } catch (e) {
      return {'success': false, 'message': "Kesalahan Sistem: ${e.toString()}"};
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

  Future<int> getPendingCount() async {
    try {
      final response = await _apiClient.get('cuti/count-pending');
      if (response.statusCode == 200) {
        return response.data['pending_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint("Error getPendingCount: $e");
      return 0;
    }
  }

  String _parseError(DioException e) {
    if (e.response != null && e.response!.data is Map) {
      return e.response!.data['message'] ?? "Gagal memproses data server";
    }
    return e.message ?? "Koneksi ke server terputus";
  }
}

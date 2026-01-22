import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/slip_gaji.dart';

class SlipGajiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<SlipGaji>> getAllSlip() async {
    try {
      final response = await _apiClient.get('slip-gaji');
      List data = response.data;
      return data.map((item) => SlipGaji.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Error getAllSlip: $e");
      return [];
    }
  }

  Future<bool> simpan(SlipGaji slip) async {
    try {
      final response = await _apiClient.post('slip-gaji', slip.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> ubah(SlipGaji slip, String id) async {
    try {
      final response = await _apiClient.put('slip-gaji/$id', slip.toJson());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<bool> hapus(String id) async {
      try {
        // Mengirim request DELETE ke url: /slip-gaji/{id}
        final response = await _apiClient.delete('slip-gaji/$id');
        
        // Jika backend mengembalikan status 200, berarti berhasil
        return response.statusCode == 200;
      } catch (e) {
        debugPrint("Error Hapus: $e");
        return false;
      }
    }
}
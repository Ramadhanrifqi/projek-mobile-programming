import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/slip_gaji.dart'; // Pastikan Anda sudah membuat modelnya

class SlipGajiService {
  final ApiClient _apiClient = ApiClient();

  /// Mengambil semua data riwayat gaji user yang login
  Future<List<SlipGaji>> getAllSlip() async {
    try {
      final response = await _apiClient.get('slip-gaji');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => SlipGaji.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error getAllSlip: $e");
      return [];
    }
  }

  /// Mengambil detail gaji bulan tertentu
  Future<SlipGaji?> getDetailSlip(String id) async {
    try {
      final response = await _apiClient.get('slip-gaji/$id');
      if (response.statusCode == 200) {
        return SlipGaji.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error getDetailSlip: $e");
      return null;
    }
  }
}
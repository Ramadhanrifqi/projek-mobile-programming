import 'package:dio/dio.dart';

// Inisialisasi instance Dio dengan konfigurasi dasar
final Dio dio = Dio(BaseOptions(
  baseUrl: 'https://681b025517018fe5057980fa.mockapi.io/', // Ganti sesuai baseURL kamu
  connectTimeout: 5000,
  receiveTimeout: 3000,
  headers: {'Content-Type': 'application/json'},
));

class ApiClient {
  // Fungsi GET
  Future<Response> get(String path) async {
    try {
      final response = await dio.get(Uri.encodeFull(path));
      return response;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  // Fungsi POST
  Future<Response> post(String path, dynamic data) async {
    try {
      final response = await dio.post(Uri.encodeFull(path), data: data);
      return response;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  // Fungsi PUT (update)
  Future<Response> put(String path, dynamic data) async {
    try {
      final response = await dio.put(Uri.encodeFull(path), data: data);
      return response;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  // Fungsi DELETE
  Future<Response> delete(String path) async {
    try {
      final response = await dio.delete(Uri.encodeFull(path));
      return response;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }
}

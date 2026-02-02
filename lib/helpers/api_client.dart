import 'package:dio/dio.dart';
import 'user_info.dart';

final Dio dio = Dio(BaseOptions(
  //baseUrl: 'http://localhost:8000/api/', 
 baseUrl: 'http://192.168.1.7:8000/api/',
  connectTimeout: Duration(milliseconds: 5000),
  receiveTimeout: Duration(milliseconds: 3000),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
));

class ApiClient {
  ApiClient() {
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Otomatis ambil token dari UserInfo
        String? token = UserInfo.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> get(String path) async {
    try {
      return await dio.get(path);
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await dio.post(path, data: data);
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await dio.put(path, data: data);
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }
}
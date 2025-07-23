// lib/services/api_services.dart
import 'package:dio/dio.dart';
import '../config/api.dart';

class ApiEndpoints {

  static Future<Response?> login(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.dio.post('login', data: data);

      return response;

    } on DioException catch (err) {
      print("Dio error: ${err.message}");
      print("Dio response: ${err.response}");
      return err.response;
    }
  }

  static Future<Response?> register(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.dio.post('register', data: data);

      return response;

    } on DioException catch (err) {
      return err.response;
    }
  }
}

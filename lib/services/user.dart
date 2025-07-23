// lib/services/api_services.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';

class UserEndpoints {

  static Future<Response?> getListUser() async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');

    try {
      final response = await ApiService.dio.get('list_user', options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      ));
      
      return response;

    } on DioException catch (err) {
      return err.response;
    }
  }

  static Future<Response?> getDetailUser(Map<String, dynamic> data) async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');

    try {
      final response = await ApiService.dio.post('detail_user', data: data, options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      ));

      return response;

    } on DioException catch (err) {
      return err.response;
    }
  }

  static Future<Response?> updateProfile(Map<String, dynamic> data) async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');

    try {
      final response = await ApiService.dio.post('edit_profile', data: data, options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      ));

      return response;

    } on DioException catch (err) {
      return err.response;
    }
  }

  static Future<Response?> updateProfileImage(FormData formData) async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    
    try {
      final response = await ApiService.dio.post('upload_profile_image', data: formData, options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      ));
      
      return response;

    } on DioException catch (err) {
      return err.response;
    }
  }
}

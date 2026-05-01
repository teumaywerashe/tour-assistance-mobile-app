import 'package:dio/dio.dart';
import '../models/admin.dart';
import '../../core/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<Admin> login(String email, String password) async {
    final response = await _dio.post('/api/user/login', data: {
      'email': email,
      'password': password,
    });
    return Admin.fromJson(response.data);
  }

  Future<Admin> register(String username, String email, String password) async {
    final response = await _dio.post('/api/user/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return Admin.fromJson(response.data);
  }
}

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_URL',
        defaultValue: kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000',
      ),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  static const _defaultBaseUrl = kIsWeb
      ? 'http://localhost:8000'
      : 'http://10.0.2.2:8000';

  static Dio get dio => _dio;

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

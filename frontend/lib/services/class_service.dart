import 'package:dio/dio.dart';
import '../network/api_client.dart';

class ClassService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getClasses() async {
    try {
      final response = await _dio.get('/classes');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to load classes: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load classes: $e');
    }
  }
}

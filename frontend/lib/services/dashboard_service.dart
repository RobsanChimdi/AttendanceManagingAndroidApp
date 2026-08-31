import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class DashboardService {
  late final Dio _dio;

  DashboardService() {
    _dio = DioClient().dio;
  }

  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final response = await _dio.get('/dashboard/statistics');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get dashboard statistics: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get dashboard statistics: $e');
    }
  }

  Future<Map<String, dynamic>> getTeacherDashboardStatistics(int teacherId) async {
    try {
      final response = await _dio.get('/dashboard/teacher-statistics/$teacherId');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get teacher dashboard statistics: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get teacher dashboard statistics: $e');
    }
  }
}

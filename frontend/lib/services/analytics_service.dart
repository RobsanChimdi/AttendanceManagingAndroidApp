import 'package:dio/dio.dart';
import '../network/api_client.dart';

class AnalyticsService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> getAttendanceTrend({int days = 30}) async {
    try {
      final response = await _dio.get(
        '/dashboard/analytics/attendance-trend',
        queryParameters: {'days': days},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get attendance trend: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get attendance trend: $e');
    }
  }

  Future<Map<String, dynamic>> getClassComparison() async {
    try {
      final response = await _dio.get('/dashboard/analytics/class-comparison');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get class comparison: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get class comparison: $e');
    }
  }

  Future<Map<String, dynamic>> getGradeComparison() async {
    try {
      final response = await _dio.get('/dashboard/analytics/grade-comparison');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get grade comparison: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get grade comparison: $e');
    }
  }

  Future<Map<String, dynamic>> getPresentAbsentDistribution() async {
    try {
      final response = await _dio.get('/dashboard/analytics/present-absent-distribution');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get present/absent distribution: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get present/absent distribution: $e');
    }
  }

  Future<Map<String, dynamic>> getCriticalAttendanceBreakdown() async {
    try {
      final response = await _dio.get('/dashboard/analytics/critical-attendance-breakdown');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get critical attendance breakdown: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get critical attendance breakdown: $e');
    }
  }
}

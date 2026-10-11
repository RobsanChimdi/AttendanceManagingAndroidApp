import 'package:dio/dio.dart';
import '../network/api_client.dart';

class AttendanceSessionService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> sessionData) async {
    try {
      final response = await _dio.post(
        '/attendance/sessions',
        data: sessionData,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Invalid session data');
      }
      throw Exception('Failed to create session: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  Future<Map<String, dynamic>> getSession(int sessionId) async {
    try {
      final response = await _dio.get('/attendance/sessions/$sessionId');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Session not found');
      }
      throw Exception('Failed to get session: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  Future<Map<String, dynamic>> startSession(int sessionId) async {
    try {
      final response = await _dio.post('/attendance/sessions/$sessionId/start');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Cannot start session');
      }
      throw Exception('Failed to start session: ${e.message}');
    } catch (e) {
      throw Exception('Failed to start session: $e');
    }
  }

  Future<Map<String, dynamic>> closeSession(int sessionId) async {
    try {
      final response = await _dio.post('/attendance/sessions/$sessionId/close');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Cannot close session');
      }
      throw Exception('Failed to close session: ${e.message}');
    } catch (e) {
      throw Exception('Failed to close session: $e');
    }
  }

  Future<Map<String, dynamic>> getSessionStatistics(int sessionId) async {
    try {
      final response = await _dio.get('/attendance/sessions/$sessionId/statistics');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get statistics: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  Future<List<dynamic>> getSessionAttendance(int sessionId) async {
    try {
      final response = await _dio.get('/attendance/sessions/$sessionId/attendance');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get attendance: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }
}

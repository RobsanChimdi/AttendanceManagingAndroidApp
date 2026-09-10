import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../network/api_client.dart';

class ReportService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> getDailyAttendanceReport({
    required DateTime date,
    String? grade,
    int? classId,
    String? section,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/attendance/daily',
        queryParameters: {
          'report_date': DateFormat('yyyy-MM-dd').format(date),
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
          'skip': skip,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get daily attendance report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get daily attendance report: $e');
    }
  }

  Future<Map<String, dynamic>> getWeeklyAttendanceReport({
    required DateTime weekStart,
    String? grade,
    int? classId,
    String? section,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/attendance/weekly',
        queryParameters: {
          'week_start': DateFormat('yyyy-MM-dd').format(weekStart),
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
          'skip': skip,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get weekly attendance report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get weekly attendance report: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthlyAttendanceReport({
    required int year,
    required int month,
    String? grade,
    int? classId,
    String? section,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/attendance/monthly',
        queryParameters: {
          'year': year,
          'month': month,
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
          'skip': skip,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get monthly attendance report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get monthly attendance report: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentAttendanceReport({
    required int studentId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/attendance/student/$studentId',
        queryParameters: {
          if (dateFrom != null) 'date_from': DateFormat('yyyy-MM-dd').format(dateFrom),
          if (dateTo != null) 'date_to': DateFormat('yyyy-MM-dd').format(dateTo),
          'skip': skip,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get student attendance report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get student attendance report: $e');
    }
  }

  Future<Map<String, dynamic>> getClassAttendanceReport({
    required int classId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/attendance/class/$classId',
        queryParameters: {
          if (dateFrom != null) 'date_from': DateFormat('yyyy-MM-dd').format(dateFrom),
          if (dateTo != null) 'date_to': DateFormat('yyyy-MM-dd').format(dateTo),
          'skip': skip,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get class attendance report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get class attendance report: $e');
    }
  }

  Future<Map<String, dynamic>> getCriticalAttendanceReport({
    double threshold = 50.0,
    String? grade,
    int? classId,
    String? section,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/critical-attendance',
        queryParameters: {
          'threshold': threshold,
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
          'skip': skip,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get critical attendance report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get critical attendance report: $e');
    }
  }

  Future<String> exportDailyAttendanceCSV({
    required DateTime date,
    String? grade,
    int? classId,
    String? section,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/attendance/daily/csv',
        queryParameters: {
          'report_date': DateFormat('yyyy-MM-dd').format(date),
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
        },
      );
      return response.data as String;
    } on DioException catch (e) {
      throw Exception('Failed to export daily attendance CSV: ${e.message}');
    } catch (e) {
      throw Exception('Failed to export daily attendance CSV: $e');
    }
  }

  Future<String> exportCriticalAttendanceCSV({
    double threshold = 50.0,
    String? grade,
    int? classId,
    String? section,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/critical-attendance/csv',
        queryParameters: {
          'threshold': threshold,
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
        },
      );
      return response.data as String;
    } on DioException catch (e) {
      throw Exception('Failed to export critical attendance CSV: ${e.message}');
    } catch (e) {
      throw Exception('Failed to export critical attendance CSV: $e');
    }
  }

  Future<List<int>> exportDailyAttendancePDF({
    required DateTime date,
    String? grade,
    int? classId,
    String? section,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/reports/attendance/daily/pdf',
        options: Options(responseType: ResponseType.bytes),
        queryParameters: {
          'report_date': DateFormat('yyyy-MM-dd').format(date),
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
        },
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw Exception('Failed to export daily attendance PDF: ${e.message}');
    } catch (e) {
      throw Exception('Failed to export daily attendance PDF: $e');
    }
  }

  Future<List<int>> exportCriticalAttendancePDF({
    double threshold = 50.0,
    String? grade,
    int? classId,
    String? section,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/reports/critical-attendance/pdf',
        options: Options(responseType: ResponseType.bytes),
        queryParameters: {
          'threshold': threshold,
          if (grade != null) 'grade': grade,
          if (classId != null) 'class_id': classId,
          if (section != null) 'section': section,
        },
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw Exception('Failed to export critical attendance PDF: ${e.message}');
    } catch (e) {
      throw Exception('Failed to export critical attendance PDF: $e');
    }
  }
}


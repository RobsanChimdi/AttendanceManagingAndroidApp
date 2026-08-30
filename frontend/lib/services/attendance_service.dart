import 'package:dio/dio.dart';
import '../network/api_client.dart';
import 'dart:io';

class AttendanceService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> recognizeFace(int sessionId, File imageFile) async {
    try {
      final formData = FormData();
      final file = await MultipartFile.fromFile(
        imageFile.path,
        filename: 'attendance_frame.jpg',
      );
      formData.files.add(MapEntry('file', file));

      final response = await _dio.post(
        '/attendance/sessions/$sessionId/recognize',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Attendance session not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Invalid request');
      }
      throw Exception('Failed to recognize face: ${e.message}');
    } catch (e) {
      throw Exception('Failed to recognize face: $e');
    }
  }
}

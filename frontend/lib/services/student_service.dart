import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../models/student_models.dart';

class StudentService {
  final Dio _dio = ApiClient.dio;

  Future<StudentFilterResponse> getStudents({
    int skip = 0,
    int limit = 100,
    int? classId,
    String? grade,
    String? section,
    StudentStatus? status,
    String? search,
    String? sortBy,
    String? sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
        if (classId != null) 'class_id': classId,
        if (grade != null) 'grade': grade,
        if (section != null) 'section': section,
        if (status != null) 'status': status.name.toUpperCase(),
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      final response = await _dio.get(
        '/students',
        queryParameters: queryParams,
      );

      return StudentFilterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Failed to fetch students: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<Student> getStudent(int studentId) async {
    try {
      final response = await _dio.get('/students/$studentId');
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to fetch student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  Future<Student> getStudentByStudentId(String studentId) async {
    try {
      final response = await _dio.get('/students/student-id/$studentId');
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to fetch student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  Future<Student> createStudent(StudentCreate student) async {
    try {
      final response = await _dio.post(
        '/students',
        data: student.toJson(),
      );
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Student with this ID already exists');
      }
      throw Exception('Failed to create student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  Future<Student> updateStudent(int studentId, StudentUpdate student) async {
    try {
      final response = await _dio.put(
        '/students/$studentId',
        data: student.toJson(),
      );
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to update student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  Future<Student> deactivateStudent(int studentId) async {
    try {
      final response = await _dio.patch('/students/$studentId/deactivate');
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to deactivate student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to deactivate student: $e');
    }
  }

  Future<void> deleteStudent(int studentId) async {
    try {
      await _dio.delete('/students/$studentId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to delete student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  Future<Map<String, dynamic>> enrollFace(int studentId, List<File> imageFiles) async {
    try {
      final formData = FormData();
      
      for (int i = 0; i < imageFiles.length; i++) {
        final file = await MultipartFile.fromFile(
          imageFiles[i].path,
          filename: 'sample_$i.jpg',
        );
        formData.files.add(MapEntry('files', file));
      }

      final response = await _dio.post(
        '/students/$studentId/face/enroll',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Invalid enrollment data');
      }
      throw Exception('Failed to enroll face: ${e.message}');
    } catch (e) {
      throw Exception('Failed to enroll face: $e');
    }
  }

  Future<Map<String, dynamic>> getFaceEnrollmentStatus(int studentId) async {
    try {
      final response = await _dio.get('/students/$studentId/face/status');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to get enrollment status: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get enrollment status: $e');
    }
  }
}

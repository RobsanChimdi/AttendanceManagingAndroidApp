import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_models.freezed.dart';
part 'student_models.g.dart';

enum StudentStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('GRADUATED')
  graduated;
}

@freezed
class Student with _$Student {
  const factory Student({
    required int id,
    required String studentId,
    required String firstName,
    String? middleName,
    required String lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    required StudentStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}

@freezed
class StudentCreate with _$StudentCreate {
  const factory StudentCreate({
    required String studentId,
    required String firstName,
    String? middleName,
    required String lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    @Default(StudentStatus.active) StudentStatus status,
  }) = _StudentCreate;

  factory StudentCreate.fromJson(Map<String, dynamic> json) =>
      _$StudentCreateFromJson(json);
}

@freezed
class StudentUpdate with _$StudentUpdate {
  const factory StudentUpdate({
    String? firstName,
    String? middleName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    StudentStatus? status,
  }) = _StudentUpdate;

  factory StudentUpdate.fromJson(Map<String, dynamic> json) =>
      _$StudentUpdateFromJson(json);
}

@freezed
class StudentFilterResponse with _$StudentFilterResponse {
  const factory StudentFilterResponse({
    required List<Student> students,
    required int total,
    required int skip,
    required int limit,
  }) = _StudentFilterResponse;

  factory StudentFilterResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentFilterResponseFromJson(json);
}

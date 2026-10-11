// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      id: (json['id'] as num).toInt(),
      studentId: json['studentId'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      grade: json['grade'] as String?,
      section: json['section'] as String?,
      classId: (json['classId'] as num?)?.toInt(),
      guardianName: json['guardianName'] as String?,
      guardianPhone: json['guardianPhone'] as String?,
      guardianEmail: json['guardianEmail'] as String?,
      status: $enumDecode(_$StudentStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth,
      'grade': instance.grade,
      'section': instance.section,
      'classId': instance.classId,
      'guardianName': instance.guardianName,
      'guardianPhone': instance.guardianPhone,
      'guardianEmail': instance.guardianEmail,
      'status': _$StudentStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'ACTIVE',
  StudentStatus.inactive: 'INACTIVE',
  StudentStatus.graduated: 'GRADUATED',
};

_$StudentCreateImpl _$$StudentCreateImplFromJson(Map<String, dynamic> json) =>
    _$StudentCreateImpl(
      studentId: json['studentId'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      grade: json['grade'] as String?,
      section: json['section'] as String?,
      classId: (json['classId'] as num?)?.toInt(),
      guardianName: json['guardianName'] as String?,
      guardianPhone: json['guardianPhone'] as String?,
      guardianEmail: json['guardianEmail'] as String?,
      status:
          $enumDecodeNullable(_$StudentStatusEnumMap, json['status']) ??
          StudentStatus.active,
    );

Map<String, dynamic> _$$StudentCreateImplToJson(_$StudentCreateImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth,
      'grade': instance.grade,
      'section': instance.section,
      'classId': instance.classId,
      'guardianName': instance.guardianName,
      'guardianPhone': instance.guardianPhone,
      'guardianEmail': instance.guardianEmail,
      'status': _$StudentStatusEnumMap[instance.status]!,
    };

_$StudentUpdateImpl _$$StudentUpdateImplFromJson(Map<String, dynamic> json) =>
    _$StudentUpdateImpl(
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      grade: json['grade'] as String?,
      section: json['section'] as String?,
      classId: (json['classId'] as num?)?.toInt(),
      guardianName: json['guardianName'] as String?,
      guardianPhone: json['guardianPhone'] as String?,
      guardianEmail: json['guardianEmail'] as String?,
      status: $enumDecodeNullable(_$StudentStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$StudentUpdateImplToJson(_$StudentUpdateImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth,
      'grade': instance.grade,
      'section': instance.section,
      'classId': instance.classId,
      'guardianName': instance.guardianName,
      'guardianPhone': instance.guardianPhone,
      'guardianEmail': instance.guardianEmail,
      'status': _$StudentStatusEnumMap[instance.status],
    };

_$StudentFilterResponseImpl _$$StudentFilterResponseImplFromJson(
  Map<String, dynamic> json,
) => _$StudentFilterResponseImpl(
  students: (json['students'] as List<dynamic>)
      .map((e) => Student.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$$StudentFilterResponseImplToJson(
  _$StudentFilterResponseImpl instance,
) => <String, dynamic>{
  'students': instance.students,
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Student _$StudentFromJson(Map<String, dynamic> json) {
  return _Student.fromJson(json);
}

/// @nodoc
mixin _$Student {
  int get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get middleName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get dateOfBirth => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;
  String? get section => throw _privateConstructorUsedError;
  int? get classId => throw _privateConstructorUsedError;
  String? get guardianName => throw _privateConstructorUsedError;
  String? get guardianPhone => throw _privateConstructorUsedError;
  String? get guardianEmail => throw _privateConstructorUsedError;
  StudentStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCopyWith<Student> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCopyWith<$Res> {
  factory $StudentCopyWith(Student value, $Res Function(Student) then) =
      _$StudentCopyWithImpl<$Res, Student>;
  @useResult
  $Res call({
    int id,
    String studentId,
    String firstName,
    String? middleName,
    String lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    StudentStatus status,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$StudentCopyWithImpl<$Res, $Val extends Student>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? firstName = null,
    Object? middleName = freezed,
    Object? lastName = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? grade = freezed,
    Object? section = freezed,
    Object? classId = freezed,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? guardianEmail = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            middleName: freezed == middleName
                ? _value.middleName
                : middleName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfBirth: freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as String?,
            grade: freezed == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                      as String?,
            section: freezed == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String?,
            classId: freezed == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as int?,
            guardianName: freezed == guardianName
                ? _value.guardianName
                : guardianName // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianPhone: freezed == guardianPhone
                ? _value.guardianPhone
                : guardianPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianEmail: freezed == guardianEmail
                ? _value.guardianEmail
                : guardianEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as StudentStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentImplCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$$StudentImplCopyWith(
    _$StudentImpl value,
    $Res Function(_$StudentImpl) then,
  ) = __$$StudentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String studentId,
    String firstName,
    String? middleName,
    String lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    StudentStatus status,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$StudentImplCopyWithImpl<$Res>
    extends _$StudentCopyWithImpl<$Res, _$StudentImpl>
    implements _$$StudentImplCopyWith<$Res> {
  __$$StudentImplCopyWithImpl(
    _$StudentImpl _value,
    $Res Function(_$StudentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? firstName = null,
    Object? middleName = freezed,
    Object? lastName = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? grade = freezed,
    Object? section = freezed,
    Object? classId = freezed,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? guardianEmail = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$StudentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        middleName: freezed == middleName
            ? _value.middleName
            : middleName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfBirth: freezed == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as String?,
        grade: freezed == grade
            ? _value.grade
            : grade // ignore: cast_nullable_to_non_nullable
                  as String?,
        section: freezed == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String?,
        classId: freezed == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as int?,
        guardianName: freezed == guardianName
            ? _value.guardianName
            : guardianName // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianPhone: freezed == guardianPhone
            ? _value.guardianPhone
            : guardianPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianEmail: freezed == guardianEmail
            ? _value.guardianEmail
            : guardianEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as StudentStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentImpl implements _Student {
  const _$StudentImpl({
    required this.id,
    required this.studentId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    this.grade,
    this.section,
    this.classId,
    this.guardianName,
    this.guardianPhone,
    this.guardianEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$StudentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentImplFromJson(json);

  @override
  final int id;
  @override
  final String studentId;
  @override
  final String firstName;
  @override
  final String? middleName;
  @override
  final String lastName;
  @override
  final String? gender;
  @override
  final String? dateOfBirth;
  @override
  final String? grade;
  @override
  final String? section;
  @override
  final int? classId;
  @override
  final String? guardianName;
  @override
  final String? guardianPhone;
  @override
  final String? guardianEmail;
  @override
  final StudentStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Student(id: $id, studentId: $studentId, firstName: $firstName, middleName: $middleName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, grade: $grade, section: $section, classId: $classId, guardianName: $guardianName, guardianPhone: $guardianPhone, guardianEmail: $guardianEmail, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.guardianName, guardianName) ||
                other.guardianName == guardianName) &&
            (identical(other.guardianPhone, guardianPhone) ||
                other.guardianPhone == guardianPhone) &&
            (identical(other.guardianEmail, guardianEmail) ||
                other.guardianEmail == guardianEmail) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    firstName,
    middleName,
    lastName,
    gender,
    dateOfBirth,
    grade,
    section,
    classId,
    guardianName,
    guardianPhone,
    guardianEmail,
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      __$$StudentImplCopyWithImpl<_$StudentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentImplToJson(this);
  }
}

abstract class _Student implements Student {
  const factory _Student({
    required final int id,
    required final String studentId,
    required final String firstName,
    final String? middleName,
    required final String lastName,
    final String? gender,
    final String? dateOfBirth,
    final String? grade,
    final String? section,
    final int? classId,
    final String? guardianName,
    final String? guardianPhone,
    final String? guardianEmail,
    required final StudentStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$StudentImpl;

  factory _Student.fromJson(Map<String, dynamic> json) = _$StudentImpl.fromJson;

  @override
  int get id;
  @override
  String get studentId;
  @override
  String get firstName;
  @override
  String? get middleName;
  @override
  String get lastName;
  @override
  String? get gender;
  @override
  String? get dateOfBirth;
  @override
  String? get grade;
  @override
  String? get section;
  @override
  int? get classId;
  @override
  String? get guardianName;
  @override
  String? get guardianPhone;
  @override
  String? get guardianEmail;
  @override
  StudentStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentCreate _$StudentCreateFromJson(Map<String, dynamic> json) {
  return _StudentCreate.fromJson(json);
}

/// @nodoc
mixin _$StudentCreate {
  String get studentId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get middleName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get dateOfBirth => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;
  String? get section => throw _privateConstructorUsedError;
  int? get classId => throw _privateConstructorUsedError;
  String? get guardianName => throw _privateConstructorUsedError;
  String? get guardianPhone => throw _privateConstructorUsedError;
  String? get guardianEmail => throw _privateConstructorUsedError;
  StudentStatus get status => throw _privateConstructorUsedError;

  /// Serializes this StudentCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCreateCopyWith<StudentCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCreateCopyWith<$Res> {
  factory $StudentCreateCopyWith(
    StudentCreate value,
    $Res Function(StudentCreate) then,
  ) = _$StudentCreateCopyWithImpl<$Res, StudentCreate>;
  @useResult
  $Res call({
    String studentId,
    String firstName,
    String? middleName,
    String lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    StudentStatus status,
  });
}

/// @nodoc
class _$StudentCreateCopyWithImpl<$Res, $Val extends StudentCreate>
    implements $StudentCreateCopyWith<$Res> {
  _$StudentCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? firstName = null,
    Object? middleName = freezed,
    Object? lastName = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? grade = freezed,
    Object? section = freezed,
    Object? classId = freezed,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? guardianEmail = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            middleName: freezed == middleName
                ? _value.middleName
                : middleName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfBirth: freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as String?,
            grade: freezed == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                      as String?,
            section: freezed == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String?,
            classId: freezed == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as int?,
            guardianName: freezed == guardianName
                ? _value.guardianName
                : guardianName // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianPhone: freezed == guardianPhone
                ? _value.guardianPhone
                : guardianPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianEmail: freezed == guardianEmail
                ? _value.guardianEmail
                : guardianEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as StudentStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentCreateImplCopyWith<$Res>
    implements $StudentCreateCopyWith<$Res> {
  factory _$$StudentCreateImplCopyWith(
    _$StudentCreateImpl value,
    $Res Function(_$StudentCreateImpl) then,
  ) = __$$StudentCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String firstName,
    String? middleName,
    String lastName,
    String? gender,
    String? dateOfBirth,
    String? grade,
    String? section,
    int? classId,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    StudentStatus status,
  });
}

/// @nodoc
class __$$StudentCreateImplCopyWithImpl<$Res>
    extends _$StudentCreateCopyWithImpl<$Res, _$StudentCreateImpl>
    implements _$$StudentCreateImplCopyWith<$Res> {
  __$$StudentCreateImplCopyWithImpl(
    _$StudentCreateImpl _value,
    $Res Function(_$StudentCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? firstName = null,
    Object? middleName = freezed,
    Object? lastName = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? grade = freezed,
    Object? section = freezed,
    Object? classId = freezed,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? guardianEmail = freezed,
    Object? status = null,
  }) {
    return _then(
      _$StudentCreateImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        middleName: freezed == middleName
            ? _value.middleName
            : middleName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfBirth: freezed == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as String?,
        grade: freezed == grade
            ? _value.grade
            : grade // ignore: cast_nullable_to_non_nullable
                  as String?,
        section: freezed == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String?,
        classId: freezed == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as int?,
        guardianName: freezed == guardianName
            ? _value.guardianName
            : guardianName // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianPhone: freezed == guardianPhone
            ? _value.guardianPhone
            : guardianPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianEmail: freezed == guardianEmail
            ? _value.guardianEmail
            : guardianEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as StudentStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentCreateImpl implements _StudentCreate {
  const _$StudentCreateImpl({
    required this.studentId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    this.grade,
    this.section,
    this.classId,
    this.guardianName,
    this.guardianPhone,
    this.guardianEmail,
    this.status = StudentStatus.active,
  });

  factory _$StudentCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentCreateImplFromJson(json);

  @override
  final String studentId;
  @override
  final String firstName;
  @override
  final String? middleName;
  @override
  final String lastName;
  @override
  final String? gender;
  @override
  final String? dateOfBirth;
  @override
  final String? grade;
  @override
  final String? section;
  @override
  final int? classId;
  @override
  final String? guardianName;
  @override
  final String? guardianPhone;
  @override
  final String? guardianEmail;
  @override
  @JsonKey()
  final StudentStatus status;

  @override
  String toString() {
    return 'StudentCreate(studentId: $studentId, firstName: $firstName, middleName: $middleName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, grade: $grade, section: $section, classId: $classId, guardianName: $guardianName, guardianPhone: $guardianPhone, guardianEmail: $guardianEmail, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentCreateImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.guardianName, guardianName) ||
                other.guardianName == guardianName) &&
            (identical(other.guardianPhone, guardianPhone) ||
                other.guardianPhone == guardianPhone) &&
            (identical(other.guardianEmail, guardianEmail) ||
                other.guardianEmail == guardianEmail) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    firstName,
    middleName,
    lastName,
    gender,
    dateOfBirth,
    grade,
    section,
    classId,
    guardianName,
    guardianPhone,
    guardianEmail,
    status,
  );

  /// Create a copy of StudentCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentCreateImplCopyWith<_$StudentCreateImpl> get copyWith =>
      __$$StudentCreateImplCopyWithImpl<_$StudentCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentCreateImplToJson(this);
  }
}

abstract class _StudentCreate implements StudentCreate {
  const factory _StudentCreate({
    required final String studentId,
    required final String firstName,
    final String? middleName,
    required final String lastName,
    final String? gender,
    final String? dateOfBirth,
    final String? grade,
    final String? section,
    final int? classId,
    final String? guardianName,
    final String? guardianPhone,
    final String? guardianEmail,
    final StudentStatus status,
  }) = _$StudentCreateImpl;

  factory _StudentCreate.fromJson(Map<String, dynamic> json) =
      _$StudentCreateImpl.fromJson;

  @override
  String get studentId;
  @override
  String get firstName;
  @override
  String? get middleName;
  @override
  String get lastName;
  @override
  String? get gender;
  @override
  String? get dateOfBirth;
  @override
  String? get grade;
  @override
  String? get section;
  @override
  int? get classId;
  @override
  String? get guardianName;
  @override
  String? get guardianPhone;
  @override
  String? get guardianEmail;
  @override
  StudentStatus get status;

  /// Create a copy of StudentCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentCreateImplCopyWith<_$StudentCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentUpdate _$StudentUpdateFromJson(Map<String, dynamic> json) {
  return _StudentUpdate.fromJson(json);
}

/// @nodoc
mixin _$StudentUpdate {
  String? get firstName => throw _privateConstructorUsedError;
  String? get middleName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get dateOfBirth => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;
  String? get section => throw _privateConstructorUsedError;
  int? get classId => throw _privateConstructorUsedError;
  String? get guardianName => throw _privateConstructorUsedError;
  String? get guardianPhone => throw _privateConstructorUsedError;
  String? get guardianEmail => throw _privateConstructorUsedError;
  StudentStatus? get status => throw _privateConstructorUsedError;

  /// Serializes this StudentUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentUpdateCopyWith<StudentUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentUpdateCopyWith<$Res> {
  factory $StudentUpdateCopyWith(
    StudentUpdate value,
    $Res Function(StudentUpdate) then,
  ) = _$StudentUpdateCopyWithImpl<$Res, StudentUpdate>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$StudentUpdateCopyWithImpl<$Res, $Val extends StudentUpdate>
    implements $StudentUpdateCopyWith<$Res> {
  _$StudentUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = freezed,
    Object? middleName = freezed,
    Object? lastName = freezed,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? grade = freezed,
    Object? section = freezed,
    Object? classId = freezed,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? guardianEmail = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            middleName: freezed == middleName
                ? _value.middleName
                : middleName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfBirth: freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as String?,
            grade: freezed == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                      as String?,
            section: freezed == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String?,
            classId: freezed == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as int?,
            guardianName: freezed == guardianName
                ? _value.guardianName
                : guardianName // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianPhone: freezed == guardianPhone
                ? _value.guardianPhone
                : guardianPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianEmail: freezed == guardianEmail
                ? _value.guardianEmail
                : guardianEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as StudentStatus?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentUpdateImplCopyWith<$Res>
    implements $StudentUpdateCopyWith<$Res> {
  factory _$$StudentUpdateImplCopyWith(
    _$StudentUpdateImpl value,
    $Res Function(_$StudentUpdateImpl) then,
  ) = __$$StudentUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$StudentUpdateImplCopyWithImpl<$Res>
    extends _$StudentUpdateCopyWithImpl<$Res, _$StudentUpdateImpl>
    implements _$$StudentUpdateImplCopyWith<$Res> {
  __$$StudentUpdateImplCopyWithImpl(
    _$StudentUpdateImpl _value,
    $Res Function(_$StudentUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = freezed,
    Object? middleName = freezed,
    Object? lastName = freezed,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? grade = freezed,
    Object? section = freezed,
    Object? classId = freezed,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? guardianEmail = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$StudentUpdateImpl(
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        middleName: freezed == middleName
            ? _value.middleName
            : middleName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfBirth: freezed == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as String?,
        grade: freezed == grade
            ? _value.grade
            : grade // ignore: cast_nullable_to_non_nullable
                  as String?,
        section: freezed == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String?,
        classId: freezed == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as int?,
        guardianName: freezed == guardianName
            ? _value.guardianName
            : guardianName // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianPhone: freezed == guardianPhone
            ? _value.guardianPhone
            : guardianPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianEmail: freezed == guardianEmail
            ? _value.guardianEmail
            : guardianEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as StudentStatus?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentUpdateImpl implements _StudentUpdate {
  const _$StudentUpdateImpl({
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.grade,
    this.section,
    this.classId,
    this.guardianName,
    this.guardianPhone,
    this.guardianEmail,
    this.status,
  });

  factory _$StudentUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentUpdateImplFromJson(json);

  @override
  final String? firstName;
  @override
  final String? middleName;
  @override
  final String? lastName;
  @override
  final String? gender;
  @override
  final String? dateOfBirth;
  @override
  final String? grade;
  @override
  final String? section;
  @override
  final int? classId;
  @override
  final String? guardianName;
  @override
  final String? guardianPhone;
  @override
  final String? guardianEmail;
  @override
  final StudentStatus? status;

  @override
  String toString() {
    return 'StudentUpdate(firstName: $firstName, middleName: $middleName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, grade: $grade, section: $section, classId: $classId, guardianName: $guardianName, guardianPhone: $guardianPhone, guardianEmail: $guardianEmail, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentUpdateImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.guardianName, guardianName) ||
                other.guardianName == guardianName) &&
            (identical(other.guardianPhone, guardianPhone) ||
                other.guardianPhone == guardianPhone) &&
            (identical(other.guardianEmail, guardianEmail) ||
                other.guardianEmail == guardianEmail) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    firstName,
    middleName,
    lastName,
    gender,
    dateOfBirth,
    grade,
    section,
    classId,
    guardianName,
    guardianPhone,
    guardianEmail,
    status,
  );

  /// Create a copy of StudentUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentUpdateImplCopyWith<_$StudentUpdateImpl> get copyWith =>
      __$$StudentUpdateImplCopyWithImpl<_$StudentUpdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentUpdateImplToJson(this);
  }
}

abstract class _StudentUpdate implements StudentUpdate {
  const factory _StudentUpdate({
    final String? firstName,
    final String? middleName,
    final String? lastName,
    final String? gender,
    final String? dateOfBirth,
    final String? grade,
    final String? section,
    final int? classId,
    final String? guardianName,
    final String? guardianPhone,
    final String? guardianEmail,
    final StudentStatus? status,
  }) = _$StudentUpdateImpl;

  factory _StudentUpdate.fromJson(Map<String, dynamic> json) =
      _$StudentUpdateImpl.fromJson;

  @override
  String? get firstName;
  @override
  String? get middleName;
  @override
  String? get lastName;
  @override
  String? get gender;
  @override
  String? get dateOfBirth;
  @override
  String? get grade;
  @override
  String? get section;
  @override
  int? get classId;
  @override
  String? get guardianName;
  @override
  String? get guardianPhone;
  @override
  String? get guardianEmail;
  @override
  StudentStatus? get status;

  /// Create a copy of StudentUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentUpdateImplCopyWith<_$StudentUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentFilterResponse _$StudentFilterResponseFromJson(
  Map<String, dynamic> json,
) {
  return _StudentFilterResponse.fromJson(json);
}

/// @nodoc
mixin _$StudentFilterResponse {
  List<Student> get students => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get skip => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;

  /// Serializes this StudentFilterResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentFilterResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentFilterResponseCopyWith<StudentFilterResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentFilterResponseCopyWith<$Res> {
  factory $StudentFilterResponseCopyWith(
    StudentFilterResponse value,
    $Res Function(StudentFilterResponse) then,
  ) = _$StudentFilterResponseCopyWithImpl<$Res, StudentFilterResponse>;
  @useResult
  $Res call({List<Student> students, int total, int skip, int limit});
}

/// @nodoc
class _$StudentFilterResponseCopyWithImpl<
  $Res,
  $Val extends StudentFilterResponse
>
    implements $StudentFilterResponseCopyWith<$Res> {
  _$StudentFilterResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentFilterResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? total = null,
    Object? skip = null,
    Object? limit = null,
  }) {
    return _then(
      _value.copyWith(
            students: null == students
                ? _value.students
                : students // ignore: cast_nullable_to_non_nullable
                      as List<Student>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            skip: null == skip
                ? _value.skip
                : skip // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentFilterResponseImplCopyWith<$Res>
    implements $StudentFilterResponseCopyWith<$Res> {
  factory _$$StudentFilterResponseImplCopyWith(
    _$StudentFilterResponseImpl value,
    $Res Function(_$StudentFilterResponseImpl) then,
  ) = __$$StudentFilterResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Student> students, int total, int skip, int limit});
}

/// @nodoc
class __$$StudentFilterResponseImplCopyWithImpl<$Res>
    extends
        _$StudentFilterResponseCopyWithImpl<$Res, _$StudentFilterResponseImpl>
    implements _$$StudentFilterResponseImplCopyWith<$Res> {
  __$$StudentFilterResponseImplCopyWithImpl(
    _$StudentFilterResponseImpl _value,
    $Res Function(_$StudentFilterResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentFilterResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? total = null,
    Object? skip = null,
    Object? limit = null,
  }) {
    return _then(
      _$StudentFilterResponseImpl(
        students: null == students
            ? _value._students
            : students // ignore: cast_nullable_to_non_nullable
                  as List<Student>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        skip: null == skip
            ? _value.skip
            : skip // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentFilterResponseImpl implements _StudentFilterResponse {
  const _$StudentFilterResponseImpl({
    required final List<Student> students,
    required this.total,
    required this.skip,
    required this.limit,
  }) : _students = students;

  factory _$StudentFilterResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentFilterResponseImplFromJson(json);

  final List<Student> _students;
  @override
  List<Student> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  @override
  final int total;
  @override
  final int skip;
  @override
  final int limit;

  @override
  String toString() {
    return 'StudentFilterResponse(students: $students, total: $total, skip: $skip, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentFilterResponseImpl &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.skip, skip) || other.skip == skip) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_students),
    total,
    skip,
    limit,
  );

  /// Create a copy of StudentFilterResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentFilterResponseImplCopyWith<_$StudentFilterResponseImpl>
  get copyWith =>
      __$$StudentFilterResponseImplCopyWithImpl<_$StudentFilterResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentFilterResponseImplToJson(this);
  }
}

abstract class _StudentFilterResponse implements StudentFilterResponse {
  const factory _StudentFilterResponse({
    required final List<Student> students,
    required final int total,
    required final int skip,
    required final int limit,
  }) = _$StudentFilterResponseImpl;

  factory _StudentFilterResponse.fromJson(Map<String, dynamic> json) =
      _$StudentFilterResponseImpl.fromJson;

  @override
  List<Student> get students;
  @override
  int get total;
  @override
  int get skip;
  @override
  int get limit;

  /// Create a copy of StudentFilterResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentFilterResponseImplCopyWith<_$StudentFilterResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

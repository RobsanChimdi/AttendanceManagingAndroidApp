// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'ADMIN',
  UserRole.teacher: 'TEACHER',
};

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenType': instance.tokenType,
      'user': instance.user,
    };

_$RefreshTokenRequestImpl _$$RefreshTokenRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenRequestImpl(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$$RefreshTokenRequestImplToJson(
  _$RefreshTokenRequestImpl instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

_$RefreshTokenResponseImpl _$$RefreshTokenResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenResponseImpl(
  accessToken: json['accessToken'] as String,
  tokenType: json['tokenType'] as String,
);

Map<String, dynamic> _$$RefreshTokenResponseImplToJson(
  _$RefreshTokenResponseImpl instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'tokenType': instance.tokenType,
};

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
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
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
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'user': instance.user,
    };

_$RefreshTokenRequestImpl _$$RefreshTokenRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenRequestImpl(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$$RefreshTokenRequestImplToJson(
  _$RefreshTokenRequestImpl instance,
) => <String, dynamic>{'refresh_token': instance.refreshToken};

_$RefreshTokenResponseImpl _$$RefreshTokenResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenResponseImpl(
  accessToken: json['access_token'] as String,
  tokenType: json['token_type'] as String,
);

Map<String, dynamic> _$$RefreshTokenResponseImplToJson(
  _$RefreshTokenResponseImpl instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'token_type': instance.tokenType,
};

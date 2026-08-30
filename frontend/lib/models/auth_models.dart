import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

enum UserRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('TEACHER')
  teacher,
}

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    required UserRole role,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required User user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
}

@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    required String accessToken,
    required String tokenType,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

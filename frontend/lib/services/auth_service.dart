import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../models/auth_models.dart';
import '../storage/secure_storage_service.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Save tokens securely
      await SecureStorageService.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
      
      // Save user info
      await SecureStorageService.saveUserInfo(
        userId: loginResponse.user.id,
        userRole: loginResponse.user.role.name,
      );
      
      // Set auth token for future requests
      ApiClient.setAuthToken(loginResponse.accessToken);
      
      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);
      
      // Save new access token
      await SecureStorageService.saveTokens(
        accessToken: refreshResponse.accessToken,
        refreshToken: refreshToken,
      );
      
      // Update auth token for future requests
      ApiClient.setAuthToken(refreshResponse.accessToken);
      
      return refreshResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid refresh token');
      }
      throw Exception('Token refresh failed: ${e.message}');
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Call logout endpoint (optional, as logout is mainly client-side)
      await _dio.post('/auth/logout');
    } catch (e) {
      // Continue with client-side logout even if API call fails
    } finally {
      // Clear all auth data
      await SecureStorageService.clearAuthData();
      ApiClient.clearAuthToken();
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception('Failed to get current user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}

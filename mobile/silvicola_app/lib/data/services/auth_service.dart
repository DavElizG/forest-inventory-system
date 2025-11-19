import 'api_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal();

  final ApiService _apiService = ApiService.instance;

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/Auth/login',  // Updated to match backend endpoint
        data: {
          'email': email,
          'password': password,
        },
      );

      return _apiService.parseResponse(response);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombreCompleto,
    required String rol,
  }) async {
    try {
      final response = await _apiService.post(
        '/Auth/register',
        data: {
          'email': email,
          'password': password,
          'nombreCompleto': nombreCompleto,
          'rol': rol,
        },
      );

      return _apiService.parseResponse(response);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/Auth/logout');
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Verify token and get user info
  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await _apiService.get('/Auth/verify');
      return _apiService.parseResponse(response);
    } catch (e) {
      throw Exception('Token verification failed: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.post(
        '/Auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }
}
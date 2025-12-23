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
      print('[AUTH] 🔐 Iniciando login para: $email');
      final response = await _apiService.post(
        '/api/Auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = _apiService.parseResponse(response);
      print('[AUTH] 📥 Respuesta del login recibida');
      print('[AUTH] 📋 Datos: ${data.keys.join(", ")}');
      
      // Guardar el token JWT si viene en la respuesta
      if (data['token'] != null) {
        print('[AUTH] ✅ Token encontrado en la respuesta');
        await _apiService.saveToken(data['token']);
      } else {
        print('[AUTH] ⚠️ No se encontró token en la respuesta del login');
      }
      
      return data;
    } catch (e) {
      print('[AUTH] ❌ Error en login: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombreCompleto,
    required int rol,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/Auth/register',
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
    print('[AUTH_SERVICE] 🚪 Iniciando logout...');
    
    // SIEMPRE limpiar el token local primero
    await _apiService.clearToken();
    print('[AUTH_SERVICE] ✅ Token local limpiado');
    
    try {
      // Intentar notificar al servidor (pero no es crítico si falla)
      await _apiService.post('/api/Auth/logout');
      print('[AUTH_SERVICE] ✅ Logout en servidor exitoso');
    } catch (e) {
      // Si el logout en el servidor falla (401, sin internet, etc.), 
      // no es un problema porque ya limpiamos el token local
      print('[AUTH_SERVICE] ⚠️ Error en logout del servidor (ignorado): $e');
    }
  }

  // Verify token and get user info
  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await _apiService.get('/api/Auth/verify');
      return _apiService.parseResponse(response);
    } catch (e) {
      throw Exception('Token verification failed: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.post(
        '/api/Auth/change-password',
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
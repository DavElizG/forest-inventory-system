import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/api_service.dart';
import '../../data/models/auth_models.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/mixins/provider_mixins.dart';

class AuthProvider extends ChangeNotifier
    with OptimizedNotifier, LoadingStateMixin {
  final AuthService _authService = AuthService.instance;
  final SecureStorageService _storage = SecureStorageService();

  bool _isAuthenticated = false;
  Usuario? _currentUser;
  bool _rememberMe = false;
  String? _pendingRoute; // Ruta a la que el usuario intentaba acceder

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Usuario? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  String? get pendingRoute => _pendingRoute;

  // Convenience getters for compatibility
  String? get token => null; // JWT is in HTTP-only cookies
  String? get userName => _currentUser?.nombreCompleto;
  int? get userRole => _currentUser?.rol;

  /// Setter for rememberMe
  set rememberMe(bool value) {
    _rememberMe = value;
    debouncedNotify();
  }

  /// Guardar ruta pendiente para después del login
  void setPendingRoute(String? route) {
    _pendingRoute = route;
    safeNotify();
  }

  /// Obtener y limpiar ruta pendiente
  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    safeNotify();
    return route;
  }

  // Login with email and password
  Future<bool> login(String email, String password,
      {bool rememberMe = false}) async {
    final result = await executeWithLoading(() async {
      final response = await _authService.login(email, password);
      final loginResponse = LoginResponse.fromJson(response);

      _isAuthenticated = true;
      _currentUser = loginResponse.usuario;
      _rememberMe = rememberMe;

      // SIEMPRE guardar datos del usuario (para acceso offline)
      await _storage.saveUserData(_currentUser!.toJson());

      // Guardar credenciales solo si "recordar sesión" está activado
      await _storage.saveCredentials(
        email: email,
        password: rememberMe ? password : '',
        rememberMe: rememberMe,
      );

      return true;
    }, onError: (error) {
      _isAuthenticated = false;
      _currentUser = null;
    });
    return result ?? false;
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String nombreCompleto,
    required int rol,
  }) async {
    final result = await executeWithLoading(() async {
      final response = await _authService.register(
        email: email,
        password: password,
        nombreCompleto: nombreCompleto,
        rol: rol,
      );
      final loginResponse = LoginResponse.fromJson(response);

      _isAuthenticated = true;
      _currentUser = loginResponse.usuario;
      _rememberMe = false;

      // Guardar datos del usuario
      await _storage.saveUserData(_currentUser!.toJson());
      return true;
    }, onError: (error) {
      _isAuthenticated = false;
      _currentUser = null;
    });
    return result ?? false;
  }

  // Logout
  Future<void> logout() async {
    await executeWithLoading(() async {
      print('[AUTH_PROVIDER] 🚪 Cerrando sesión...');

      // Intentar hacer logout en el servidor (aunque falle, continuar)
      try {
        await _authService.logout();
        print('[AUTH_PROVIDER] ✅ Logout exitoso en el servidor');
      } catch (e) {
        print(
            '[AUTH_PROVIDER] ⚠️ Error en logout del servidor (continuando): $e');
      }

      // Limpiar almacenamiento seguro (contrasenas, email, etc.)
      await _storage.clearAll();
      print('[AUTH_PROVIDER] 🗑️ Storage limpiado');
    }, onFinally: () {
      // IMPORTANTE: Limpiar el estado SIEMPRE, incluso si hay errores
      _isAuthenticated = false;
      _currentUser = null;
      _rememberMe = false;
      print('[AUTH_PROVIDER] ✅ Estado de autenticación limpiado');
    });
  }

  // Verify token and restore session (intenta online, fallback a offline)
  Future<bool> verifyToken() async {
    final result = await executeWithLoading(() async {
      // Primero verificar si hay un token guardado
      final hasToken = await ApiService.instance.getToken();
      if (hasToken == null) {
        return false;
      }

      try {
        // Intentar verificar token contra el servidor
        final response = await _authService.verifyToken();
        final usuario = Usuario.fromJson(response);

        _isAuthenticated = true;
        _currentUser = usuario;
        _rememberMe = await _storage.shouldRememberMe();

        // Actualizar datos locales con la respuesta del servidor
        await _storage.saveUserData(_currentUser!.toJson());

        return true;
      } catch (e) {
        // Si falla la verificación online, intentar cargar desde storage local
        await loadUserFromStorage();

        if (_isAuthenticated && _currentUser != null) {
          return true;
        }

        return false;
      }
    });
    return result ?? false;
  }

  /// Intentar auto-login con credenciales guardadas
  Future<bool> tryAutoLogin() async {
    final result = await executeWithLoading(() async {
      // Verificar si debe recordar sesión
      final shouldRemember = await _storage.shouldRememberMe();

      if (!shouldRemember) {
        // Si NO debe recordar, intentar cargar datos locales (modo offline)
        // pero SOLO si no hubo un logout explícito
        final hasUserData = await _storage.getUserData();
        if (hasUserData != null) {
          await loadUserFromStorage();
          return _isAuthenticated;
        }
        return false;
      }

      // Primero intentar cargar datos del usuario desde storage local
      await loadUserFromStorage();

      // Si hay usuario guardado, considerarlo autenticado
      if (_currentUser != null) {
        _isAuthenticated = true;
        return true;
      }

      // Si no hay datos locales, intentar obtener credenciales guardadas
      final email = await _storage.getSavedEmail();
      final password = await _storage.getSavedPassword();

      if (email == null || password == null) {
        return false;
      }

      // Intentar login con credenciales guardadas (solo si hay internet)
      return await login(email, password, rememberMe: true);
    }, onError: (error) {
      // Si falla el login pero hay datos locales, usar esos
      loadUserFromStorage();
    });
    return result ?? false;
  }

  /// Cargar datos del usuario desde storage (para modo offline)
  Future<void> loadUserFromStorage() async {
    try {
      final userData = await _storage.getUserData();
      if (userData != null && userData.isNotEmpty) {
        _currentUser = Usuario.fromJson(userData);
        _isAuthenticated = true;
        _rememberMe = await _storage.shouldRememberMe();
        safeNotify();
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
    }
  }

  // Change password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final result = await executeWithLoading(() async {
      await _authService.changePassword(currentPassword, newPassword);
      return true;
    });
    return result ?? false;
  }
}

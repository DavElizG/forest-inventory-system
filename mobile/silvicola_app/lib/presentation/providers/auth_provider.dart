import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/auth_models.dart';
import '../../core/services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final SecureStorageService _storage = SecureStorageService();
  
  bool _isAuthenticated = false;
  Usuario? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _pendingRoute; // Ruta a la que el usuario intentaba acceder

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Usuario? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String? get pendingRoute => _pendingRoute;

  // Convenience getters for compatibility
  String? get token => null; // JWT is in HTTP-only cookies
  String? get userName => _currentUser?.nombreCompleto;
  int? get userRole => _currentUser?.rol;

  /// Setter for rememberMe
  set rememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Guardar ruta pendiente para después del login
  void setPendingRoute(String? route) {
    _pendingRoute = route;
    notifyListeners();
  }

  /// Obtener y limpiar ruta pendiente
  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    notifyListeners();
    return route;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Login with email and password
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.login(email, password);
      final loginResponse = LoginResponse.fromJson(response);

      _isAuthenticated = true;
      _currentUser = loginResponse.usuario;
      _rememberMe = rememberMe;
      _errorMessage = null;

      // SIEMPRE guardar datos del usuario (para acceso offline)
      await _storage.saveUserData(_currentUser!.toJson());
      
      // Guardar credenciales solo si "recordar sesión" está activado
      await _storage.saveCredentials(
        email: email,
        password: rememberMe ? password : '',
        rememberMe: rememberMe,
      );
      
      print('✅ Login exitoso - Usuario guardado localmente: ${_currentUser?.nombreCompleto}');
      
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      
      print('❌ Error en login: $_errorMessage');
      
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String nombreCompleto,
    required int rol,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

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
      _errorMessage = null;

      // Guardar datos del usuario
      await _storage.saveUserData(_currentUser!.toJson());
      
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      
      // Limpiar almacenamiento seguro
      await _storage.clearAll();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _rememberMe = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify token and restore session (intenta online, fallback a offline)
  Future<bool> verifyToken() async {
    try {
      _isLoading = true;
      notifyListeners();

      try {
        // Intentar verificar token contra el servidor
        final response = await _authService.verifyToken();
        final usuario = Usuario.fromJson(response);

        _isAuthenticated = true;
        _currentUser = usuario;
        _rememberMe = await _storage.shouldRememberMe();
        _errorMessage = null;
        
        // Actualizar datos locales con la respuesta del servidor
        await _storage.saveUserData(_currentUser!.toJson());
        
        print('✅ Token verificado online');
        notifyListeners();
        return true;
      } catch (e) {
        // Si falla la verificación online, intentar cargar desde storage local
        print('⚠️ Error al verificar token online, intentando offline: $e');
        await loadUserFromStorage();
        
        if (_isAuthenticated && _currentUser != null) {
          print('✅ Usando sesión offline con datos guardados');
          return true;
        }
        
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Intentar auto-login con credenciales guardadas
  Future<bool> tryAutoLogin() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verificar si debe recordar sesión
      final shouldRemember = await _storage.shouldRememberMe();
      if (!shouldRemember) {
        // Intentar cargar datos locales aunque no se haya marcado "recordar"
        await loadUserFromStorage();
        return _isAuthenticated;
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
    } catch (e) {
      // Si falla el login pero hay datos locales, usar esos
      await loadUserFromStorage();
      return _isAuthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar datos del usuario desde storage (para modo offline)
  Future<void> loadUserFromStorage() async {
    try {
      final userData = await _storage.getUserData();
      if (userData != null && userData.isNotEmpty) {
        _currentUser = Usuario.fromJson(userData);
        _isAuthenticated = true;
        _rememberMe = await _storage.shouldRememberMe();
        print('✅ Usuario cargado desde storage local: ${_currentUser?.nombreCompleto}');
        notifyListeners();
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        print('❌ No hay datos de usuario en storage local');
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      print('⚠️ Error al cargar usuario desde storage: $e');
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.changePassword(currentPassword, newPassword);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

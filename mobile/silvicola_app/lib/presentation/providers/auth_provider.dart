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
  String? get userRole => _currentUser?.rol;

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

      // Guardar credenciales si "recordar sesión" está activado
      await _storage.saveCredentials(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

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

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String nombreCompleto,
    required String rol,
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

  // Verify token and restore session
  Future<bool> verifyToken() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.verifyToken();
      final usuario = Usuario.fromJson(response);

      _isAuthenticated = true;
      _currentUser = usuario;
      _rememberMe = await _storage.shouldRememberMe();
      _errorMessage = null;
      
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      // Don't set error message for failed token verification
      
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
        return false;
      }

      // Intentar obtener credenciales guardadas
      final email = await _storage.getSavedEmail();
      final password = await _storage.getSavedPassword();

      if (email == null || password == null) {
        return false;
      }

      // Intentar login con credenciales guardadas
      return await login(email, password, rememberMe: true);
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar datos del usuario desde storage
  Future<void> loadUserFromStorage() async {
    try {
      final userData = await _storage.getUserData();
      if (userData != null) {
        _currentUser = Usuario.fromJson(userData);
        _isAuthenticated = true;
        _rememberMe = await _storage.shouldRememberMe();
        notifyListeners();
      }
    } catch (e) {
      // Ignorar errores al cargar datos
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

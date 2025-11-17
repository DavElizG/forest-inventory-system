import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Servicio para almacenar credenciales de forma segura
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'email';
  static const String _keyPassword = 'password';
  static const String _keyToken = 'token';
  static const String _keyUserData = 'user_data';
  static const String _keyTokenExpiry = 'token_expiry';

  /// Guardar credenciales de login
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await _storage.write(key: _keyRememberMe, value: rememberMe.toString());
    
    if (rememberMe) {
      await _storage.write(key: _keyEmail, value: email);
      await _storage.write(key: _keyPassword, value: password);
    } else {
      await clearCredentials();
    }
  }

  /// Obtener email guardado
  Future<String?> getSavedEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  /// Obtener contraseña guardada
  Future<String?> getSavedPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  /// Verificar si "recordar sesión" está activo
  Future<bool> shouldRememberMe() async {
    final rememberMe = await _storage.read(key: _keyRememberMe);
    return rememberMe == 'true';
  }

  /// Guardar token de autenticación
  Future<void> saveToken(String token, DateTime expiresAt) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyTokenExpiry, value: expiresAt.toIso8601String());
  }

  /// Obtener token guardado
  Future<String?> getToken() async {
    final token = await _storage.read(key: _keyToken);
    final expiryStr = await _storage.read(key: _keyTokenExpiry);
    
    if (token == null || expiryStr == null) {
      return null;
    }

    // Verificar si el token expiró
    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      await clearToken();
      return null;
    }

    return token;
  }

  /// Guardar datos del usuario
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await _storage.write(key: _keyUserData, value: userJson);
  }

  /// Obtener datos del usuario guardados
  Future<Map<String, dynamic>?> getUserData() async {
    final userJson = await _storage.read(key: _keyUserData);
    if (userJson == null) return null;

    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Limpiar credenciales
  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
  }

  /// Limpiar token
  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyTokenExpiry);
  }

  /// Limpiar todo (logout completo)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Verificar si hay sesión activa
  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null;
  }
}

import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userName;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userName => _userName;
  String? get userRole => _userRole;

  Future<void> login(String email, String password) async {
    // TODO: Implementar login con backend
    _isAuthenticated = true;
    _token = 'mock_token';
    _userName = email;
    _userRole = 'user';
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _userName = null;
    _userRole = null;
    notifyListeners();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    // TODO: Implementar cambio de contraseña
    notifyListeners();
  }
}

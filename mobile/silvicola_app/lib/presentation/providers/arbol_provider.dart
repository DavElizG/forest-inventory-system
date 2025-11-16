import 'package:flutter/material.dart';

class ArbolProvider extends ChangeNotifier {
  List<dynamic> _arboles = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get arboles => _arboles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchArboles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implementar fetch de árboles desde DB local y remote
      _arboles = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveArbol(Map<String, dynamic> arbolData) async {
    // TODO: Implementar guardado de árbol
    notifyListeners();
  }

  Future<void> deleteArbol(int id) async {
    // TODO: Implementar eliminación de árbol
    notifyListeners();
  }
}

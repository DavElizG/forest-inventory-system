import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';

class ArbolProvider extends ChangeNotifier {
  final LocalDatabase _db = LocalDatabase.instance;
  
  List<Map<String, dynamic>> _arboles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get arboles => _arboles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtener todos los árboles o filtrar por parcela
  Future<void> fetchArboles({String? parcelaId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      if (parcelaId != null && parcelaId.isNotEmpty) {
        // Filtrar por parcela
        _arboles = await database.query(
          'arboles',
          where: 'parcelaId = ? AND activo = ?',
          whereArgs: [parcelaId, 1],
          orderBy: 'fechaCreacion DESC',
        );
      } else {
        // Obtener todos
        _arboles = await database.query(
          'arboles',
          where: 'activo = ?',
          whereArgs: [1],
          orderBy: 'fechaCreacion DESC',
        );
      }
    } catch (e) {
      _errorMessage = 'Error al cargar árboles: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buscar árboles
  Future<void> searchArboles(String query, {String? parcelaId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      if (parcelaId != null && parcelaId.isNotEmpty) {
        _arboles = await database.query(
          'arboles',
          where: 'parcelaId = ? AND activo = ? AND nombreLocal LIKE ?',
          whereArgs: [parcelaId, 1, '%$query%'],
          orderBy: 'fechaCreacion DESC',
        );
      } else {
        _arboles = await database.query(
          'arboles',
          where: 'activo = ? AND nombreLocal LIKE ?',
          whereArgs: [1, '%$query%'],
          orderBy: 'fechaCreacion DESC',
        );
      }
    } catch (e) {
      _errorMessage = 'Error al buscar árboles: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guardar o actualizar árbol
  Future<bool> saveArbol(Map<String, dynamic> arbolData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      // Verificar si existe
      final existing = await database.query(
        'arboles',
        where: 'id = ?',
        whereArgs: [arbolData['id']],
      );

      if (existing.isEmpty) {
        // Crear nuevo
        arbolData['fechaCreacion'] = DateTime.now().toIso8601String();
        arbolData['fechaModificacion'] = DateTime.now().toIso8601String();
        await database.insert('arboles', arbolData);
      } else {
        // Actualizar existente
        arbolData['fechaModificacion'] = DateTime.now().toIso8601String();
        arbolData['sincronizado'] = 0; // Marcar como no sincronizado
        await database.update(
          'arboles',
          arbolData,
          where: 'id = ?',
          whereArgs: [arbolData['id']],
        );
      }

      await fetchArboles(); // Recargar lista
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar árbol: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eliminar árbol (soft delete)
  Future<bool> deleteArbol(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      await database.update(
        'arboles',
        {
          'activo': 0,
          'sincronizado': 0,
          'fechaModificacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await fetchArboles(); // Recargar lista
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar árbol: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener un árbol por ID
  Future<Map<String, dynamic>?> getArbolById(String id) async {
    try {
      final database = await _db.database;
      final result = await database.query(
        'arboles',
        where: 'id = ? AND activo = ?',
        whereArgs: [id, 1],
      );
      
      return result.isEmpty ? null : result.first;
    } catch (e) {
      _errorMessage = 'Error al obtener árbol: ${e.toString()}';
      return null;
    }
  }
}

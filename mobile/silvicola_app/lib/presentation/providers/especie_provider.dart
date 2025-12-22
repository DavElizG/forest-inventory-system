import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';

class EspecieProvider extends ChangeNotifier {
  final LocalDatabase _db = LocalDatabase.instance;
  
  List<Map<String, dynamic>> _especies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get especies => _especies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtener todas las especies
  Future<void> fetchEspecies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      _especies = await database.query(
        'especies',
        where: 'activo = ?',
        whereArgs: [1],
        orderBy: 'nombre_cientifico ASC',
      );
    } catch (e) {
      _errorMessage = 'Error al cargar especies: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buscar especies
  Future<void> searchEspecies(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      _especies = await database.query(
        'especies',
        where: 'activo = ? AND (nombre_comun LIKE ? OR nombre_cientifico LIKE ?)',
        whereArgs: [1, '%$query%', '%$query%'],
        orderBy: 'nombre_cientifico ASC',
      );
    } catch (e) {
      _errorMessage = 'Error al buscar especies: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guardar o actualizar especie
  Future<bool> saveEspecie(Map<String, dynamic> especieData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      // Verificar si existe
      final existing = await database.query(
        'especies',
        where: 'id = ?',
        whereArgs: [especieData['id']],
      );

      if (existing.isEmpty) {
        // Crear nueva
        especieData['fecha_creacion'] = DateTime.now().toIso8601String();
        especieData['fecha_actualizacion'] = DateTime.now().toIso8601String();
        especieData['activo'] = 1;
        await database.insert('especies', especieData);
      } else {
        // Actualizar existente
        especieData['fecha_actualizacion'] = DateTime.now().toIso8601String();
        especieData['sincronizado'] = 0;
        await database.update(
          'especies',
          especieData,
          where: 'id = ?',
          whereArgs: [especieData['id']],
        );
      }

      await fetchEspecies();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar especie: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eliminar especie (soft delete)
  Future<bool> deleteEspecie(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final database = await _db.database;
      
      await database.update(
        'especies',
        {
          'activo': 0,
          'sincronizado': 0,
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await fetchEspecies();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar especie: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener una especie por ID
  Future<Map<String, dynamic>?> getEspecieById(String id) async {
    try {
      final database = await _db.database;
      final result = await database.query(
        'especies',
        where: 'id = ? AND activo = ?',
        whereArgs: [id, 1],
      );
      
      return result.isEmpty ? null : result.first;
    } catch (e) {
      _errorMessage = 'Error al obtener especie: ${e.toString()}';
      return null;
    }
  }
}

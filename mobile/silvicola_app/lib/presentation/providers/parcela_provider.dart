import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';

class ParcelaProvider extends ChangeNotifier {
  final LocalDatabase _localDatabase = LocalDatabase.instance;
  List<Map<String, dynamic>> _parcelas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get parcelas => _parcelas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtiene todas las parcelas desde la base de datos local
  Future<void> fetchParcelas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await _localDatabase.database;
      _parcelas = await db.query(
        'parcelas',
        orderBy: 'fechaCreacion DESC',
      );
    } catch (e) {
      _errorMessage = 'Error al cargar parcelas: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca parcelas por código
  Future<void> searchParcelas(String query) async {
    if (query.isEmpty) {
      await fetchParcelas();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await _localDatabase.database;
      _parcelas = await db.query(
        'parcelas',
        where: 'codigo LIKE ? OR descripcion LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'fechaCreacion DESC',
      );
    } catch (e) {
      _errorMessage = 'Error al buscar parcelas: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea o actualiza una parcela
  Future<bool> saveParcela(Map<String, dynamic> parcelaData) async {
    try {
      final db = await _localDatabase.database;
      
      if (parcelaData['id'] != null) {
        // Actualizar
        parcelaData['fechaUltimaActualizacion'] = DateTime.now().toIso8601String();
        await db.update(
          'parcelas',
          parcelaData,
          where: 'id = ?',
          whereArgs: [parcelaData['id']],
        );
      } else {
        // Crear nueva
        parcelaData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        parcelaData['fechaCreacion'] = DateTime.now().toIso8601String();
        parcelaData['sincronizado'] = 0;
        parcelaData['activo'] = 1;
        await db.insert('parcelas', parcelaData);
      }
      
      await fetchParcelas();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar parcela: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una parcela (soft delete)
  Future<bool> deleteParcela(String id) async {
    try {
      final db = await _localDatabase.database;
      await db.update(
        'parcelas',
        {'activo': 0, 'sincronizado': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      await fetchParcelas();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar parcela: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Obtiene una parcela por ID
  Future<Map<String, dynamic>?> getParcelaById(String id) async {
    try {
      final db = await _localDatabase.database;
      final result = await db.query(
        'parcelas',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      _errorMessage = 'Error al obtener parcela: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

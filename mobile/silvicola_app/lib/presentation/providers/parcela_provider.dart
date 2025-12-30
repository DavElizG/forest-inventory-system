import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';
import '../../data/services/sync_service.dart';

class ParcelaProvider extends ChangeNotifier {
  final LocalDatabase _localDatabase = LocalDatabase.instance;
  final SyncService? _syncService;
  List<Map<String, dynamic>> _parcelas = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  // Paginación
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  ParcelaProvider({SyncService? syncService}) : _syncService = syncService;

  List<Map<String, dynamic>> get parcelas => _parcelas;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// Obtiene las parcelas de la primera página
  Future<void> fetchParcelas() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final db = await _localDatabase.database;
      _parcelas = await db.query(
        'parcelas',
        orderBy: 'fecha_creacion DESC',
        limit: _pageSize,
      );
      
      _hasMore = _parcelas.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Error al cargar parcelas: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga más parcelas (siguiente página)
  Future<void> fetchMoreParcelas() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final db = await _localDatabase.database;
      final newParcelas = await db.query(
        'parcelas',
        orderBy: 'fecha_creacion DESC',
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (newParcelas.isNotEmpty) {
        _parcelas.addAll(newParcelas);
        _currentPage++;
        _hasMore = newParcelas.length == _pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar más parcelas: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
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
        orderBy: 'fecha_creacion DESC',
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
        parcelaData['fecha_actualizacion'] = DateTime.now().toIso8601String();
        await db.update(
          'parcelas',
          parcelaData,
          where: 'id = ?',
          whereArgs: [parcelaData['id']],
        );
      } else {
        // Crear nueva
        parcelaData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        parcelaData['fecha_creacion'] = DateTime.now().toIso8601String();
        parcelaData['sincronizado'] = 0;
        parcelaData['activo'] = 1;
        await db.insert('parcelas', parcelaData);
      }
      
      await fetchParcelas();
      // Actualizar contadores de sincronización
      await _syncService?.updatePendingCounts();
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
      await _localDatabase.deleteParcela(id);
      await fetchParcelas();
      // Actualizar contadores de sincronización
      await _syncService?.updatePendingCounts();
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

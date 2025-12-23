import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';

class ArbolProvider extends ChangeNotifier {
  final LocalDatabase _db = LocalDatabase.instance;
  
  List<Map<String, dynamic>> _arboles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  // Paginación
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String? _currentParcelaId;

  List<Map<String, dynamic>> get arboles => _arboles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// Obtener árboles de la primera página
  Future<void> fetchArboles({String? parcelaId}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _currentParcelaId = parcelaId;
    notifyListeners();

    try {
      final database = await _db.database;
      
      if (parcelaId != null && parcelaId.isNotEmpty) {
        _arboles = await database.rawQuery('''
          SELECT 
            a.*,
            e.nombre_cientifico as especieNombre,
            e.nombre_comun as especieNombreComun,
            p.codigo as parcelaCodigo,
            p.nombre as parcelaNombre
          FROM arboles a
          LEFT JOIN especies e ON a.especie_id = e.id
          LEFT JOIN parcelas p ON a.parcela_id = p.id
          WHERE a.parcela_id = ? AND a.activo = 1
          ORDER BY a.fecha_creacion DESC
          LIMIT ?
        ''', [parcelaId, _pageSize]);
      } else {
        _arboles = await database.rawQuery('''
          SELECT 
            a.*,
            e.nombre_cientifico as especieNombre,
            e.nombre_comun as especieNombreComun,
            p.codigo as parcelaCodigo,
            p.nombre as parcelaNombre
          FROM arboles a
          LEFT JOIN especies e ON a.especie_id = e.id
          LEFT JOIN parcelas p ON a.parcela_id = p.id
          WHERE a.activo = 1
          ORDER BY a.fecha_creacion DESC
          LIMIT ?
        ''', [_pageSize]);
      }
      
      _hasMore = _arboles.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Error al cargar árboles: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar más árboles (siguiente página)
  Future<void> fetchMoreArboles() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final database = await _db.database;
      List<Map<String, dynamic>> newArboles;
      final offset = _currentPage * _pageSize;
      
      if (_currentParcelaId != null && _currentParcelaId!.isNotEmpty) {
        newArboles = await database.rawQuery('''
          SELECT 
            a.*,
            e.nombre_cientifico as especieNombre,
            e.nombre_comun as especieNombreComun,
            p.codigo as parcelaCodigo,
            p.nombre as parcelaNombre
          FROM arboles a
          LEFT JOIN especies e ON a.especie_id = e.id
          LEFT JOIN parcelas p ON a.parcela_id = p.id
          WHERE a.parcela_id = ? AND a.activo = 1
          ORDER BY a.fecha_creacion DESC
          LIMIT ? OFFSET ?
        ''', [_currentParcelaId, _pageSize, offset]);
      } else {
        newArboles = await database.rawQuery('''
          SELECT 
            a.*,
            e.nombre_cientifico as especieNombre,
            e.nombre_comun as especieNombreComun,
            p.codigo as parcelaCodigo,
            p.nombre as parcelaNombre
          FROM arboles a
          LEFT JOIN especies e ON a.especie_id = e.id
          LEFT JOIN parcelas p ON a.parcela_id = p.id
          WHERE a.activo = 1
          ORDER BY a.fecha_creacion DESC
          LIMIT ? OFFSET ?
        ''', [_pageSize, offset]);
      }

      if (newArboles.isNotEmpty) {
        _arboles.addAll(newArboles);
        _currentPage++;
        _hasMore = newArboles.length == _pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar más árboles: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
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
          where: 'parcela_id = ? AND activo = ? AND (numero_arbol LIKE ? OR observaciones LIKE ?)',
          whereArgs: [parcelaId, 1, '%$query%', '%$query%'],
          orderBy: 'fecha_creacion DESC',
        );
      } else {
        _arboles = await database.query(
          'arboles',
          where: 'activo = ? AND (numero_arbol LIKE ? OR observaciones LIKE ?)',
          whereArgs: [1, '%$query%', '%$query%'],
          orderBy: 'fecha_creacion DESC',
        );
      }
    } catch (e) {
      _errorMessage = 'Error al buscar árboles: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener el siguiente número de árbol para una parcela específica
  Future<int> getNextNumeroArbol(String parcelaId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery('''
        SELECT COALESCE(MAX(numero_arbol), 0) + 1 as next_numero
        FROM arboles
        WHERE parcela_id = ? AND activo = 1
      ''', [parcelaId]);
      
      if (result.isNotEmpty && result.first['next_numero'] != null) {
        return result.first['next_numero'] as int;
      }
      return 1;
    } catch (e) {
      _errorMessage = 'Error al obtener número de árbol: ${e.toString()}';
      return 1; // Por defecto retornar 1 si hay error
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
        arbolData['fecha_creacion'] = DateTime.now().toIso8601String();
        arbolData['fecha_actualizacion'] = DateTime.now().toIso8601String();
        arbolData['activo'] = 1;
        await database.insert('arboles', arbolData);
      } else {
        // Actualizar existente
        arbolData['fecha_actualizacion'] = DateTime.now().toIso8601String();
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
          'fecha_actualizacion': DateTime.now().toIso8601String(),
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

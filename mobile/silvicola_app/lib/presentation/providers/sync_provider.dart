import 'package:flutter/material.dart';
import '../../data/services/sync_service.dart';
import '../../data/local/local_database.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final LocalDatabase _localDatabase = LocalDatabase.instance;
  
  bool _isSyncing = false;
  int _pendingCount = 0;
  DateTime? _lastSyncTime;
  String? _errorMessage;

  SyncProvider(this._syncService);

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;

  Future<void> sync() async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _syncService.syncAll();
      _lastSyncTime = DateTime.now();
      await checkPendingItems();
    } catch (e) {
      _errorMessage = 'Error al sincronizar: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> checkPendingItems() async {
    try {
      final db = await _localDatabase.database;
      
      // Contar parcelas pendientes
      final parcelasResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM parcelas WHERE sincronizado = 0'
      );
      final parcelasCount = parcelasResult.first['count'] as int;
      
      // Contar árboles pendientes
      final arbolesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM arboles WHERE sincronizado = 0'
      );
      final arbolesCount = arbolesResult.first['count'] as int;
      
      // Contar especies pendientes
      final especiesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM especies WHERE sincronizado = 0'
      );
      final especiesCount = especiesResult.first['count'] as int;
      
      // Contar fotos pendientes
      final fotosResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM fotos WHERE sincronizado = 0'
      );
      final fotosCount = fotosResult.first['count'] as int;
      
      _pendingCount = parcelasCount + arbolesCount + especiesCount + fotosCount;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al contar items pendientes: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

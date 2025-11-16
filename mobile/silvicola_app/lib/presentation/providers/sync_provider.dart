import 'package:flutter/material.dart';

class SyncProvider extends ChangeNotifier {
  bool _isSyncing = false;
  int _pendingCount = 0;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> sync() async {
    _isSyncing = true;
    notifyListeners();

    try {
      // TODO: Implementar sincronización
      _lastSyncTime = DateTime.now();
      _pendingCount = 0;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> checkPendingItems() async {
    // TODO: Contar items pendientes de sincronización
    notifyListeners();
  }
}

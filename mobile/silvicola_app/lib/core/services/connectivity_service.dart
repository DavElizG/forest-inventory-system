import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Servicio para monitorear la conectividad a Internet
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isOnline = false;
  bool _isSyncing = false;
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  
  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error al verificar conectividad: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    
    // Verificar si hay al menos una conexión activa (WiFi, Móvil, Ethernet)
    _isOnline = result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet;
    
    debugPrint('Estado de conexión: ${_isOnline ? "Online" : "Offline"}');
    
    // Si cambió de offline a online, notificar
    if (!wasOnline && _isOnline) {
      debugPrint('📶 Conectividad restaurada');
    } else if (wasOnline && !_isOnline) {
      debugPrint('📵 Conectividad perdida');
    }
    
    notifyListeners();
  }

  void setSyncStatus(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

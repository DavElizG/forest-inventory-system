import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../local/local_database.dart';
import '../../core/services/connectivity_service.dart';
import 'api_service.dart';
import 'sync/sync_download_service.dart';
import 'sync/sync_upload_service.dart';
import 'sync/sync_result.dart';

/// Servicio de sincronización bidireccional (offline-first)
/// Coordina la descarga (pull) y subida (push) de datos
class SyncService extends ChangeNotifier {
  final LocalDatabase _localDB = LocalDatabase.instance;
  final ConnectivityService _connectivityService;
  final ApiService _apiService;
  final Logger _logger = Logger();
  
  late final SyncDownloadService _downloadService;
  late final SyncUploadService _uploadService;
  
  Dio get _dio => _apiService.dio;
  
  Timer? _autoSyncTimer;
  Timer? _connectivityDebounceTimer;
  DateTime? _lastSyncAttempt;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _lastSyncError;
  Map<String, int> _pendingCounts = {};
  
  // Cooldown de 30 segundos entre sincronizaciones automáticas
  static const _syncCooldownDuration = Duration(seconds: 30);
  
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastSyncError => _lastSyncError;
  Map<String, int> get pendingCounts => _pendingCounts;
  int get totalPending => _pendingCounts.values.fold(0, (sum, count) => sum + count);

  SyncService({
    required ConnectivityService connectivityService,
    required ApiService apiService,
  })  : _connectivityService = connectivityService,
        _apiService = apiService {
    // Inicializar servicios auxiliares
    _downloadService = SyncDownloadService(
      localDB: _localDB,
      dio: _dio,
      logger: _logger,
    );
    _uploadService = SyncUploadService(
      localDB: _localDB,
      dio: _dio,
      logger: _logger,
      apiService: _apiService,
    );
    _init();
  }

  void _init() {
    // Actualizar contadores al iniciar
    _updatePendingCounts();
    
    // Escuchar cambios de conectividad
    _connectivityService.addListener(_onConnectivityChanged);
    
    // Configurar sincronización automática cada 5 minutos
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectivityService.isOnline && !_isSyncing) {
        syncAll();
      }
    });
  }

  void _onConnectivityChanged() {
    // Cancelar el timer anterior si existe
    _connectivityDebounceTimer?.cancel();
    
    // Esperar 2 segundos antes de sincronizar (debouncing)
    _connectivityDebounceTimer = Timer(const Duration(seconds: 2), () {
      // Verificar cooldown: no sincronizar si acabamos de hacerlo hace menos de 30 segundos
      if (_lastSyncAttempt != null) {
        final timeSinceLastSync = DateTime.now().difference(_lastSyncAttempt!);
        if (timeSinceLastSync < _syncCooldownDuration) {
          _logger.i('⏱️ Cooldown activo, esperando ${_syncCooldownDuration.inSeconds - timeSinceLastSync.inSeconds}s más');
          return;
        }
      }
      
      if (_connectivityService.isOnline && !_isSyncing && totalPending > 0) {
        _logger.i('📶 Conectividad restaurada, iniciando sincronización automática...');
        syncAll();
      }
    });
  }

  /// Actualizar contadores de registros pendientes (público para llamar desde formularios)
  Future<void> updatePendingCounts() async {
    try {
      _pendingCounts = await _localDB.getContadoresSincronizacion();
      notifyListeners();
    } catch (e) {
      _logger.e('Error actualizando contadores: $e');
    }
  }

  /// Actualizar contadores internamente sin notificar
  Future<void> _updatePendingCounts({bool notify = true}) async {
    try {
      _pendingCounts = await _localDB.getContadoresSincronizacion();
      if (notify) {
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error actualizando contadores: $e');
    }
  }

  /// Sincronizar todos los datos pendientes
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Ya hay una sincronización en curso',
        synced: 0,
        failed: 0,
      );
    }

    // Verificar si hay un token de autenticación
    final token = await _apiService.getToken();
    if (token == null) {
      _logger.w('⚠️ No hay token de autenticación, omitiendo sincronización');
      return SyncResult(
        success: false,
        message: 'No autorizado. Inicia sesión para sincronizar.',
        synced: 0,
        failed: 0,
      );
    }

    if (!_connectivityService.isOnline) {
      return SyncResult(
        success: false,
        message: 'Sin conexión a Internet',
        synced: 0,
        failed: 0,
      );
    }

    // Registrar intento de sincronización (para cooldown)
    _lastSyncAttempt = DateTime.now();
    _isSyncing = true;
    _lastSyncError = null;
    _connectivityService.setSyncStatus(true);
    // NO llamar notifyListeners() aquí - esperar al final

    int totalSynced = 0;
    int totalFailed = 0;
    final List<String> errors = [];

    try {
      _logger.i('🔄 Iniciando sincronización...');

      // Limpiar registros corruptos ANTES de sincronizar
      _logger.i('🗑️ Limpiando árboles con referencias inválidas...');
      final arbolesEliminados = await _localDB.eliminarArbolesConReferenciasInvalidas();
      if (arbolesEliminados > 0) {
        _logger.i('✅ Eliminados $arbolesEliminados árboles con IDs corruptos');
      }

      // FASE 1: DESCARGAR datos del servidor (Pull)
      _logger.i('⬇️ Descargando datos del servidor...');
      await _downloadService.downloadEspecies();
      await _downloadService.downloadParcelas();
      await _downloadService.downloadArboles();

      // FASE 2: SUBIR cambios locales al servidor (Push)
      _logger.i('⬆️ Subiendo cambios locales...');

      final especiesResult = await _uploadService.syncEspecies();
      totalSynced += especiesResult.synced;
      totalFailed += especiesResult.failed;
      if (!especiesResult.success) errors.add(especiesResult.message);

      final parcelasResult = await _uploadService.syncParcelas();
      totalSynced += parcelasResult.synced;
      totalFailed += parcelasResult.failed;
      if (!parcelasResult.success) errors.add(parcelasResult.message);

      final arbolesResult = await _uploadService.syncArboles();
      totalSynced += arbolesResult.synced;
      totalFailed += arbolesResult.failed;
      if (!arbolesResult.success) errors.add(arbolesResult.message);

      final fotosResult = await _uploadService.syncFotos();
      totalSynced += fotosResult.synced;
      totalFailed += fotosResult.failed;
      if (!fotosResult.success) errors.add(fotosResult.message);

      _lastSyncTime = DateTime.now();
      _lastSyncError = errors.isEmpty ? null : errors.join(', ');

      _logger.i('✅ Sincronización completada: $totalSynced exitosos, $totalFailed fallidos');

      // Actualizar contadores sin notificar (lo haremos en el finally)
      await _updatePendingCounts(notify: false);

      return SyncResult(
        success: totalFailed == 0,
        message: errors.isEmpty ? 'Sincronización exitosa' : errors.join(', '),
        synced: totalSynced,
        failed: totalFailed,
      );
    } catch (e) {
      _logger.e('❌ Error en sincronización: $e');
      _lastSyncError = e.toString();
      
      return SyncResult(
        success: false,
        message: 'Error: $e',
        synced: totalSynced,
        failed: totalFailed,
      );
    } finally {
      _isSyncing = false;
      _connectivityService.setSyncStatus(false);
      // Solo notificar UNA VEZ al final
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivityDebounceTimer?.cancel();
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}

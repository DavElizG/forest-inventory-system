import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../local/local_database.dart';
import '../../core/services/connectivity_service.dart';
import 'api_service.dart';

/// Servicio de sincronización automática entre base de datos local y servidor
class SyncService extends ChangeNotifier {
  final LocalDatabase _localDB = LocalDatabase.instance;
  final ConnectivityService _connectivityService;
  final ApiService _apiService;
  final Logger _logger = Logger();
  
  // Usar el Dio del ApiService que ya tiene el interceptor de auth
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

      // 1. Sincronizar Especies
      final especiesResult = await _syncEspecies();
      totalSynced += especiesResult.synced;
      totalFailed += especiesResult.failed;
      if (!especiesResult.success) errors.add(especiesResult.message);

      // 2. Sincronizar Parcelas
      final parcelasResult = await _syncParcelas();
      totalSynced += parcelasResult.synced;
      totalFailed += parcelasResult.failed;
      if (!parcelasResult.success) errors.add(parcelasResult.message);

      // 3. Sincronizar Árboles
      final arbolesResult = await _syncArboles();
      totalSynced += arbolesResult.synced;
      totalFailed += arbolesResult.failed;
      if (!arbolesResult.success) errors.add(arbolesResult.message);

      // 4. Sincronizar Fotos
      final fotosResult = await _syncFotos();
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

  /// Sincronizar Especies
  Future<SyncResult> _syncEspecies() async {
    try {
      final especies = await _localDB.getEspecies(soloNoSincronizadas: true);
      int synced = 0;
      int failed = 0;

      for (final especie in especies) {
        try {
          final response = await _dio.post(
            '/api/Especies',
            data: {
              'nombreCientifico': especie['nombre_cientifico'],
              'nombreComun': especie['nombre_comun'],
              'familia': especie['familia'],
              'descripcion': especie['descripcion'],
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _localDB.marcarEspecieSincronizada(especie['id']);
            await _localDB.registrarSyncLog(
              tabla: 'especies',
              registroId: especie['id'],
              operacion: 'CREATE',
              exito: true,
            );
            synced++;
          }
        } catch (e) {
          _logger.w('Error sincronizando especie ${especie['id']}: $e');
          await _localDB.registrarSyncLog(
            tabla: 'especies',
            registroId: especie['id'],
            operacion: 'CREATE',
            exito: false,
            mensaje: e.toString(),
          );
          failed++;
        }
      }

      return SyncResult(
        success: failed == 0,
        message: 'Especies: $synced sincronizadas, $failed fallidas',
        synced: synced,
        failed: failed,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando especies: $e',
        synced: 0,
        failed: 0,
      );
    }
  }

  /// Sincronizar Parcelas
  Future<SyncResult> _syncParcelas() async {
    try {
      final parcelas = await _localDB.getParcelas(soloNoSincronizadas: true);
      int synced = 0;
      int failed = 0;

      // Obtener el ID del usuario autenticado desde el token
      final userId = await _getUserIdFromToken();
      if (userId == null) {
        _logger.w('No se pudo obtener userId, no se pueden sincronizar parcelas');
        return SyncResult(
          success: false,
          message: 'Usuario no autenticado',
          synced: 0,
          failed: parcelas.length,
        );
      }

      for (final parcela in parcelas) {
        try {
          // Preparar datos según CreateParcelaDto del backend
          final data = {
            'codigo': parcela['codigo'] ?? '',
            'nombre': parcela['codigo'] ?? 'Parcela ${parcela['id']}', // Usar código como nombre si no hay nombre
            'latitud': parcela['latitud'] ?? 0.0,
            'longitud': parcela['longitud'] ?? 0.0,
            'area': parcela['area'] ?? 0.0,
            'usuarioCreadorId': userId,
          };

          // Agregar campos opcionales solo si existen
          if (parcela['altitud'] != null) {
            data['altitud'] = parcela['altitud'];
          }
          if (parcela['descripcion'] != null && parcela['descripcion'].toString().isNotEmpty) {
            data['descripcion'] = parcela['descripcion'];
          }
          if (parcela['ubicacion'] != null && parcela['ubicacion'].toString().isNotEmpty) {
            data['ubicacion'] = parcela['ubicacion'];
          }

          final response = await _dio.post('/api/Parcelas', data: data);

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _localDB.marcarParcelaSincronizada(parcela['id']);
            await _localDB.registrarSyncLog(
              tabla: 'parcelas',
              registroId: parcela['id'],
              operacion: 'CREATE',
              exito: true,
            );
            synced++;
          }
        } catch (e) {
          _logger.w('Error sincronizando parcela ${parcela['id']}: $e');
          await _localDB.registrarSyncLog(
            tabla: 'parcelas',
            registroId: parcela['id'],
            operacion: 'CREATE',
            exito: false,
            mensaje: e.toString(),
          );
          failed++;
        }
      }

      return SyncResult(
        success: failed == 0,
        message: 'Parcelas: $synced sincronizadas, $failed fallidas',
        synced: synced,
        failed: failed,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando parcelas: $e',
        synced: 0,
        failed: 0,
      );
    }
  }

  /// Sincronizar Árboles
  Future<SyncResult> _syncArboles() async {
    try {
      final arboles = await _localDB.getArboles(soloNoSincronizados: true);
      int synced = 0;
      int failed = 0;

      for (final arbol in arboles) {
        try {
          final response = await _dio.post(
            '/api/Arboles',
            data: {
              'numeroArbol': arbol['numero_arbol'] ?? 1,
              'parcelaId': arbol['parcela_id'],
              'especieId': arbol['especie_id'],
              'latitud': arbol['latitud'],
              'longitud': arbol['longitud'],
              'altura': arbol['altura'],
              'diametro': arbol['dap'], // Backend espera 'diametro' no 'dap'
              'nombreLocal': arbol['observaciones'], // Usamos observaciones como nombreLocal
              'descripcion': arbol['observaciones'], // También como descripción
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _localDB.marcarArbolSincronizado(arbol['id']);
            await _localDB.registrarSyncLog(
              tabla: 'arboles',
              registroId: arbol['id'],
              operacion: 'CREATE',
              exito: true,
            );
            synced++;
          }
        } catch (e) {
          _logger.w('Error sincronizando árbol ${arbol['id']}: $e');
          await _localDB.registrarSyncLog(
            tabla: 'arboles',
            registroId: arbol['id'],
            operacion: 'CREATE',
            exito: false,
            mensaje: e.toString(),
          );
          failed++;
        }
      }

      return SyncResult(
        success: failed == 0,
        message: 'Árboles: $synced sincronizados, $failed fallidos',
        synced: synced,
        failed: failed,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando árboles: $e',
        synced: 0,
        failed: 0,
      );
    }
  }

  /// Sincronizar Fotos
  Future<SyncResult> _syncFotos() async {
    try {
      final fotos = await _localDB.getFotos(soloNoSincronizadas: true);
      int synced = 0;
      int failed = 0;

      for (final foto in fotos) {
        try {
          final file = File(foto['ruta_local']);
          if (!await file.exists()) {
            _logger.w('Archivo de foto no existe: ${foto['ruta_local']}');
            failed++;
            continue;
          }

          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              foto['ruta_local'],
              filename: file.path.split('/').last,
            ),
            'arbolId': foto['arbol_id'],
            'parcelaId': foto['parcela_id'],
            'descripcion': foto['descripcion'],
            'tipo': foto['tipo'],
          });

          final response = await _dio.post('/api/Fotos', data: formData);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final rutaRemota = response.data['ruta'] ?? response.data['url'];
            await _localDB.marcarFotoSincronizada(foto['id'], rutaRemota);
            await _localDB.registrarSyncLog(
              tabla: 'fotos',
              registroId: foto['id'],
              operacion: 'UPLOAD',
              exito: true,
            );
            synced++;
          }
        } catch (e) {
          _logger.w('Error sincronizando foto ${foto['id']}: $e');
          await _localDB.registrarSyncLog(
            tabla: 'fotos',
            registroId: foto['id'],
            operacion: 'UPLOAD',
            exito: false,
            mensaje: e.toString(),
          );
          failed++;
        }
      }

      return SyncResult(
        success: failed == 0,
        message: 'Fotos: $synced sincronizadas, $failed fallidas',
        synced: synced,
        failed: failed,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando fotos: $e',
        synced: 0,
        failed: 0,
      );
    }
  }

  /// Extrae el userId del token JWT
  Future<String?> _getUserIdFromToken() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      // Decodificar JWT (formato: header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decodificar el payload (segunda parte)
      final payload = parts[1];
      // Normalizar base64 padding
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // El backend usa "UserId" (con mayúscula) en el claim
      return payloadMap['UserId'] as String?;
    } catch (e) {
      _logger.e('Error extrayendo userId del token: $e');
      return null;
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

/// Resultado de una operación de sincronización
class SyncResult {
  final bool success;
  final String message;
  final int synced;
  final int failed;

  SyncResult({
    required this.success,
    required this.message,
    required this.synced,
    required this.failed,
  });
}

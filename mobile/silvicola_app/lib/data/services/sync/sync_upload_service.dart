import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../local/local_database.dart';
import '../api_service.dart';
import 'sync_result.dart';

/// Servicio encargado de SUBIR (PUSH) datos al servidor
class SyncUploadService {
  final LocalDatabase _localDB;
  final Dio _dio;
  final Logger _logger;
  final ApiService _apiService;

  SyncUploadService({
    required LocalDatabase localDB,
    required Dio dio,
    required Logger logger,
    required ApiService apiService,
  })  : _localDB = localDB,
        _dio = dio,
        _logger = logger,
        _apiService = apiService;

  /// Sincronizar Especies
  Future<SyncResult> syncEspecies() async {
    try {
      final especies = await _localDB.getEspecies(soloNoSincronizadas: true);
      int synced = 0;
      int failed = 0;

      _logger.i('📋 Especies pendientes de sincronización: ${especies.length}');

      for (final especie in especies) {
        try {
          _logger.d('Sincronizando especie: ${especie['nombre_cientifico']} (ID: ${especie['id']})');
          
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
            final serverData = response.data;
            final String serverId = serverData['id'];
            final String localId = especie['id'];
            
            _logger.i('✅ Especie sincronizada - Local: $localId → Server: $serverId');
            
            if (serverId != localId) {
              _logger.d('Actualizando referencias de especie $localId a $serverId');
              await _localDB.actualizarReferenciaEspecieId(localId, serverId);
            }
            
            await _localDB.marcarEspecieSincronizada(serverId);
            await _localDB.registrarSyncLog(
              tabla: 'especies',
              registroId: serverId,
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
  Future<SyncResult> syncParcelas() async {
    try {
      final parcelas = await _localDB.getParcelas(soloNoSincronizadas: true);
      int synced = 0;
      int failed = 0;

      _logger.i('📋 Parcelas pendientes de sincronización: ${parcelas.length}');

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
          _logger.d('Sincronizando parcela: ${parcela['codigo']} (ID: ${parcela['id']})');
          
          final data = {
            'codigo': parcela['codigo'] ?? '',
            'nombre': parcela['codigo'] ?? 'Parcela ${parcela['id']}',
            'latitud': parcela['latitud'] ?? 0.0,
            'longitud': parcela['longitud'] ?? 0.0,
            'area': parcela['area'] ?? 0.0,
            'usuarioCreadorId': userId,
          };

          if (parcela['altitud'] != null) data['altitud'] = parcela['altitud'];
          if (parcela['descripcion'] != null && parcela['descripcion'].toString().isNotEmpty) {
            data['descripcion'] = parcela['descripcion'];
          }
          if (parcela['ubicacion'] != null && parcela['ubicacion'].toString().isNotEmpty) {
            data['ubicacion'] = parcela['ubicacion'];
          }

          final response = await _dio.post('/api/Parcelas', data: data);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final serverData = response.data;
            final String serverId = serverData['id'];
            final String localId = parcela['id'];
            
            _logger.i('✅ Parcela sincronizada - Local: $localId → Server: $serverId');
            
            if (serverId != localId) {
              _logger.d('Actualizando referencias de parcela $localId a $serverId');
              await _localDB.actualizarReferenciaParcelaId(localId, serverId);
            }
            
            await _localDB.marcarParcelaSincronizada(serverId);
            await _localDB.registrarSyncLog(
              tabla: 'parcelas',
              registroId: serverId,
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
  Future<SyncResult> syncArboles() async {
    try {
      final arboles = await _localDB.getArboles(soloNoSincronizados: true);
      int synced = 0;
      int failed = 0;

      _logger.i('📋 Árboles pendientes de sincronización: ${arboles.length}');

      for (final arbol in arboles) {
        try {
          _logger.d('Sincronizando árbol ID: ${arbol['id']}, Especie: ${arbol['especie_id']}, Parcela: ${arbol['parcela_id']}');
          
          final especieId = arbol['especie_id'];
          final parcelaId = arbol['parcela_id'];
          
          _logger.d('🔍 Verificando IDs - ParcelaID: $parcelaId, EspecieID: $especieId');
          
          // Verificar que la especie existe y está sincronizada
          final especies = await _localDB.getEspecies();
          final especieExiste = especies.any((e) => e['id'] == especieId && e['sincronizado'] == 1);
          
          if (!especieExiste) {
            _logger.w('⚠️ Especie $especieId no encontrada o no sincronizada. Saltando árbol.');
            failed++;
            continue;
          }
          
          // Verificar que la parcela existe y está sincronizada
          final parcelas = await _localDB.getParcelas();
          final parcelaExiste = parcelas.any((p) => p['id'] == parcelaId && p['sincronizado'] == 1);
          
          if (!parcelaExiste) {
            _logger.w('⚠️ Parcela $parcelaId no encontrada o no sincronizada. Saltando árbol.');
            failed++;
            continue;
          }
          
          final response = await _dio.post(
            '/api/Arboles',
            data: {
              'numeroArbol': arbol['numero_arbol'] ?? 1,
              'parcelaId': arbol['parcela_id'],
              'especieId': arbol['especie_id'],
              'latitud': arbol['latitud'],
              'longitud': arbol['longitud'],
              'altura': arbol['altura'],
              'diametro': arbol['dap'],
              'nombreLocal': arbol['observaciones'],
              'descripcion': arbol['observaciones'],
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
  Future<SyncResult> syncFotos() async {
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

      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      return payloadMap['UserId'] as String?;
    } catch (e) {
      _logger.e('Error extrayendo userId del token: $e');
      return null;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../local/local_database.dart';

/// Servicio encargado de DESCARGAR (PULL) datos del servidor
class SyncDownloadService {
  final LocalDatabase _localDB;
  final Dio _dio;
  final Logger _logger;

  SyncDownloadService({
    required LocalDatabase localDB,
    required Dio dio,
    required Logger logger,
  })  : _localDB = localDB,
        _dio = dio,
        _logger = logger;

  /// Descargar especies del servidor
  Future<void> downloadEspecies() async {
    try {
      final response = await _dio.get('/api/Especies');
      if (response.statusCode == 200) {
        final List<dynamic> especies = response.data;
        _logger.i('⬇️ Descargando ${especies.length} especies del servidor');
        
        for (final especie in especies) {
          // Verificar si ya existe localmente por nombre científico
          final especiesExistentes = await _localDB.getEspecies();
          final especieDuplicada = especiesExistentes.firstWhere(
            (e) => e['nombre_cientifico'] == especie['nombreCientifico'],
            orElse: () => <String, dynamic>{},
          );
          
          if (especieDuplicada.isNotEmpty) {
            // Si existe localmente, actualizar ID y marcar como sincronizada
            _logger.d('🔄 Especie existente: ${especie['nombreCientifico']}, actualizando ID');
            final localId = especieDuplicada['id'];
            final serverId = especie['id'];
            if (localId != serverId) {
              await _localDB.actualizarReferenciaEspecieId(localId, serverId);
            }
            await _localDB.marcarEspecieSincronizada(serverId);
          } else {
            // Si no existe, insertarla
            await _localDB.insertEspecie({
              'id': especie['id'],
              'nombre_cientifico': especie['nombreCientifico'],
              'nombre_comun': especie['nombreComun'],
              'familia': especie['familia'],
              'descripcion': especie['descripcion'],
              'sincronizado': 1,
              'activo': 1,
              'fecha_creacion': especie['fechaCreacion'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (e) {
      _logger.w('Error descargando especies: $e');
    }
  }

  /// Descargar parcelas del servidor
  Future<void> downloadParcelas() async {
    try {
      final response = await _dio.get('/api/Parcelas');
      if (response.statusCode == 200) {
        final List<dynamic> parcelas = response.data;
        _logger.i('⬇️ Descargando ${parcelas.length} parcelas del servidor');
        
        for (final parcela in parcelas) {
          // Verificar si ya existe localmente por código
          final parcelasExistentes = await _localDB.getParcelas();
          final parcelaDuplicada = parcelasExistentes.firstWhere(
            (p) => p['codigo'] == parcela['codigo'],
            orElse: () => <String, dynamic>{},
          );
          
          if (parcelaDuplicada.isNotEmpty) {
            // Si existe localmente, actualizar ID y marcar como sincronizada
            _logger.d('🔄 Parcela existente: ${parcela['codigo']}, actualizando ID');
            final localId = parcelaDuplicada['id'];
            final serverId = parcela['id'];
            if (localId != serverId) {
              await _localDB.actualizarReferenciaParcelaId(localId, serverId);
            }
            await _localDB.marcarParcelaSincronizada(serverId);
          } else {
            // Si no existe, insertarla
            await _localDB.insertParcela({
              'id': parcela['id'],
              'codigo': parcela['codigo'],
              'nombre': parcela['nombre'],
              'latitud': parcela['latitud'],
              'longitud': parcela['longitud'],
              'altitud': parcela['altitud'],
              'area': parcela['area'] ?? 0.0,
              'descripcion': parcela['descripcion'],
              'ubicacion': parcela['ubicacion'],
              'sincronizado': 1,
              'activo': 1,
              'fecha_creacion': parcela['fechaCreacion'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (e) {
      _logger.w('Error descargando parcelas: $e');
    }
  }

  /// Descargar árboles del servidor
  Future<void> downloadArboles() async {
    try {
      final response = await _dio.get('/api/Arboles');
      if (response.statusCode == 200) {
        final List<dynamic> arboles = response.data;
        _logger.i('⬇️ Descargando ${arboles.length} árboles del servidor');
        
        for (final arbol in arboles) {
          // Verificar si ya existe un árbol local con el mismo numeroArbol + parcelaId
          final arbolesExistentes = await _localDB.getArboles();
          final arbolDuplicado = arbolesExistentes.firstWhere(
            (a) => a['numero_arbol'] == arbol['numeroArbol'] && a['parcela_id'] == arbol['parcelaId'],
            orElse: () => <String, dynamic>{},
          );
          
          if (arbolDuplicado.isNotEmpty) {
            // Si existe localmente, actualizar su ID al del servidor y marcarlo como sincronizado
            _logger.d('🔄 Árbol existente encontrado (numero: ${arbol['numeroArbol']}, parcela: ${arbol['parcelaId']}), actualizando ID');
            final localId = arbolDuplicado['id'];
            final serverId = arbol['id'];
            
            // Actualizar el ID del árbol si son diferentes
            if (localId != serverId) {
              await _localDB.database.then((db) async {
                await db.update(
                  'arboles',
                  {'id': serverId, 'sincronizado': 1},
                  where: 'id = ?',
                  whereArgs: [localId],
                );
              });
              _logger.i('✅ Árbol actualizado - Local: $localId → Server: $serverId');
            } else {
              await _localDB.marcarArbolSincronizado(serverId);
            }
          } else {
            // Si no existe, insertarlo
            await _localDB.insertArbol({
              'id': arbol['id'],
              'numero_arbol': arbol['numeroArbol'] ?? 0,
              'parcela_id': arbol['parcelaId'],
              'especie_id': arbol['especieId'],
              'latitud': arbol['latitud'],
              'longitud': arbol['longitud'],
              'altura': arbol['altura'] ?? 0.0,
              'dap': arbol['diametro'] ?? 0.0,
              'observaciones': arbol['descripcion'],
              'sincronizado': 1,
              'activo': 1,
              'fecha_creacion': arbol['fechaCreacion'] ?? DateTime.now().toIso8601String(),
              'fecha_actualizacion': DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (e) {
      _logger.w('Error descargando árboles: $e');
    }
  }
}

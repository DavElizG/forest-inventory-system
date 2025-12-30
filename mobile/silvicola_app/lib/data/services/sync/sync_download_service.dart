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

        // Obtener todas las especies locales de una vez
        final especiesExistentes = await _localDB.getEspecies();
        final Map<String, dynamic> especiesByNombreCientifico = {
          for (var e in especiesExistentes) e['nombre_cientifico']: e
        };

        final List<Map<String, dynamic>> especiesAInsertar = [];
        final List<String> especiesASincronizar = [];

        for (final especie in especies) {
          final especieDuplicada =
              especiesByNombreCientifico[especie['nombreCientifico']];

          if (especieDuplicada != null) {
            // Si existe localmente, actualizar ID y marcar como sincronizada
            final localId = especieDuplicada['id'];
            final serverId = especie['id'];
            if (localId != serverId) {
              await _localDB.actualizarReferenciaEspecieId(localId, serverId);
            }
            especiesASincronizar.add(serverId);
          } else {
            // Si no existe, agregarlo a la lista de inserción
            especiesAInsertar.add({
              'id': especie['id'],
              'nombre_cientifico': especie['nombreCientifico'],
              'nombre_comun': especie['nombreComun'],
              'familia': especie['familia'],
              'descripcion': especie['descripcion'],
              'sincronizado': 1,
              'activo': 1,
              'fecha_creacion':
                  especie['fechaCreacion'] ?? DateTime.now().toIso8601String(),
            });
          }
        }

        // Insertar todas las especies nuevas en batch
        if (especiesAInsertar.isNotEmpty) {
          await _localDB.insertEspeciesBatch(especiesAInsertar);
          _logger
              .i('✅ ${especiesAInsertar.length} especies insertadas en batch');
        }

        // Marcar especies sincronizadas en batch
        if (especiesASincronizar.isNotEmpty) {
          await _localDB.markAsSyncedBatch('especies', especiesASincronizar);
          _logger.i(
              '✅ ${especiesASincronizar.length} especies marcadas como sincronizadas');
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

        // Obtener todas las parcelas locales de una vez
        final parcelasExistentes = await _localDB.getParcelas();
        final Map<String, dynamic> parcelasByCodigo = {
          for (var p in parcelasExistentes) p['codigo']: p
        };

        final List<Map<String, dynamic>> parcelasAInsertar = [];
        final List<String> parcelasASincronizar = [];

        for (final parcela in parcelas) {
          final parcelaDuplicada = parcelasByCodigo[parcela['codigo']];

          if (parcelaDuplicada != null) {
            // Si existe localmente, actualizar ID y marcar como sincronizada
            final localId = parcelaDuplicada['id'];
            final serverId = parcela['id'];
            if (localId != serverId) {
              await _localDB.actualizarReferenciaParcelaId(localId, serverId);
            }
            parcelasASincronizar.add(serverId);
          } else {
            // Si no existe, agregarlo a la lista de inserción
            parcelasAInsertar.add({
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
              'fecha_creacion':
                  parcela['fechaCreacion'] ?? DateTime.now().toIso8601String(),
            });
          }
        }

        // Insertar todas las parcelas nuevas en batch
        if (parcelasAInsertar.isNotEmpty) {
          await _localDB.insertParcelasBatch(parcelasAInsertar);
          _logger
              .i('✅ ${parcelasAInsertar.length} parcelas insertadas en batch');
        }

        // Marcar parcelas sincronizadas en batch
        if (parcelasASincronizar.isNotEmpty) {
          await _localDB.markAsSyncedBatch('parcelas', parcelasASincronizar);
          _logger.i(
              '✅ ${parcelasASincronizar.length} parcelas marcadas como sincronizadas');
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

        // Obtener todos los árboles locales de una vez
        final arbolesExistentes = await _localDB.getArboles();
        final Map<String, dynamic> arbolesByNumeroYParcela = {
          for (var a in arbolesExistentes)
            '${a['numero_arbol']}_${a['parcela_id']}': a
        };

        final List<Map<String, dynamic>> arbolesAInsertar = [];

        for (final arbol in arboles) {
          final key = '${arbol['numeroArbol']}_${arbol['parcelaId']}';
          final arbolDuplicado = arbolesByNumeroYParcela[key];

          if (arbolDuplicado != null) {
            // Si existe localmente, actualizar su ID al del servidor y marcarlo como sincronizado
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
              _logger.i(
                  '✅ Árbol actualizado - Local: $localId → Server: $serverId');
            } else {
              await _localDB.marcarArbolSincronizado(serverId);
            }
          } else {
            // Si no existe, agregarlo a la lista de inserción
            arbolesAInsertar.add({
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
              'fecha_creacion':
                  arbol['fechaCreacion'] ?? DateTime.now().toIso8601String(),
              'fecha_actualizacion': DateTime.now().toIso8601String(),
            });
          }
        }

        // Insertar todos los árboles nuevos en batch
        if (arbolesAInsertar.isNotEmpty) {
          await _localDB.insertArbolesBatch(arbolesAInsertar);
          _logger.i('✅ ${arbolesAInsertar.length} árboles insertados en batch');
        }
      }
    } catch (e) {
      _logger.w('Error descargando árboles: $e');
    }
  }
}

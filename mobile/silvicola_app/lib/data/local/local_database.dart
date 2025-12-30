import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Base de datos local SQLite para almacenamiento offline
class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('silvicola_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final path = join(appDocDir.path, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columna activo a especies
      await db
          .execute('ALTER TABLE especies ADD COLUMN activo INTEGER DEFAULT 1');
      // Agregar columna activo a arboles
      await db
          .execute('ALTER TABLE arboles ADD COLUMN activo INTEGER DEFAULT 1');
      // Agregar columna activo a parcelas si no existe
      try {
        await db.execute(
            'ALTER TABLE parcelas ADD COLUMN activo INTEGER DEFAULT 1');
      } catch (e) {
        // La columna puede existir ya, ignorar error
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de Parcelas
    await db.execute('''
      CREATE TABLE parcelas (
        id TEXT PRIMARY KEY,
        codigo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        ubicacion TEXT,
        area REAL,
        latitud REAL,
        longitud REAL,
        altitud REAL,
        descripcion TEXT,
        fecha_establecimiento TEXT,
        usuario_id TEXT,
        activo INTEGER DEFAULT 1,
        sincronizado INTEGER DEFAULT 0,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT
      )
    ''');

    // Tabla de Especies
    await db.execute('''
      CREATE TABLE especies (
        id TEXT PRIMARY KEY,
        nombre_cientifico TEXT NOT NULL,
        nombre_comun TEXT,
        familia TEXT,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        sincronizado INTEGER DEFAULT 0,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT
      )
    ''');

    // Tabla de Árboles
    await db.execute('''
      CREATE TABLE arboles (
        id TEXT PRIMARY KEY,
        numero_arbol INTEGER NOT NULL,
        parcela_id TEXT NOT NULL,
        especie_id TEXT NOT NULL,
        dap REAL,
        altura REAL,
        altura_comercial REAL,
        estado_salud TEXT,
        coordenada_x REAL,
        coordenada_y REAL,
        latitud REAL,
        longitud REAL,
        observaciones TEXT,
        activo INTEGER DEFAULT 1,
        sincronizado INTEGER DEFAULT 0,
        fecha_medicion TEXT,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT,
        FOREIGN KEY (parcela_id) REFERENCES parcelas (id),
        FOREIGN KEY (especie_id) REFERENCES especies (id)
      )
    ''');

    // Tabla de Fotos
    await db.execute('''
      CREATE TABLE fotos (
        id TEXT PRIMARY KEY,
        arbol_id TEXT,
        parcela_id TEXT,
        ruta_local TEXT NOT NULL,
        ruta_remota TEXT,
        descripcion TEXT,
        tipo TEXT,
        sincronizado INTEGER DEFAULT 0,
        fecha_captura TEXT,
        fecha_creacion TEXT,
        FOREIGN KEY (arbol_id) REFERENCES arboles (id),
        FOREIGN KEY (parcela_id) REFERENCES parcelas (id)
      )
    ''');

    // Tabla de logs de sincronización
    await db.execute('''
      CREATE TABLE sync_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tabla TEXT NOT NULL,
        registro_id TEXT NOT NULL,
        operacion TEXT NOT NULL,
        exito INTEGER NOT NULL,
        mensaje TEXT,
        fecha TEXT NOT NULL
      )
    ''');

    // Índices para optimizar búsquedas
    await db.execute('CREATE INDEX idx_arboles_parcela ON arboles(parcela_id)');
    await db.execute('CREATE INDEX idx_arboles_especie ON arboles(especie_id)');
    await db.execute(
        'CREATE INDEX idx_arboles_sincronizado ON arboles(sincronizado)');
    await db.execute('CREATE INDEX idx_arboles_activo ON arboles(activo)');
    await db.execute(
        'CREATE INDEX idx_arboles_numero ON arboles(numero_arbol, parcela_id)');
    await db.execute(
        'CREATE INDEX idx_parcelas_sincronizado ON parcelas(sincronizado)');
    await db.execute('CREATE INDEX idx_parcelas_activo ON parcelas(activo)');
    await db.execute('CREATE INDEX idx_parcelas_codigo ON parcelas(codigo)');
    await db.execute(
        'CREATE INDEX idx_especies_sincronizado ON especies(sincronizado)');
    await db.execute('CREATE INDEX idx_especies_activo ON especies(activo)');
    await db.execute('CREATE INDEX idx_fotos_arbol ON fotos(arbol_id)');
    await db
        .execute('CREATE INDEX idx_fotos_sincronizado ON fotos(sincronizado)');
  }

  // === OPERACIONES CRUD PARA PARCELAS ===

  Future<String> insertParcela(Map<String, dynamic> parcela) async {
    final db = await database;
    await db.insert('parcelas', parcela,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return parcela['id'];
  }

  Future<List<Map<String, dynamic>>> getParcelas(
      {bool soloNoSincronizadas = false}) async {
    final db = await database;
    if (soloNoSincronizadas) {
      return await db.query('parcelas',
          where: 'sincronizado = ? AND activo = ?', whereArgs: [0, 1]);
    }
    return await db.query('parcelas',
        where: 'activo = ?', whereArgs: [1], orderBy: 'fecha_creacion DESC');
  }

  Future<Map<String, dynamic>?> getParcelaById(String id) async {
    final db = await database;
    final results = await db.query('parcelas',
        where: 'id = ? AND activo = ?', whereArgs: [id, 1]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateParcela(String id, Map<String, dynamic> parcela) async {
    final db = await database;
    parcela['sincronizado'] = 0; // Marcar como no sincronizado
    return await db
        .update('parcelas', parcela, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteParcela(String id) async {
    final db = await database;
    // Soft delete - mover a papelera en lugar de eliminar
    return await db.update(
      'parcelas',
      {'activo': 0, 'sincronizado': 0, 'fecha_actualizacion': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarParcelaSincronizada(String id) async {
    final db = await database;
    await db.update('parcelas', {'sincronizado': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // === OPERACIONES CRUD PARA ESPECIES ===

  Future<String> insertEspecie(Map<String, dynamic> especie) async {
    final db = await database;
    await db.insert('especies', especie,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return especie['id'];
  }

  Future<List<Map<String, dynamic>>> getEspecies(
      {bool soloNoSincronizadas = false}) async {
    final db = await database;
    if (soloNoSincronizadas) {
      return await db.query('especies',
          where: 'sincronizado = ? AND activo = ?',
          whereArgs: [0, 1],
          orderBy: 'nombre_cientifico ASC');
    }
    // Filtrar registros en papelera (activo = 0)
    return await db.query('especies',
        where: 'activo = ?',
        whereArgs: [1],
        orderBy: 'nombre_cientifico ASC');
  }

  Future<Map<String, dynamic>?> getEspecieById(String id) async {
    final db = await database;
    final results = await db.query('especies',
        where: 'id = ? AND activo = ?', whereArgs: [id, 1]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateEspecie(String id, Map<String, dynamic> especie) async {
    final db = await database;
    especie['sincronizado'] = 0;
    return await db
        .update('especies', especie, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEspecie(String id) async {
    final db = await database;
    // Soft delete - mover a papelera en lugar de eliminar
    return await db.update(
      'especies',
      {'activo': 0, 'sincronizado': 0, 'fecha_actualizacion': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarEspecieSincronizada(String id) async {
    final db = await database;
    await db.update('especies', {'sincronizado': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Actualizar el ID de una especie y todas sus referencias en árboles
  Future<void> actualizarReferenciaEspecieId(String oldId, String newId) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Actualizar el ID de la especie
      await txn.execute('''
        UPDATE especies 
        SET id = ?, sincronizado = 1 
        WHERE id = ?
      ''', [newId, oldId]);

      // 2. Actualizar las referencias en árboles
      await txn.execute('''
        UPDATE arboles 
        SET especie_id = ? 
        WHERE especie_id = ?
      ''', [newId, oldId]);
    });
  }

  /// Actualizar el ID de una parcela y todas sus referencias en árboles
  Future<void> actualizarReferenciaParcelaId(String oldId, String newId) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Actualizar el ID de la parcela
      await txn.execute('''
        UPDATE parcelas 
        SET id = ?, sincronizado = 1 
        WHERE id = ?
      ''', [newId, oldId]);

      // 2. Actualizar las referencias en árboles
      await txn.execute('''
        UPDATE arboles 
        SET parcela_id = ? 
        WHERE parcela_id = ?
      ''', [newId, oldId]);
    });
  }

  // === OPERACIONES CRUD PARA ÁRBOLES ===

  Future<String> insertArbol(Map<String, dynamic> arbol) async {
    final db = await database;
    await db.insert('arboles', arbol,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return arbol['id'];
  }

  Future<List<Map<String, dynamic>>> getArboles({
    String? parcelaId,
    bool soloNoSincronizados = false,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    // Siempre filtrar registros en papelera (activo = 0)
    if (parcelaId != null && soloNoSincronizados) {
      where = 'parcela_id = ? AND sincronizado = ? AND activo = ?';
      whereArgs = [parcelaId, 0, 1];
    } else if (parcelaId != null) {
      where = 'parcela_id = ? AND activo = ?';
      whereArgs = [parcelaId, 1];
    } else if (soloNoSincronizados) {
      where = 'sincronizado = ? AND activo = ?';
      whereArgs = [0, 1];
    } else {
      where = 'activo = ?';
      whereArgs = [1];
    }

    return await db.query('arboles',
        where: where, whereArgs: whereArgs, orderBy: 'fecha_creacion DESC');
  }

  Future<Map<String, dynamic>?> getArbolById(String id) async {
    final db = await database;
    final results = await db.query('arboles',
        where: 'id = ? AND activo = ?', whereArgs: [id, 1]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateArbol(String id, Map<String, dynamic> arbol) async {
    final db = await database;
    arbol['sincronizado'] = 0;
    return await db.update('arboles', arbol, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteArbol(String id) async {
    final db = await database;
    // Soft delete - mover a papelera en lugar de eliminar
    return await db.update(
      'arboles',
      {'activo': 0, 'sincronizado': 0, 'fecha_actualizacion': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarArbolSincronizado(String id) async {
    final db = await database;
    await db.update('arboles', {'sincronizado': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // === OPERACIONES CRUD PARA FOTOS ===

  Future<String> insertFoto(Map<String, dynamic> foto) async {
    final db = await database;
    await db.insert('fotos', foto,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return foto['id'];
  }

  Future<List<Map<String, dynamic>>> getFotos({
    String? arbolId,
    String? parcelaId,
    bool soloNoSincronizadas = false,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (arbolId != null && soloNoSincronizadas) {
      where = 'arbol_id = ? AND sincronizado = ?';
      whereArgs = [arbolId, 0];
    } else if (arbolId != null) {
      where = 'arbol_id = ?';
      whereArgs = [arbolId];
    } else if (parcelaId != null && soloNoSincronizadas) {
      where = 'parcela_id = ? AND sincronizado = ?';
      whereArgs = [parcelaId, 0];
    } else if (parcelaId != null) {
      where = 'parcela_id = ?';
      whereArgs = [parcelaId];
    } else if (soloNoSincronizadas) {
      where = 'sincronizado = ?';
      whereArgs = [0];
    }

    return await db.query('fotos',
        where: where, whereArgs: whereArgs, orderBy: 'fecha_captura DESC');
  }

  Future<void> marcarFotoSincronizada(String id, String rutaRemota) async {
    final db = await database;
    await db.update('fotos', {'sincronizado': 1, 'ruta_remota': rutaRemota},
        where: 'id = ?', whereArgs: [id]);
  }

  // === ESTADÍSTICAS Y CONTADORES ===

  Future<Map<String, int>> getContadoresSincronizacion() async {
    final db = await database;

    final parcelasNoSync = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM parcelas WHERE sincronizado = 0 AND activo = 1')) ??
        0;

    final arbolesNoSync = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM arboles WHERE sincronizado = 0 AND activo = 1')) ??
        0;

    final especiesNoSync = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM especies WHERE sincronizado = 0 AND activo = 1')) ??
        0;

    final fotosNoSync = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM fotos WHERE sincronizado = 0')) ??
        0;

    return {
      'parcelas': parcelasNoSync,
      'arboles': arbolesNoSync,
      'especies': especiesNoSync,
      'fotos': fotosNoSync,
      'total': parcelasNoSync + arbolesNoSync + especiesNoSync + fotosNoSync,
    };
  }

  // === LOGS DE SINCRONIZACIÓN ===

  Future<void> registrarSyncLog({
    required String tabla,
    required String registroId,
    required String operacion,
    required bool exito,
    String? mensaje,
  }) async {
    final db = await database;
    await db.insert('sync_logs', {
      'tabla': tabla,
      'registro_id': registroId,
      'operacion': operacion,
      'exito': exito ? 1 : 0,
      'mensaje': mensaje,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncLogs({int limit = 50}) async {
    final db = await database;
    return await db.query('sync_logs', orderBy: 'fecha DESC', limit: limit);
  }

  // === LIMPIEZA Y MANTENIMIENTO ===

  Future<void> limpiarDatosSincronizados({int diasAntes = 30}) async {
    final db = await database;
    final fechaLimite =
        DateTime.now().subtract(Duration(days: diasAntes)).toIso8601String();

    // Eliminar logs antiguos
    await db.delete('sync_logs', where: 'fecha < ?', whereArgs: [fechaLimite]);
  }

  Future<void> cerrar() async {
    final db = await database;
    await db.close();
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DELETE FROM arboles');
    await db.execute('DELETE FROM fotos');
    await db.execute('DELETE FROM parcelas');
    await db.execute('DELETE FROM especies');
    await db.execute('DELETE FROM sync_logs');
  }

  /// Resetear estado de sincronización para forzar resync
  Future<void> resetearEstadoSincronizacion() async {
    final db = await database;
    await db.execute('UPDATE especies SET sincronizado = 0');
    await db.execute('UPDATE parcelas SET sincronizado = 0');
    await db.execute('UPDATE arboles SET sincronizado = 0');
    await db.execute('UPDATE fotos SET sincronizado = 0');
  }

  /// Eliminar solo árboles no sincronizados
  Future<void> eliminarArbolesNoSincronizados() async {
    final db = await database;
    await db.delete('arboles', where: 'sincronizado = 0');
  }

  /// Eliminar árboles con referencias inválidas (IDs de especies/parcelas que no existen)
  Future<int> eliminarArbolesConReferenciasInvalidas() async {
    final db = await database;

    // Eliminar árboles cuya especie no existe
    final arbolesEspecieInvalida = await db.rawDelete('''
      DELETE FROM arboles 
      WHERE especie_id NOT IN (SELECT id FROM especies)
    ''');

    // Eliminar árboles cuya parcela no existe
    final arbolesParcelaInvalida = await db.rawDelete('''
      DELETE FROM arboles 
      WHERE parcela_id NOT IN (SELECT id FROM parcelas)
    ''');

    final total = arbolesEspecieInvalida + arbolesParcelaInvalida;
    print('🗑️ Eliminados $total árboles con referencias inválidas');
    return total;
  }

  // === BATCH OPERATIONS ===

  /// Insertar múltiples especies en una transacción
  Future<int> insertEspeciesBatch(List<Map<String, dynamic>> especies) async {
    if (especies.isEmpty) return 0;

    final db = await database;
    final batch = db.batch();
    int count = 0;

    for (final especie in especies) {
      batch.insert('especies', especie,
          conflictAlgorithm: ConflictAlgorithm.replace);
      count++;
    }

    await batch.commit(noResult: true);
    return count;
  }

  /// Insertar múltiples parcelas en una transacción
  Future<int> insertParcelasBatch(List<Map<String, dynamic>> parcelas) async {
    if (parcelas.isEmpty) return 0;

    final db = await database;
    final batch = db.batch();
    int count = 0;

    for (final parcela in parcelas) {
      batch.insert('parcelas', parcela,
          conflictAlgorithm: ConflictAlgorithm.replace);
      count++;
    }

    await batch.commit(noResult: true);
    return count;
  }

  /// Insertar múltiples árboles en una transacción
  Future<int> insertArbolesBatch(List<Map<String, dynamic>> arboles) async {
    if (arboles.isEmpty) return 0;

    final db = await database;
    final batch = db.batch();
    int count = 0;

    for (final arbol in arboles) {
      batch.insert('arboles', arbol,
          conflictAlgorithm: ConflictAlgorithm.replace);
      count++;
    }

    await batch.commit(noResult: true);
    return count;
  }

  /// Actualizar estado de sincronización de múltiples registros
  Future<void> markAsSyncedBatch(String table, List<String> ids) async {
    if (ids.isEmpty) return;

    final db = await database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        table,
        {'sincronizado': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }
}

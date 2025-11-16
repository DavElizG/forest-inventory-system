import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../core/config/environment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(Environment.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: Environment.dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla Arboles
    await db.execute('''
      CREATE TABLE arboles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        especie_id INTEGER NOT NULL,
        parcela_id INTEGER NOT NULL,
        dap REAL NOT NULL,
        altura REAL NOT NULL,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        foto_path TEXT,
        observaciones TEXT,
        estado TEXT NOT NULL,
        fecha_medicion TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla Parcelas
    await db.execute('''
      CREATE TABLE parcelas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        area REAL NOT NULL,
        ubicacion TEXT,
        latitud REAL,
        longitud REAL,
        sincronizado INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla Especies
    await db.execute('''
      CREATE TABLE especies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_comun TEXT NOT NULL,
        nombre_cientifico TEXT NOT NULL,
        familia TEXT,
        sincronizado INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla Sync Queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla Usuario (local)
    await db.execute('''
      CREATE TABLE usuario_local (
        id INTEGER PRIMARY KEY,
        email TEXT NOT NULL,
        nombre TEXT NOT NULL,
        rol TEXT NOT NULL,
        last_login TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Implementar migraciones aquí
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

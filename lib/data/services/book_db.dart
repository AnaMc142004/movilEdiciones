import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbService {
  static final DbService instance = DbService._init();
  static Database? _database;

  DbService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementar versión para agregar nueva tabla
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id TEXT PRIMARY KEY,
        nombre TEXT,
        isbn TEXT,
        editorial TEXT,
        cantidadPropia INTEGER,
        cantidadConsignacion INTEGER,
        total INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_metadata(
        key TEXT PRIMARY KEY,
        last_update INTEGER,
        created_at INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar tabla de metadata si no existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cache_metadata(
          key TEXT PRIMARY KEY,
          last_update INTEGER,
          created_at INTEGER
        )
      ''');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await instance.database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> clearTable(String table) async {
    final db = await instance.database;
    await db.delete(table);
  }

  // Método para obtener el tamaño de una tabla
  Future<int> getTableSize(String table) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return result.first['count'] as int;
  }

  // Método para verificar si una tabla existe
  Future<bool> tableExists(String tableName) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
    );
    return result.isNotEmpty;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
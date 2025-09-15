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
      version: 1,
      onCreate: _createDB,
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

  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtener todos los registros de una tabla
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  /// Obtener registros con condiciones
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  /// Actualizar registro
  Future<int> update(String table, Map<String, dynamic> data,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await instance.database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Eliminar registro
  Future<int> delete(String table,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Borrar todo
  Future<void> clearTable(String table) async {
    final db = await instance.database;
    await db.delete(table);
  }

  /// Cerrar DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

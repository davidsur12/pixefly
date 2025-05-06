import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseInfoBackgraund {
  static final DatabaseInfoBackgraund instance = DatabaseInfoBackgraund._init();
  static Database? _database;

  DatabaseInfoBackgraund._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('info_backgraund_img.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE info_backgraund_img (
        grupo INTEGER PRIMARY KEY,
        cantidad_img INTEGER NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      )
    ''');
  }

  // Insertar un registro
  Future<void> insertData(int grupo, int cantidadImg, String fecha) async {
    final db = await instance.database;
    await db.insert(
      'info_backgraund_img',
      {
        'grupo': grupo,
        'cantidad_img': cantidadImg,
        'fecha_actualizacion': fecha,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todos los datos
  Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await instance.database;
    return await db.query('info_backgraund_img');
  }

  // Borrar todos los datos de la tabla
  Future<void> clearTable() async {
    final db = await instance.database;
    await db.delete('info_backgraund_img');
  }

  // Eliminar la base de datos completamente
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'info_backgraund_img.db');

    if (File(path).existsSync()) {
      await deleteDatabase(path);
      _database = null;
    }
  }

  // Editar la fecha_actualizacion mediante el grupo
  Future<void> updateFechaPorGrupo(int grupo, String nuevaFecha) async {
    final db = await instance.database;
    await db.update(
      'info_backgraund_img',
      {'fecha_actualizacion': nuevaFecha},
      where: 'grupo = ?',
      whereArgs: [grupo],
    );
  }
}

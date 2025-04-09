import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBackgraund {
  static final DataBackgraund _instance = DataBackgraund._internal();

  factory DataBackgraund() => _instance;

  static Database? _database;

  DataBackgraund._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "images.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Crear la tabla en la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        fieldId TEXT NOT NULL
      )
    ''');
  }

  // Insertar una imagen
  Future<int> insertImage(int groupId, String fieldId) async {
    final db = await database;
    try {
      int result = await db.insert(
        'images',
        {'group_id': groupId, 'fieldId': fieldId},
      );
      print("✅ Imagen insertada con ID: $result");
      return result;
    } catch (e) {
      print("❌ Error al insertar la imagen: $e");
      return -1; // o lanza el error
    }
  }

  // Obtener todas las imágenes
  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    return await db.query('images');
  }

  // Obtener imágenes por grupo
  Future<List<Map<String, dynamic>>> getImagesByGroup(int groupId) async {
    final db = await database;
    return await db.query('images', where: 'group_id = ?', whereArgs: [groupId]);
  }

  // Eliminar una imagen por ID
  Future<int> deleteImage(int id) async {
    final db = await database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  // Eliminar todas las imágenes de un grupo
  Future<int> deleteImagesByGroup(int groupId) async {
    final db = await database;
    return await db.delete('images', where: 'group_id = ?', whereArgs: [groupId]);
  }
  // Verificar si una imagen ya existe por su fieldId
  Future<bool> imageExistsByFieldId(String fieldId) async {
    final db = await database;
    final result = await db.query(
      'images',
      where: 'fieldId = ?',
      whereArgs: [fieldId],
    );
    return result.isNotEmpty;
  }

  Future<Map<int, List<Map<String, dynamic>>>> obtenerImagenesPorGrupo2() async {
    final db = await _initDatabase();

    final List<Map<String, dynamic>> resultados = await db.query('images');

    Map<int, List<Map<String, dynamic>>> imagenesAgrupadas = {};

    for (var fila in resultados) {
      int grupoId = fila['group_id'];

      if (!imagenesAgrupadas.containsKey(grupoId)) {
        imagenesAgrupadas[grupoId] = [];
      }

      imagenesAgrupadas[grupoId]!.add(fila);
    }

    return imagenesAgrupadas;
  }
  Future<Map<int, Map<String, List<String>>>> obtenerImagenesPorGrupoYSubgrupo() async {
    final db = await _initDatabase();

    final List<Map<String, dynamic>> resultados = await db.query('images');

    Map<int, Map<String, List<String>>> estructura = {};

    for (var fila in resultados) {
      int groupId = fila['group_id'];
      String fieldId = fila['fieldId'];

      // Obtener subgrupo desde el fieldId (ej: "subgrupo/imagen.png")
      List<String> partes = fieldId.split('/');
      String subgrupo = partes.length > 1 ? partes[0] : 'sin_subgrupo';

      estructura.putIfAbsent(groupId, () => {});
      estructura[groupId]!.putIfAbsent(subgrupo, () => []);
      estructura[groupId]![subgrupo]!.add(fieldId);
    }

    return estructura;
  }

}

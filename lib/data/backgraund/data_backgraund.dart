import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixelfy/blocs/image_cubit_backgraund.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class DataBackgraund {


  static final DataBackgraund _instance = DataBackgraund._internal();
  factory DataBackgraund({BuildContext? context}) {
    if (context != null) {
      _instance._context = context;
    }
    return _instance;
  }
  BuildContext? _context;

  //factory DataBackgraund() => _instance;

  static Database? _database;

  DataBackgraund._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "images_backgraund.db");
print("Ruta base de datos: $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  // Crear la tabla en la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images_backgraund (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
         nombre_grupo TEXT NOT NULL,
        fieldId TEXT NOT NULL,
        path TEXT NOT NULL
      )
    ''');
  }


  /***
   * se encargar de guardar el fieldide de la iamgen,
   * el grupo al que pertenece,
   * el el nombre del grupo,
   * y el path donde se encuentra
   *
   */
  Future<int> insertarImage(
      int groupId, String nombreGrupo, String fieldId, String path) async {
    final db = await database;
    try {
      int result = await db.insert(
        'images_backgraund',
        {'group_id': groupId, 'nombre_grupo': nombreGrupo, 'fieldId': fieldId, 'path': path },
      );
      print("✅ Imagen insertada con ID: $result");
      _context?.read<ImagesCubitBackgraund>().notificarCambio();

      return result;
    } catch (e) {
      print("❌ Error al insertar la imagen: $e");
      return -1; // o lanza el error
    }
  }

  // Obtener todas las imágenes
  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    return await db.query('images_backgraund ');
  }

  // Obtener imágenes por grupo
  Future<List<Map<String, dynamic>>> getImagesByGroup(int groupId) async {
    final db = await database;
    return await db.query('images_backgraund',
        where: 'group_id = ?', whereArgs: [groupId]);
  }

  // Eliminar una imagen por ID
  Future<int> deleteImage(int id) async {
    final db = await database;
    return await db
        .delete('images_backgraund', where: 'id = ?', whereArgs: [id]);
  }

  // Eliminar todas las imágenes de un grupo
  Future<int> deleteImagesByGroup(int groupId) async {
    final db = await database;
    return await db.delete('images_backgraund',
        where: 'group_id = ?', whereArgs: [groupId]);
  }

  /***
   *  Verificar si una imagen ya existe por su fieldId en sqlite
   */
  Future<bool> imageExistsByFieldId(String fieldId) async {
    final db = await database;
    final result = await db.query(
      'images_backgraund',
      where: 'fieldId = ?',
      whereArgs: [fieldId],
    );
    return result.isNotEmpty;
  }

  /***
   * metodo que se encarga de  cargar las imagenes de sqlite y retornarlas en
   * un future en modo de mapa
   */
  Future<Map<int, List<Map<String, dynamic>>>>
      obtenerImagenesPorGrupo2() async {
    final db = await database; //objeto sqlite

    final List<Map<String, dynamic>> resultados = await db
        .query('images_backgraund'); //consulto si hay imagenes en el sqlite

    Map<int, List<Map<String, dynamic>>> imagenesAgrupadas = {};
    print("***********************************************");
    print("total de imagenes ${resultados.length}");
    for (var fila in resultados) {
      int grupoId = fila['group_id'];

      if (!imagenesAgrupadas.containsKey(grupoId)) {
        /*
        Si aún no hay una entrada en el mapa para ese group_id, se crea una lista vacía.
        Luego se agrega esa imagen a la lista correspondiente.
         */

        imagenesAgrupadas[grupoId] = [];
      }

      imagenesAgrupadas[grupoId]!.add(fila);//se agrega item  a la lista
      print("id de la imagen: ${imagenesAgrupadas[grupoId]}");
    }

    return imagenesAgrupadas;
  }

  Future<Map<int, Map<String, List<String>>>>
      obtenerImagenesPorGrupoYSubgrupo() async {
    final db = await database;

    final List<Map<String, dynamic>> resultados =
        await db.query('images_backgraund');

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

  Future<List<FileSystemEntity>> listarBasesDeDatos() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> archivos = appDir.listSync();

    // Filtrar por archivos que terminen en ".db"
    final List<FileSystemEntity> basesDeDatos =
    archivos.where((archivo) => archivo.path.endsWith('.db')).toList();
    print("total de bases de datos ${basesDeDatos.length}");
for(var iten in basesDeDatos){
  print("ruta: ${iten}");
}
    return basesDeDatos;
  }

  Future<bool> eliminarImagenPorPath(String path) async {
    final db = await   database; // Reemplaza esto con tu método real para obtener la base de datos

    final count = await db.delete(
      'images_backgraund',
      where: 'path = ?',
      whereArgs: [path],
    );

    return count > 0;
  }

}

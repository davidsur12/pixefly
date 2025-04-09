import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data' as typed; // Para manejar Uint8List
import 'package:appwrite/models.dart' as appWriteModels;
import 'package:pixelfy/data/data_backgraund.dart';

class AppWrite {
  // Crear la instancia Singleton
  static final AppWrite _InstanciaAppWrite = AppWrite._constructor();

  // Cliente de Appwrite
  final Client client = Client();

  // Declarar `Storage` pero no inicializarlo aún
  late Storage storage;

  // Constructor privado
  AppWrite._constructor() {
    // Inicializar el cliente en el constructor privado
    client
        .setEndpoint(
            'https://cloud.appwrite.io/v1') // Setear el endpoint correcto
        .setProject('67ddc33c0007f982de7a'); // Setear tu project ID

    // Inicializar `Storage` después de que `client` esté configurado
    storage = Storage(client);
  }

  // Getter estático para obtener la instancia única
  static AppWrite get InstanciaAppWrite {
    return _InstanciaAppWrite;
  }

  Future<typed.Uint8List> downloadImage2() async {
    Client client = Client();
    client
        .setEndpoint(
            'https://cloud.appwrite.io/v1') // Setear el endpoint correcto
        .setProject('67ddc33c0007f982de7a'); // Setear tu project ID

    Storage storage = Storage(client);

    try {
      print("📥 Iniciando descarga de imagen...");

      // Verificar si storage está inicializado
      if (storage == null) {
        print("⚠️ Storage no está inicializado correctamente.");
        throw Exception("Storage no está disponible");
      }

      // Intentar descargar la imagen
      typed.Uint8List bytes = await storage.getFileDownload(
        bucketId: '67ded71200357a584f41',
        fileId: '67ec17c1003cc796dc3c',
      );

      print("✅ Imagen descargada con ${bytes.length} bytes.");

      return bytes;
    } catch (e) {
      print("❌ Error al descargar la imagen: $e");
      rethrow; // Relanza el error para que FutureBuilder lo capture
    }
  }

  Future<File> descargarImagen(String bucketId, String fileId) async {
    try {
      // Descargar los bytes del archivo desde Appwrite.
      typed.Uint8List bytes =
          await storage.getFileDownload(bucketId: bucketId, fileId: fileId);

      // Obtener un directorio temporal y definir el path del archivo descargado.
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileId.png'; // Usar un nombre único.

      // Crear un archivo local y escribir los bytes descargados.
      File file = File(tempPath);
      await file.writeAsBytes(bytes);

      return file; // Retornar el archivo creado.
    } catch (e) {
      print("Error descargando la imagen: $e");
      rethrow; // Propagar el error si necesitas manejarlo más arriba.
    }
  }

  Future<File> descargarImagen2(String bucketId, String fileId) async {
    try {
      // Descargar los bytes del archivo desde Appwrite
      typed.Uint8List bytes = await storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileId,
      );

      // Obtener el directorio temporal
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileId.png'; // Nombre único

      // Guardar la imagen localmente
      File file = File(tempPath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print("❌ Error descargando la imagen: $e");
      rethrow; // Si necesitas manejarlo más arriba
    }
  }

  /***
   * obtener lista de imagenes a descargar los 5 primeros ejemplos
   */

  Future<List<appWriteModels.Document>> getDocuments() async {
    Client client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67ddc33c0007f982de7a");

    final databases = Databases(client);
    try {
      // Llamada para listar documentos
      final documents = await databases.listDocuments(
        databaseId: '67debbb0000b14f2f7ec',
        collectionId: '67debc5a002b9f76055d',
      );

      // Retorna la lista de documentos encontrados
      print("${documents.documents.length} documentos encontrados");
      return documents.documents;
    } on AppwriteException catch (e) {
      print("Error al obtener documentos: $e");
      return []; // Retorna una lista vacía si ocurre un error
    }
  }

  Future<Set<int>> gruposBasicos() async {
    Client client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67ddc33c0007f982de7a");

    final databases = Databases(client);
    Set<int> uniqueGroups = {};
    try {
      final response = await databases.listDocuments(
        databaseId: '67debbb0000b14f2f7ec',
        collectionId: '67debc5a002b9f76055d',
        queries: [
          Query.limit(1000), // Trae hasta 1000 registros
        ],
      );

      // Extraer los valores únicos de "grupo"

      for (var doc in response.documents) {
        int groupId = doc.data['grupo']; // Asegúrate de que el tipo es int
        uniqueGroups.add(groupId);
      }
      print("**********************");
      print("uniqueGroups: $uniqueGroups");
      print("Número de grupos únicos: ${uniqueGroups.length}");
      return uniqueGroups; //uniqueGroups.length;
    } on AppwriteException catch (e) {
      print("Error: $e");
      return uniqueGroups;
    }
  }

  /***
   * me devuel el grupo y una lista de imagenes por cada grupo
   */
  Future<Map<int, List<String>>> obtenerFileIdsPorGrupo() async {
    Client client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67ddc33c0007f982de7a");

    final databases = Databases(client);
    Map<int, List<String>> fileIdsPorGrupo = {};

    try {
      // Obtener los grupos únicos
      Set<int> uniqueGroups = {1, 2, 3, 4, 5}; //await gruposBasicos();
      if (uniqueGroups.isNotEmpty) {
        for (int grupo in uniqueGroups) {
          final response = await databases.listDocuments(
            databaseId: '67debbb0000b14f2f7ec',
            collectionId: '67debc5a002b9f76055d',
            queries: [
              Query.equal('grupo', grupo), // Filtra por grupo
              Query.limit(1000), // Ajusta el límite según sea necesario
            ],
          );

          // Extraer los fileId de los documentos que pertenecen a este grupo
          List<String> fileIds = response.documents
              .map((doc) => doc.data['fileId'] as String) // ✅ Obtener el valor del campo "fileId"
              .toList();


          fileIdsPorGrupo[grupo] = fileIds;
        }

        print("File IDs por grupo: $fileIdsPorGrupo");
        return fileIdsPorGrupo;
      } else {
        print("*** uniqueGroups vacios *** ");
      }
      return fileIdsPorGrupo;
    } on AppwriteException catch (e) {
      print("Error: $e");
      return {};
    }
  }

  /// **Obtener y guardar imágenes de Appwrite**
  Future<void> obtenerYGuardarImagenes() async {
    Map<int, List<String>> fileIdsPorGrupo = await obtenerFileIdsPorGrupo();

    for (int grupo in fileIdsPorGrupo.keys) {
      for (String fileId in fileIdsPorGrupo[grupo]!) {
        print("laimagen que s deberia obtener es $grupo + $fileId");
        await descargarYGuardarImagen(grupo, fileId);
      }
    }
    print("Imagenes descargadas");
  }

  Future<void> descargarYGuardarImagen2(int grupo, String fileId) async {
    try {

      Client client = Client();
      client
          .setEndpoint(
          'https://cloud.appwrite.io/v1') // Setear el endpoint correcto
          .setProject('67ddc33c0007f982de7a'); // Setear tu project ID

      Storage storage = Storage(client);



      // 1️**Descargar los bytes de la imagen**

      typed.Uint8List bytes = await storage.getFileDownload(
        bucketId: '67ded71200357a584f41',
        fileId: fileId,
      );

      // **Guardar la imagen localmente**
      print("📥 Bytes descargados: ${bytes.length}");
      print("Desacragando la imagen $fileId");
       File imageFile = (await DataBackgraund().insertImage(grupo, fileId)) as File;

      //  **Guardar en SQLite**
         await DataBackgraund().insertImage(grupo, imageFile.path);

      print("✅ Imagen guardada en SQLite: Grupo $grupo - FileID $fileId");
    } catch (e) {
      print("❌ Error descargando imagen ($fileId): $e");
    }
  }

  Future<void> descargarYGuardarImagen(int grupo, String fileId) async {
    try {
      Client client = Client();
      client
          .setEndpoint(
          'https://cloud.appwrite.io/v1') // Setear el endpoint correcto
          .setProject('67ddc33c0007f982de7a'); // Setear tu project ID

      Storage storage = Storage(client);

      bool existe = await DataBackgraund().imageExistsByFieldId(fileId);
      if (existe) {
        print("La imagen ya está guardada.");
      } else {
        print("La imagen no está guardada todavía.");
        // 1️⃣ Descargar los bytes de la imagen desde Appwrite
        typed.Uint8List bytes = await storage.getFileDownload(
          bucketId: '67ded71200357a584f41',
          fileId: fileId,
        );

        // 2️⃣ Guardar la imagen en el almacenamiento local
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileId.png';
        final imageFile = await File(filePath).writeAsBytes(bytes);

        // 3️⃣ Guardar el grupo y el path (fileId) en SQLite
        int result = await DataBackgraund().insertImage(grupo, imageFile.path);

        if (result != -1) {
          print("✅ Imagen guardada en SQLite: Grupo $grupo - FileID $fileId");
        } else {
          print("❌ Error al guardar en SQLite");
        }
      }



    } catch (e) {
      print("❌ Error descargando imagen ($fileId): $e");
    }
  }




/*

  import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveImage(File imageFile, String fileName) async {
  final directory = await getApplicationDocumentsDirectory(); // Directorio privado de la app
  final filePath = '${directory.path}/$fileName';
  final newFile = await imageFile.copy(filePath);
  return newFile.path;
}
   */
}

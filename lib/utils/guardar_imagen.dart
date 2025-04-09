import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveImage(File imageFile, String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final newFile = await imageFile.copy(filePath);
    print('Imagen guardada correctamente en: ${newFile.path}'); // Mensaje de éxito
    return newFile.path;
  } catch (e) {
    print('Error al guardar la imagen: $e'); // Mensaje de error
    return ''; // O lanza una excepción, dependiendo de cómo quieras manejar los errores
  }
}

Future<List<File>> getImagesConsulta() async {
  final directory = await getApplicationDocumentsDirectory();
  List<File> imageFiles = [];

  try {
    final files = directory.listSync();
    for (var file in files) {
      if (file is File) {
        final filePath = file.path.toLowerCase();
        if (filePath.endsWith('.jpg') || filePath.endsWith('.png') || filePath.endsWith('.jpeg')) {
          imageFiles.add(file);
        }
      }
    }
  } catch (e) {
    print('Error al leer el directorio: $e');
  }

  return imageFiles;
}


/***
 * verifica si hay imagenes descargardas en backraund si las hay devuelve
 * la ruta de las imagenes de lo contrario las descarga
 */
Future<void> checkImagenes(Function descargarImagenes, Function error) async {
  try {
    List<File> images = await getImagesConsulta();

    if (images.isNotEmpty) {
      //no hay imagenes principales se porcede a descargarlas
      print('Se encontraron ${images.length} imágenes en el directorio.');
      descargarImagenes(); // Llamar a la función de éxito
    } else {
      print('No se encontraron imágenes en el directorio.');
      error(); // Llamar a la función de error
    }
  } catch (e) {
    print('Ocurrió un error al obtener las imágenes del directorio: $e');
    error(); // En caso de error, llamamos a la función de error
  }
}



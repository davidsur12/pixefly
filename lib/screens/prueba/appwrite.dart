import 'dart:io';



import 'package:flutter/material.dart';

import 'package:pixelfy/cloud/appwrite_recursos.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:typed_data' as typed;  // Para manejar Uint8List
import 'package:pixelfy/cloud/appwrite_recursos.dart' as funAppwrite;


class PruebaAppWrite extends StatefulWidget {
 PruebaAppWrite({super.key});
  File? imageFile;  // Variable para almacenar el archivo descargado

  @override
  State<PruebaAppWrite> createState() => _PruebaAppWriteState();
}


class _PruebaAppWriteState extends State<PruebaAppWrite> {

  late final Storage storage;
  late Future<typed.Uint8List> imageFuture;
  late Future<File> imageFuture2;

  @override
  void initState() {
    super.initState();

    // Configurar el cliente y el almacenamiento
    Client client = Client();
    client
        .setEndpoint('https://cloud.appwrite.io/v1')  // API Endpoint
        .setProject('67ddc33c0007f982de7a');  // Project ID (sin paréntesis)

    storage = Storage(client);

    // Descargar imagen una vez
    //imageFuture= funAppwrite.AppWrite.InstanciaAppWrite.downloadImage2();
   // imageFuture2 =  funAppwrite.AppWrite.InstanciaAppWrite.descargarImagen2("67ded71200357a584f41", '67ec17c1003cc796dc3c' );//downloadImage(storage);

    //imageFuture =  downloadImage(storage);
    imageFuture = funAppwrite.AppWrite.InstanciaAppWrite.downloadImage2();
    imageFuture2 = funAppwrite.AppWrite.InstanciaAppWrite.descargarImagen(
      "67ded71200357a584f41",
      '67ec17c1003cc796dc3c',
    );
  }

  Future<typed.Uint8List> downloadImage(Storage storage) async {
    // Descarga los bytes de la imagen y retorna el resultado (correctamente envuelto en Future)
    typed.Uint8List bytes = await storage.getFileDownload(
      bucketId: '67ded71200357a584f41',
      fileId: '67ec17c1003cc796dc3c',
    );
    return bytes;  // Retorna los bytes de la imagen como parte del Future
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Imagen desde Appwrite")),
      body: Center(
        child:FutureBuilder<typed.Uint8List>(
          future: imageFuture,
          builder: (context, snapshot) {
            print("📊 Estado del snapshot: ${snapshot.connectionState}");

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              print("❌ Error en FutureBuilder: ${snapshot.error}");
              return Text("Error al descargar la imagen: ${snapshot.error}");
            } else if (snapshot.hasData) {
              print("✅ Imagen lista para mostrar.");
              return Image.memory(snapshot.data!);
            } else {
              return Text("No se pudo descargar la imagen.");
            }
          },
        ),
        /*
        FutureBuilder<typed.Uint8List>(
          future: imageFuture,  // Future persistente
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();  // Mostrar loader mientras descarga
            } else if (snapshot.hasError) {
              print("Error al descargar la imagen: ${snapshot.error}");
              return Text("Error al descargar la imagen: ${snapshot.error}");
            } else if (snapshot.hasData) {
              //return Image.file(snapshot.data!);
              return Image.memory(snapshot.data!);  // Mostrar imagen descargada
            } else {
              return Text("No se pudo descargar la imagen.");
            }
          },
        ),

        */
      ),
    );
  }
}

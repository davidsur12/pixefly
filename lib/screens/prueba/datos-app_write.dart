import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:pixelfy/cloud/appwrite_recursos.dart';
import 'package:pixelfy/data/data_backgraund.dart';
import 'package:pixelfy/utils/conection_internet.dart';
import 'package:pixelfy/utils/toast_personalisados.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pixelfy/utils/guardar_imagen.dart';
import 'dart:io' as io;


class DatosAppWrite extends StatefulWidget {
  const DatosAppWrite({super.key});

  @override
  State<DatosAppWrite> createState() => _DatosAppWriteState();
}

class _DatosAppWriteState extends State<DatosAppWrite> {


  Future<List<Document>> getDocuments() async {
    Client client = Client()
        .setEndpoint(
        "https://cloud.appwrite.io/v1") // Reemplazar con el endpoint correcto
        .setProject("67ddc33c0007f982de7a"); // Coloca tu ID de proyecto

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

  Future<List<Document>> fetchDocuments() async {
    // Configura el cliente de Appwrite
    Client client = Client()
        .setEndpoint(
        "https://cloud.appwrite.io/v1") // Reemplazar con el endpoint correcto
        .setProject("67ddc33c0007f982de7a"); // Coloca tu ID de proyecto

    final databases = Databases(client);

    try {
      // Recupera los documentos de la colección según la consulta
      final documents = await databases.listDocuments(
        databaseId: '67debbb0000b14f2f7ec',
        collectionId: '67debc5a002b9f76055d',
        queries: [
          Query.equal('Nombre', 'Grupo'), // Modifica según tu campo y valor
        ],
      );
      return documents.documents; // Retorna la lista de documentos
    } on AppwriteException catch (e) {
      print("Error al obtener documentos: $e");
      return []; // Retorna una lista vacía si ocurre un error
    }
  }

  Future<int> countUniqueGroups() async {
    Client client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67ddc33c0007f982de7a");

    final databases = Databases(client);

    try {
      print("descargando imagenes");
      // ToastPersonalisado.showToasSimple(context, "Error al descargar ");
      final response = await databases.listDocuments(
        databaseId: '67debbb0000b14f2f7ec',
        collectionId: '67debc5a002b9f76055d',
        queries: [
          Query.limit(1000), // Trae hasta 1000 registros
        ],
      );

      // Extraer los valores únicos de "grupo"
      Set<int> uniqueGroups = {};

      for (var doc in response.documents) {
        int groupId = doc.data['grupo']; // Asegúrate de que el tipo es int
        uniqueGroups.add(groupId);
      }
      print("**********************");
      print(uniqueGroups);
      print("Número de grupos únicos: ${uniqueGroups.length}");
      return uniqueGroups.length;
    } on AppwriteException catch (e) {
      print("Error: $e");
      return 0; // Retorna 0 si hay un error
    }
  }

  void conecionInternet(Future<void> Function() funcion, Function() error) {
    final listener =
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
        // The internet is now connected
          funcion();
          break;
        case InternetStatus.disconnected:
        // The internet is now disconnected
          print("No hay internet");
          // ToastPersonalisado.showToasSimple(context, "Error al descargar ");
          //error();


          break;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Column(children: [

          FloatingActionButton(onPressed: () {
  /*
            conecionInternet4(
                AppWrite.InstanciaAppWrite.obtenerYGuardarImagenes,
                //AppWrite.InstanciaAppWrite.gruposBasicos,
                    () =>
                    ToastPersonalisado.showToasSimple(
                        context, "Error al descargar las imagens "));
            */
             //checkImagenes();

           // buildImagenesAgrupadasWidget();

          }


          ),
          FloatingActionButton(onPressed: () async {
            //descarga las imagenes
            List<Map<String, dynamic>> images = await DataBackgraund().getImages();
            print("total imagenes decargadas ${images.length}");


          },)],),




    body: buildImagenesAgrupadasWidget(context)
    /*SingleChildScrollView(
    child:buildImagenesAgrupadasWidget()

    Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    FutureBuilder<List<Document>>(
    future: getDocuments(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Center(child: Text("Error: ${snapshot.error}"));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return Center(child: Text("No hay documentos."));
    } else {
    final documents = snapshot.data!;
    return ListView.builder(
    shrinkWrap: true, // Solución: Permite que ListView adapte su tamaño al contenido
    physics: NeverScrollableScrollPhysics(), // Desactiva el scroll de ListView para evitar conflictos
    itemCount: documents.length,
    itemBuilder: (context, index) {
    return ListTile(
    title: Text(documents[index].data['nombre'] ?? 'Sin título'),
    subtitle: Text(documents[index].data['grupo'].toString() ?? 'Sin descripción'),

    );
    },
    );
    }
    },
    )
    ],
    ),





    )
    */

    );
  }

  /*
  void mostrarImagenesAgrupadas() async {
    final grupos = await DataBackgraund().obtenerImagenesPorGrupo();

    grupos.forEach((grupoId, imagenes) {
      print('Grupo $grupoId:');
      for (var imagen in imagenes) {
        print(' - fieldId: ${imagen['fieldId']}');
      }
    });
  }
  */


  Widget buildImagenesAgrupadasWidget(BuildContext context) {
    return FutureBuilder<Map<int, Map<String, List<String>>>>(
      future: DataBackgraund().obtenerImagenesPorGrupoYSubgrupo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay imágenes guardadas.'));
        }

        final data = snapshot.data!;

        return ListView(
          children: data.entries.map((grupo) {
            return ExpansionTile(
              title: Text('Grupo ${grupo.key}'),
              children: grupo.value.entries.map((subgrupo) {
                return ExpansionTile(
                  title: Text('Subgrupo: ${subgrupo.key}'),
                  children: subgrupo.value.map((fieldId) {
                    return ListTile(
                      title: Text(fieldId),
                      onTap: () {
                        mostrarImagenDialog(context, fieldId);
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
  void mostrarImagenDialog(BuildContext context, String rutaImagen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(io.File(rutaImagen), fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              rutaImagen,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }



}

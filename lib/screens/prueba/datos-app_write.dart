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
            conecionInternet4(
                AppWrite.InstanciaAppWrite.obtenerYGuardarImagenes,
                //AppWrite.InstanciaAppWrite.gruposBasicos,
                    () =>
                    ToastPersonalisado.showToasSimple(
                        context, "Error al descargar las imagens "));

            //checkImagenes();

            // buildImagenesAgrupadasWidget();

          }


          ),
          FloatingActionButton(onPressed: () async {
            mostrarImagenesAgrupadas();
            //descarga las imagenes
            List<Map<String, dynamic>> images = await DataBackgraund()
                .getImages();
            print("total imagenes decargadas ${images.length}");
          },)
        ],),


        body: buildBottomSheetGruposYImagenesFuture() //buildGruposDeImagenes() //buildImagenesAgrupadasWidget(context)


    );
  }


  void mostrarImagenesAgrupadas() async {
    final grupos = await DataBackgraund().obtenerImagenesPorGrupo2();

    grupos.forEach((grupoId, imagenes) {
      print('Grupo $grupoId:');
      for (var imagen in imagenes) {
        print(' - fieldId: ${imagen['fieldId']}');
      }
    });
  }

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
      builder: (context) =>
          AlertDialog(
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

  Widget buildGruposDeImagenes() {
    return FutureBuilder<Map<int, List<Map<String, dynamic>>>>(
      future: DataBackgraund().obtenerImagenesPorGrupo2(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay grupos disponibles.'));
        }

        final grupos = snapshot.data!;

        return ListView.builder(
          itemCount: grupos.length,
          itemBuilder: (context, index) {
            final grupoId = grupos.keys.elementAt(index);
            final imagenes = grupos[grupoId]!;

            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grupo $grupoId',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: imagenes
                          .map((imagen) =>
                          Chip(
                            label: Text(imagen['fieldId'].toString()),
                          ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }





  Widget buildBottomSheetGruposYImagenesFuture() {
    return FutureBuilder<Map<int, List<Map<String, dynamic>>>>(
      future: DataBackgraund().obtenerImagenesPorGrupo2(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay imágenes agrupadas.'));
        }

        final gruposConImagenes = snapshot.data!;
        final grupoKeys = gruposConImagenes.keys.toList();
        final pageController = PageController();
        final currentGrupo = ValueNotifier<int>(grupoKeys.first);

        return ValueListenableBuilder<int>(
          valueListenable: currentGrupo,
          builder: (context, grupoActualId, _) {
            return Container(
              height: 350,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila de grupos
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: grupoKeys.length,
                      itemBuilder: (context, index) {
                        final grupoId = grupoKeys[index];
                        final isSelected = grupoId == grupoActualId;

                        return GestureDetector(
                          onTap: () {
                            currentGrupo.value = grupoId;
                            pageController.jumpToPage(index);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                              isSelected ? Colors.blue : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Grupo $grupoId',
                                style: TextStyle(
                                  color:
                                  isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fila de imágenes por grupo
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: grupoKeys.length,
                      onPageChanged: (index) {
                        currentGrupo.value = grupoKeys[index];
                      },
                      itemBuilder: (context, index) {
                        final grupoId = grupoKeys[index];
                        final imagenes = gruposConImagenes[grupoId]!;

                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: imagenes.map((imagen) {
                            final ruta = imagen['fieldId'];

                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  io.File(ruta),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }




}

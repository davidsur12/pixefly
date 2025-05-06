import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pixelfy/cloud/appwrite_recursos.dart';
import 'package:pixelfy/data/backgraund/data_backgraund.dart';
import 'package:pixelfy/utils/conection_internet.dart';
import 'package:pixelfy/utils/toast_personalisados.dart';
class ImagenVerificada extends StatefulWidget {
  final String ruta;

  const ImagenVerificada({super.key, required this.ruta});

  @override
  State<ImagenVerificada> createState() => _ImagenVerificadaState();
}

class _ImagenVerificadaState extends State<ImagenVerificada> {
  late Future<bool> _future;
  bool _descargaIniciada = false;

  @override
  void initState() {
    super.initState();
    _future = _verificarImagenYDescargarSiEsInvalida();
  }

  Future<bool> _verificarImagenYDescargarSiEsInvalida() async {
    print("verificando imagenes");
    final file = File(widget.ruta);
    bool esValida = false;//devuelve falso si la imagen esta dañada

    if (await file.exists()) {
      print("la imagen si existe");
      final length = await file.length();
      esValida = length > 0;
    }

    if (esValida == false) {
      print("Imagen inválida. Eliminando y descargando...");
      //elimino el registro en la base de datos
      await DataBackgraund().eliminarImagenPorPath(widget.ruta);

      if (!_descargaIniciada) {
        _descargaIniciada = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          conecionInternet4(
            AppWrite.InstanciaAppWrite.obtenerYGuardarImagenesBackgraund,
                () => ToastPersonalisado.showToasSimple(
                context, "Error al descargar las imágenes"),
          );
        });
      }
    }

    return esValida;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 120,
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
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
                File(widget.ruta),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          print("error al cargar la imagen");
          return const SizedBox.shrink(); // Imagen inválida: no mostrar nada
        }
      },
    );
  }
}




/*
class ImagenVerificada extends StatelessWidget {
  final String ruta;

  const ImagenVerificada({super.key, required this.ruta});

  Future<bool> _esImagenValidaYEliminaSiNo() async {
    final file = File(ruta);
    if (await file.exists()) {
      final length = await file.length();
      if (length > 0) {
        return true;
      } else {
        print("ruta eliminada");
        await DataBackgraund().eliminarImagenPorPath(ruta);
        return false;
      }
    } else {
      print("ruta eliminada");
      await DataBackgraund().eliminarImagenPorPath(ruta);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _esImagenValidaYEliminaSiNo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 120,
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {

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
                File(ruta),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          /*
          si hibo un error al cargar el archivo se procede a volver
          a descargar los recursos faltantes
           */
          print("se procede a descargar los archivos por que estan corructos");
          conecionInternet4(
              AppWrite.InstanciaAppWrite.obtenerYGuardarImagenesBackgraund,
              //AppWrite.InstanciaAppWrite.gruposBasicos,
                  () => ToastPersonalisado.showToasSimple(
                  context, "Error al descargar las imagens "));
          return SizedBox.shrink(); // No mostrar nada si fue eliminado o inválido
        }
      },
    );
  }
}
*/



import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:ui';

class CollagePhoto {
  //Uint8List image; // Imagen en bytes
  int id;
  double width;
  Offset position; // Posición dentro del collage
  double scale; // Tamaño de la imagen
  double rotation; // Rotación de la imagen en grados

  // litsa de pociciones
  List<Offset> listaPosicioes = [Offset(0, 0), Offset(0, 0)];
  CollagePhoto({
    //required this.image,
    this.id = 1,
    this.width=0,
    this.position = const Offset(0, 0),
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

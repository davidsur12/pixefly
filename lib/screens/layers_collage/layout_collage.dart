


import 'dart:ui';

class CollagePhoto {
  //debe agregarse la lista de imagenes
  int id;
  double width;
  double height;
  Offset position;
  double scale;
  double rotation;
  List<Offset> listaPosicioes;

  CollagePhoto({
    this.id = 1,
    this.width = 0,
    this.height=0,
    this.position = const Offset(0, 0),
    this.scale = 1.0,
    this.rotation = 0.0,
  }) : listaPosicioes = [ Offset(0, (0)), ];//Offset((0), (height*0.5))
}

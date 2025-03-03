import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/screens/layers_collage/layout_collage.dart';
import 'package:pixelfy/screens/layers_collage/resize_layout_stack.dart';
/***
 * clase que se encarga de gestionar los collage se agrega a la capa de
 * ImageEditorScreen donde esta el editor principal
 * esta clase se encarga de obtener  o cargar las items de diseños de collage
 * con sus imagenes y su respectivo ajuste de tamaño
 * recibe como parametros el ancho y el alto del area de trabajo segun el
 * aspecradio y se rederiza segun el cambio de aspecto
 */
class CapaLayoutCollage extends StatefulWidget {

  double width; //ancho del aspec radio
  double height; //largo del aspecradio

  //las imagenes estan en la clase CollagePhoto

  CapaLayoutCollage({super.key, required this.width, required this.height});

  @override
  State<CapaLayoutCollage> createState() => _CapaLayoutCollageState();
}

class _CapaLayoutCollageState extends State<CapaLayoutCollage> {
  late CollagePhoto collagePhoto;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("el collage tiene un ancho: ${widget.width} y el alto: ${widget.height}");
    collagePhoto = CollagePhoto(width: widget.width, height: widget.height);
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(children: [
      ...collagePhoto.listaPosicioes.map((pos)=> ResizableStack(
        initialWidth: widget.width /2,
        initialHeight: widget.height,
        position: pos,
      )).toList()

    ],);}}

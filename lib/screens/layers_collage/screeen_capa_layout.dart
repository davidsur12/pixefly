import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/screens/layers_collage/layout_collage.dart';
import 'package:pixelfy/screens/layers_collage/resize_layout_stack.dart';
import 'package:pixelfy/utils/size_ratio.dart';
import 'package:provider/provider.dart';
/***
 * clase que se encarga de gestionar los collage se agrega a la capa de
 * ImageEditorScreen donde esta el editor principal
 * esta clase se encarga de obtener  o cargar las items de diseños de collage
 * con sus imagenes y su respectivo ajuste de tamaño
 * recibe como parametros el ancho y el alto del area de trabajo segun el
 * aspecradio y se rederiza segun el cambio de aspecto
 */

/*
class CapaLayoutCollage extends StatelessWidget {
  final double width;
  final double height;

  CapaLayoutCollage({Key? key, required this.width, required this.height}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...CollagePhoto(width: width, height: height).listaPosicioes.map((pos) =>
            ResizableStack(
              key: ValueKey(pos), // Evita que los widgets se pierdan en reconstrucciones
              initialWidth: width / 2,
              initialHeight: height,
              position: pos,
            )
        ).toList(),
      ],
    );
  }
}
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
    //collagePhoto = CollagePhoto(width: widget.width, height: widget.height);
  }

  @override
  Widget build(BuildContext context) {
    double w =context.watch<SizeRatio>().width;
    double h =context.watch<SizeRatio>().height;
    collagePhoto = CollagePhoto(width: w, height: h);
    return  Stack(children: [
      ...collagePhoto.listaPosicioes.map((pos)=> ResizableStack(
        initialWidth: w/2,//widget.width /2,
        initialHeight: h/2,//widget.height,
        position: pos,
      )).toList()

    ],);}}

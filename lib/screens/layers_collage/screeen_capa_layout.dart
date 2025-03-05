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
  final double width;
  final double height;

  CapaLayoutCollage({super.key, required this.width, required this.height});

  @override
  State<CapaLayoutCollage> createState() => _CapaLayoutCollageState();
}

class _CapaLayoutCollageState extends State<CapaLayoutCollage> {
  late double leftWidth;
  late double rightWidth;
  double borderRadius = 0.0;
  double minWidth = 50.0; // Ancho mínimo de cada caja
  late double maxWidth; // Se calculará dinámicamente

  @override
  void initState() {
    super.initState();
    leftWidth = widget.width / 2;
    rightWidth = widget.width / 2;
    maxWidth = widget.width * 0.8; // Máximo 80% del total
    minWidth = widget.width*0.2;
  }

  void updateLeftSize(double newWidth) {
    setState(() {
      double adjustedLeftWidth = newWidth.clamp(minWidth, widget.width - minWidth);
      double adjustedRightWidth = widget.width - adjustedLeftWidth;

      leftWidth = adjustedLeftWidth;
      rightWidth = adjustedRightWidth;
    });
  }

  void updateRightSize(double newWidth) {
    setState(() {
      double adjustedRightWidth = newWidth.clamp(minWidth, widget.width - minWidth);
      double adjustedLeftWidth = widget.width - adjustedRightWidth;

      rightWidth = adjustedRightWidth;
      leftWidth = adjustedLeftWidth;
    });
  }

 
  @override
  Widget build(BuildContext context) {
    double h = widget.height;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ResizableStack(
                width: leftWidth,
                height: h,
                position: Offset(0, 0),
                maxWidth: widget.width*0.8,
                minWidth: widget.width*0.2,
                borderRadius: borderRadius,
                onResize: (newWidth, _) => updateLeftSize(newWidth),
              ),
              ResizableStack(
                width: rightWidth,
                height: h,
                position: Offset(leftWidth, 0),
                maxWidth: widget.width*0.8,
                minWidth: widget.width*0.2,
                borderRadius: borderRadius,
                onResize: (newWidth, _) => updateRightSize(newWidth),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("Radio del Borde: ${borderRadius.toInt()}"),
              Slider(
                value: borderRadius,
                min: 0,
                max: 50,
                onChanged: (value) {
                  setState(() {
                    borderRadius = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/*
class CapaLayoutCollage extends StatefulWidget {
  final double width;
  final double height;

  CapaLayoutCollage({super.key, required this.width, required this.height});

  @override
  State<CapaLayoutCollage> createState() => _CapaLayoutCollageState();
}

class _CapaLayoutCollageState extends State<CapaLayoutCollage> {
  late double leftWidth;
  late double rightWidth;
  double borderRadius = 0.0; // Nuevo estado para el radio del borde

  @override
  void initState() {
    super.initState();
    leftWidth = widget.width / 2;
    rightWidth = widget.width / 2;
  }

  void updateLeftSize(double newWidth) {
    setState(() {
      leftWidth = newWidth.clamp(50.0, widget.width - 50.0);
      rightWidth = widget.width - leftWidth;
    });
  }

  void updateRightSize(double newWidth) {
    setState(() {
      rightWidth = newWidth.clamp(50.0, widget.width - 50.0);
      leftWidth = widget.width - rightWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = widget.height;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ResizableStack(
                width: leftWidth,
                height: h,
                position: Offset(0, 0),
                borderRadius: borderRadius,
                onResize: (newWidth, _) => updateLeftSize(newWidth),
              ),
              ResizableStack(
                width: rightWidth,
                height: h,
                position: Offset(leftWidth, 0),
                borderRadius: borderRadius,
                onResize: (newWidth, _) => updateRightSize(newWidth),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("Radio del Borde: ${borderRadius.toInt()}"),
              Slider(
                value: borderRadius,
                min: 0,
                max: 50, // Ajusta el valor máximo según necesites
                onChanged: (value) {
                  setState(() {
                    borderRadius = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
*/




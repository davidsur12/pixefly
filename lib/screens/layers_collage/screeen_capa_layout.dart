import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/screens/layers_collage/layout_collage.dart';
import 'package:pixelfy/screens/layers_collage/resize_layout_stack.dart';
import 'package:pixelfy/utils/images_seleccionadas.dart';
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
  double margin = 8.0;
  late double minWidth;
  late double maxWidth;

  @override
  void initState() {
    super.initState();
    minWidth = (widget.width - (3 * margin)) * 0.2;
    maxWidth = (widget.width - (3 * margin)) * 0.8;
    leftWidth = ((widget.width - (3 * margin)) / 2);
    rightWidth = ((widget.width - (3 * margin)) / 2);
  }

  void updateLeftSize(double newWidth) {
    setState(() {
      double adjustedLeftWidth = newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedRightWidth = widget.width - adjustedLeftWidth - (3 * margin);

      leftWidth = adjustedLeftWidth;
      rightWidth = adjustedRightWidth;
    });
  }

  void updateRightSize(double newWidth) {
    setState(() {
      double adjustedRightWidth = newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedLeftWidth = widget.width - adjustedRightWidth - (3 * margin);

      rightWidth = adjustedRightWidth;
      leftWidth = adjustedLeftWidth;
    });
  }

  void updateMargin(double newMargin) {
    setState(() {
      margin = newMargin.clamp(0, widget.width * 0.05);
      minWidth = (widget.width - (3 * margin)) * 0.2;
      maxWidth = (widget.width - (3 * margin)) * 0.8;
      leftWidth = ((widget.width - (3 * margin)) / 2);
      rightWidth = ((widget.width - (3 * margin)) / 2);
    });
  }

  void onBoxClicked(String boxName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Has hecho clic en $boxName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = widget.height - (2 * margin);

    return Padding(
      padding: EdgeInsets.all(margin),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ResizableStack(
                  width: leftWidth,
                  height: h,
                  position: Offset(0, 0),
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                  borderRadius: borderRadius,
                  onResize: (newWidth, _) => updateLeftSize(newWidth),
                  onTap: () => onBoxClicked("Caja Izquierda"), // ✅ Se pasa el evento onClick
                 // DoubleeOnTap: () => onBoxClicked("doble tap Caja izquierda"),
                  image:Provider.of<ImagesSeleccionadas>(context).selectedImages[0] ,
                ),
                ResizableStack(
                  width: rightWidth,
                  height: h,
                  position: Offset(leftWidth + margin, 0),
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                  borderRadius: borderRadius,
                  onResize: (newWidth, _) => updateRightSize(newWidth),
                  onTap: () => onBoxClicked("Caja Derecha"), // ✅ Se pasa el evento onClick
                //  DoubleeOnTap: () => onBoxClicked("doble tap Caja Derecha"),
                  image:Provider.of<ImagesSeleccionadas>(context).selectedImages[1] ,
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
                Text("Margen entre cajas y bordes: ${margin.toInt()}"),
                Slider(
                  value: margin,
                  min: 0,
                  max:  widget.width > 0 ? widget.width * 0.05:1,
                  onChanged: (value) => updateMargin(value),
                ),
              ],
            ),
          ),
        ],
      ),
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
  double borderRadius = 0.0;
  double margin = 8.0;
  late double minWidth;
  late double maxWidth;

  @override
  void initState() {
    super.initState();
    minWidth = (widget.width - (3 * margin)) * 0.2;
    maxWidth = (widget.width - (3 * margin)) * 0.8;
    leftWidth = ((widget.width - (3 * margin)) / 2);
    rightWidth = ((widget.width - (3 * margin)) / 2);
  }

  void updateLeftSize(double newWidth) {
    setState(() {
      double adjustedLeftWidth = newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedRightWidth = widget.width - adjustedLeftWidth - (3 * margin);

      leftWidth = adjustedLeftWidth;
      rightWidth = adjustedRightWidth;
    });
  }

  void updateRightSize(double newWidth) {
    setState(() {
      double adjustedRightWidth = newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedLeftWidth = widget.width - adjustedRightWidth - (3 * margin);

      rightWidth = adjustedRightWidth;
      leftWidth = adjustedLeftWidth;
    });
  }

  void updateMargin(double newMargin) {
    setState(() {
      margin = newMargin.clamp(0, widget.width * 0.05);
      minWidth = (widget.width - (3 * margin)) * 0.2;
      maxWidth = (widget.width - (3 * margin)) * 0.8;
      leftWidth = ((widget.width - (3 * margin)) / 2);
      rightWidth = ((widget.width - (3 * margin)) / 2);
    });
  }

  void onBoxClicked(String boxName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Has hecho clic en $boxName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = widget.height - (2 * margin);

    return Padding(
      padding: EdgeInsets.all(margin),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ResizableStack(
                  width: leftWidth,
                  height: h,
                  position: Offset(0, 0),
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                  borderRadius: borderRadius,
                  onResize: (newWidth, _) => updateLeftSize(newWidth),
                  onTap: () => onBoxClicked("Caja Izquierda"), // ✅ Se pasa el evento onClick
                ),
                ResizableStack(
                  width: rightWidth,
                  height: h,
                  position: Offset(leftWidth + margin, 0),
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                  borderRadius: borderRadius,
                  onResize: (newWidth, _) => updateRightSize(newWidth),
                  onTap: () => onBoxClicked("Caja Derecha"), // ✅ Se pasa el evento onClick
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
                Text("Margen entre cajas y bordes: ${margin.toInt()}"),
                Slider(
                  value: margin,
                  min: 0,
                  max: widget.width * 0.05,
                  onChanged: (value) => updateMargin(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

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
  double borderRadius = 0.0;
  double margin = 8.0; // 🔹 Margen inicial aplicado a todos los lados
  late double minWidth;
  late double maxWidth;

  @override
  void initState() {
    super.initState();
    minWidth = (widget.width - (3 * margin)) * 0.2;
    maxWidth = (widget.width - (3 * margin)) * 0.8;
    leftWidth = ((widget.width - (3 * margin)) / 2);
    rightWidth = ((widget.width - (3 * margin)) / 2);
  }

  void updateLeftSize(double newWidth) {
    setState(() {
      double adjustedLeftWidth = newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedRightWidth = widget.width - adjustedLeftWidth - (3 * margin);

      leftWidth = adjustedLeftWidth;
      rightWidth = adjustedRightWidth;
    });
  }

  void updateRightSize(double newWidth) {
    setState(() {
      double adjustedRightWidth = newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedLeftWidth = widget.width - adjustedRightWidth - (3 * margin);

      rightWidth = adjustedRightWidth;
      leftWidth = adjustedLeftWidth;
    });
  }

  void updateMargin(double newMargin) {
    setState(() {
      margin = newMargin.clamp(0, widget.width * 0.05); // 🔹 Límite del margen
      minWidth = (widget.width - (3 * margin)) * 0.2;
      maxWidth = (widget.width - (3 * margin)) * 0.8;
      leftWidth = ((widget.width - (3 * margin)) / 2);
      rightWidth = ((widget.width - (3 * margin)) / 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = widget.height - (2 * margin); // 🔹 Se descuenta el margen superior e inferior

    return Padding(
      padding: EdgeInsets.all(margin), // 🔹 Margen aplicado alrededor de todo el collage
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ResizableStack(
                  width: leftWidth,
                  height: h,
                  position: Offset(0, 0),
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                  borderRadius: borderRadius,
                  onResize: (newWidth, _) => updateLeftSize(newWidth),
                ),
                ResizableStack(
                  width: rightWidth,
                  height: h,
                  position: Offset(leftWidth + margin, 0), // 🔹 Margen entre las cajas
                  maxWidth: maxWidth,
                  minWidth: minWidth,
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
                Text("Margen entre cajas y bordes: ${margin.toInt()}"),
                Slider(
                  value: margin,
                  min: 0,
                  max: widget.width * 0.05, // 🔹 Ajuste de margen hasta 5% del ancho total
                  onChanged: (value) => updateMargin(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

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
*/







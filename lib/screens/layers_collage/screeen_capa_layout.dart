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
  int? _selectedId; // 👈 Variable para rastrear la caja seleccionada

  @override
  void initState() {
    super.initState();
    minWidth = (widget.width - (3 * margin)) * 0.2;
    maxWidth = (widget.width - (3 * margin)) * 0.8;
    leftWidth = ((widget.width - (3 * margin)) / 2);
    rightWidth = ((widget.width - (3 * margin)) / 2);
  }
/*
  void updateLeftSize(double newWidth) {
    setState(() {
      double adjustedLeftWidth =
          newWidth.clamp(minWidth, widget.width - minWidth - (3 * margin));
      double adjustedRightWidth =
          widget.width - adjustedLeftWidth - (3 * margin);

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
  */
  void updateRightSize(double newWidth) {
    setState(() {
      // Asegurar que el ancho derecho esté dentro de los límites
      double adjustedRightWidth = newWidth.clamp(minWidth, maxWidth);

      // Calcular el nuevo ancho del izquierdo sin reducirlo más de su mínimo
      double adjustedLeftWidth = (widget.width - adjustedRightWidth - (3 * margin)).clamp(minWidth, double.infinity);

      // Evitar que el derecho se desplace
      if (adjustedLeftWidth < minWidth) {
        adjustedLeftWidth = minWidth;
        adjustedRightWidth = widget.width - minWidth - (3 * margin);
      }

      rightWidth = adjustedRightWidth;
      leftWidth = adjustedLeftWidth;
    });
  }

/*
  void updateRightSize(double newWidth) {
    print("--------------------");
    print("ancho total ${widget.width}");
    print("minimo ancho $minWidth");
    print("maximo ancho $maxWidth");
    print("la psicionde debria ser ${leftWidth + margin}");
    print("margen $margin");
    setState(() {
      // Ajustar el ancho derecho dentro de los límites permitidos
      double adjustedRightWidth = newWidth.clamp(minWidth, maxWidth);//restringe el valor en tre los limites

      // Ajustar el ancho izquierdo sin permitir que sea menor a su mínimo
      double adjustedLeftWidth = (widget.width - adjustedRightWidth - (3 * margin)).clamp(minWidth, maxWidth);

      // Aplicar los valores corregidos sin alterar la posición del izquierdo
      rightWidth = adjustedRightWidth;
      leftWidth = adjustedLeftWidth;
      print("ancho right: $rightWidth");
      print("ancho left: $leftWidth");
    });
  }
*/
  void updateLeftSize(double newWidth) {
    setState(() {
      // Ajustar el ancho izquierdo dentro de los límites permitidos
      double adjustedLeftWidth = newWidth.clamp(minWidth, maxWidth);

      // Ajustar el ancho derecho sin permitir que sea menor a su mínimo
      double adjustedRightWidth = (widget.width - adjustedLeftWidth - (3 * margin)).clamp(minWidth, maxWidth);

      // Aplicar los valores corregidos sin alterar la posición del derecho
      leftWidth = adjustedLeftWidth;
      rightWidth = adjustedRightWidth;
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

  void onBoxClicked(int id) {
    setState(() {
      _selectedId = (_selectedId == id) ? null : id; // Alterna la selección
    });
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
                  onTap: () => onBoxClicked(0),
                  // 👈 Pasa el ID 0
                  image: Provider.of<ImagesSeleccionadas>(context)
                      .selectedImages[0],
                  id: 0,
                  isSelected:
                      _selectedId == 0, // 👈 Verifica si está seleccionado
                ),
                ResizableStack(
                  width: rightWidth,
                  height: h,
                  position: Offset(leftWidth + margin, 0),
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                  borderRadius: borderRadius,
                  onResize: (newWidth, _) => updateRightSize(newWidth),
                  onTap: () => onBoxClicked(1),
                  // 👈 Pasa el ID 1
                  image: Provider.of<ImagesSeleccionadas>(context)
                      .selectedImages[1],
                  id: 1,
                  isSelected:
                      _selectedId == 1, // 👈 Verifica si está seleccionado
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
                  id: 0,
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
                  id: 1,
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

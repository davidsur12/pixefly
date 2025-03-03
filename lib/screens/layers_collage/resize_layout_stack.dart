import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layers_collage/layout_collage.dart';

/***
 * figura de cuadrado con los siguientes parametros
 * posicion
 * ancho
 * alto
 * ,odificadores de tamaño
 * limitadores
 * ancho y alto minimo
 */


/*
class ResizableStack extends StatefulWidget {
  final double initialWidth;
  final double initialHeight;
  final Offset position;

  ResizableStack({
    Key? key,
    required this.initialWidth,
    required this.initialHeight,
    required this.position,
  }) : super(key: key);

  @override
  _ResizableStackState createState() => _ResizableStackState();
}

class _ResizableStackState extends State<ResizableStack> {
  late double width;
  late double height;
  late Offset position;

  @override
  void initState() {
    super.initState();
    width = widget.initialWidth;
    height = widget.initialHeight;
    position = widget.position;
  }

  @override
  void didUpdateWidget(covariant ResizableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWidth != widget.initialWidth || oldWidget.initialHeight != widget.initialHeight) {
      setState(() {
        width = widget.initialWidth;
        height = widget.initialHeight;
        position = widget.position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Center(child: Icon(Icons.image, size: 50)),
      ),
    );
  }
}
*/
class ResizableStack extends StatefulWidget {
  final double initialWidth;
  final double initialHeight;
  final Offset position;

  ResizableStack({
    Key? key,
    required this.initialWidth,
    required this.initialHeight,
    required this.position,
  }) : super(key: key);

  @override
  _ResizableStackState createState() => _ResizableStackState();
}

class _ResizableStackState extends State<ResizableStack> {
  late double width;
  late double height;
  late Offset position;
  late CollagePhoto boxCollage;

  @override
  void initState() {
    super.initState();
    width = widget.initialWidth;
    height = widget.initialHeight;
    position = widget.position;
    boxCollage = CollagePhoto(width: width, height: height);
  }


  void _updateSize(double dx, double dy, {bool fromLeft = false, bool fromTop = false}) {
    setState(() {
      if (fromLeft) {
        position = position.translate(dx, 0); // Mueve el cuadro hacia la izquierda
        width -= dx;
      } else {
        width += dx;
      }

      if (fromTop) {
        position = position.translate(0, dy); // Mueve el cuadro hacia arriba
        height -= dy;
      } else {
        height += dy;
      }

      // Límites del tamaño
      width = width.clamp(100.0, 500.0);
      height = height.clamp(100.0, 500.0);
    });
  }

  Widget _buildResizeHandle({required double left, required double top, required Function(DragUpdateDetails) onDrag}) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: onDrag,
        child: Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Center(child: Icon(Icons.image, size: 50)),
          ),

          // 🔴 Puntos de control colocados correctamente
          _buildResizeHandle(left: -10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0, fromLeft: true)), // Izquierda
          _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)), // Derecha
          _buildResizeHandle(left: width / 2 - 10, top: -10, onDrag: (d) => _updateSize(0, d.delta.dy, fromTop: true)), // Arriba
          _buildResizeHandle(left: width / 2 - 10, top: height - 10, onDrag: (d) => _updateSize(0, d.delta.dy)), // Abajo

        ],
      ),
    );
  }
}

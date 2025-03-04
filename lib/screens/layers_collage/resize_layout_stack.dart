import 'package:flutter/material.dart';
import 'package:pixelfy/main.dart';
import 'package:pixelfy/screens/layers_collage/layout_collage.dart';
import 'package:pixelfy/utils/size_ratio.dart';
import 'package:provider/provider.dart';

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

/*
class ResizableStack extends StatefulWidget {
  final Offset position;

  ResizableStack({
    Key? key,
    required this.position,
  }) : super(key: key);

  @override
  _ResizableStackState createState() => _ResizableStackState();
}

class _ResizableStackState extends State<ResizableStack> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = widget.position;
  }

  void _updateSize(double dx, double dy, {bool fromLeft = false, bool fromTop = false}) {
    setState(() {
      final sizeProvider = Provider.of<SizeRatio>(context, listen: false);
      double newWidth = sizeProvider.width;
      double newHeight = sizeProvider.height;

      if (fromLeft) {
        position = position.translate(dx, 0);
        newWidth -= dx;
      } else {
        newWidth += dx;
      }

      if (fromTop) {
        position = position.translate(0, dy);
        newHeight -= dy;
      } else {
        newHeight += dy;
      }

      // Evitar que el tamaño sea demasiado pequeño
      newWidth = newWidth.clamp(50.0, double.infinity);
      newHeight = newHeight.clamp(50.0, double.infinity);

      // Actualizar los valores en el provider
      sizeProvider.cambioSize(newWidth, newHeight);
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
    final sizeProvider = context.watch<SizeRatio>(); // Obteniendo el tamaño actualizado
    double width = sizeProvider.width;
    double height = sizeProvider.height;

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

          // Puntos de redimensionamiento
          _buildResizeHandle(left: -10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0, fromLeft: true)), // Izquierda
          _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)), // Derecha
          _buildResizeHandle(left: width / 2 - 10, top: -10, onDrag: (d) => _updateSize(0, d.delta.dy, fromTop: true)), // Arriba
          _buildResizeHandle(left: width / 2 - 10, top: height - 10, onDrag: (d) => _updateSize(0, d.delta.dy)), // Abajo
        ],
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

  @override
  void didUpdateWidget(covariant ResizableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialWidth != oldWidget.initialWidth || widget.initialHeight != oldWidget.initialHeight) {
      setState(() {
        width = widget.initialWidth;
        height = widget.initialHeight;
        position = widget.position; // Recalcular posición si es necesario
      });
    }
  }

  @override
  void initState() {
    super.initState();
    width = widget.initialWidth;
    height = widget.initialHeight;
    position = widget.position;
  }

  void _updateSize(double dx, double dy, {bool fromLeft = false, bool fromTop = false}) {
    setState(() {
      if (fromLeft) {
        position = position.translate(dx, 0);
        width -= dx;
      } else {
        width += dx;
      }

      if (fromTop) {
        position = position.translate(0, dy);
        height -= dy;
      } else {
        height += dy;
      }

      // Evitar que el tamaño sea demasiado pequeño o grande
      width = width.clamp(50.0, widget.initialWidth);
      height = height.clamp(50.0, widget.initialHeight);
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
    double w =context.watch<SizeRatio>().width;
    double h =context.watch<SizeRatio>().height;
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

          // Puntos de redimensionamiento
          _buildResizeHandle(left: -10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0, fromLeft: true)), // Izquierda
          _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)), // Derecha
          _buildResizeHandle(left: width / 2 - 10, top: -10, onDrag: (d) => _updateSize(0, d.delta.dy, fromTop: true)), // Arriba
          _buildResizeHandle(left: width / 2 - 10, top: height - 10, onDrag: (d) => _updateSize(0, d.delta.dy)), // Abajo
        ],
      ),
    );
  }
}


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
*/
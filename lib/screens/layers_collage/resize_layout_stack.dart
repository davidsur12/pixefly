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



class ResizableStack extends StatefulWidget {
  final double width;
  final double height;
  final Offset position;
  final double borderRadius;
  final Function(double newWidth, double newHeight)? onResize;
  final double? maxWidth;
  final double? minWidth;
  final VoidCallback? onTap; // ✅ Agregamos el evento onClick

  ResizableStack({
    Key? key,
    required this.width,
    required this.height,
    required this.position,
    this.borderRadius = 0.0,
    this.onResize,
    this.maxWidth,
    this.minWidth,
    this.onTap, // ✅ Se recibe el callback de clic
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
    width = widget.width;
    height = widget.height;
    position = widget.position;
  }

  void _updateSize(double dx, double dy, {bool fromLeft = false}) {
    setState(() {
      if (fromLeft) {
        position = position.translate(dx, 0);
        width = (width - dx).clamp(widget.minWidth ?? 50.0, widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(widget.minWidth ?? 50.0, widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: widget.onTap, // ✅ Se detecta el clic aquí
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Center(child: Icon(Icons.image, size: 50)),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class ResizableStack extends StatefulWidget {
  final double width;
  final double height;
  final Offset position;
  final double borderRadius;
  final Function(double newWidth, double newHeight)? onResize;
  final double? maxWidth;
  final double minWidth; // Nuevo parámetro

  ResizableStack({
    Key? key,
    required this.width,
    required this.height,
    required this.position,
    this.borderRadius = 0.0,
    this.onResize,
    this.maxWidth,
    this.minWidth = 50.0, required void Function() onTap, // Valor por defecto
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
    width = widget.width;
    height = widget.height;
    position = widget.position;
  }

  @override
  void didUpdateWidget(covariant ResizableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.width != oldWidget.width ||
        widget.height != oldWidget.height ||
        widget.position != oldWidget.position) {
      setState(() {
        width = widget.width;
        height = widget.height;
        position = widget.position;
      });
    }
  }

  void _updateSize(double dx, double dy, {bool fromLeft = false}) {
    setState(() {
      if (fromLeft) {
        position = position.translate(dx, 0);
        width = (width - dx).clamp(widget.minWidth, widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(widget.minWidth, widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
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
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Center(child: Icon(Icons.image, size: 50)),
          ),
          _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)),
        ],
      ),
    );
  }
}

*/
/*
class ResizableStack extends StatefulWidget {
  final double width;
  final double height;
  final Offset position;
  final double borderRadius; // Nuevo parámetro
  final Function(double newWidth, double newHeight)? onResize;
  final double? maxWidth;

  ResizableStack({
    Key? key,
    required this.width,
    required this.height,
    required this.position,
    this.borderRadius = 0.0, // Valor por defecto
    this.onResize,
    this.maxWidth,
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
    width = widget.width;
    height = widget.height;
    position = widget.position;
  }

  @override
  void didUpdateWidget(covariant ResizableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.width != oldWidget.width ||
        widget.height != oldWidget.height ||
        widget.position != oldWidget.position) {
      setState(() {
        width = widget.width;
        height = widget.height;
        position = widget.position;
      });
    }
  }
  void _updateSize(double dx, double dy, {bool fromLeft = false}) {
    setState(() {
      if (fromLeft) {
        position = position.translate(dx, 0);
        width = (width - dx).clamp(50.0, widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(50.0, widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
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
              borderRadius: BorderRadius.circular(widget.borderRadius), // Aplicando el radio de borde
            ),
            child: Center(child: Icon(Icons.image, size: 50)),
          ),
          _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)),
        ],
      ),
    );
  }
}

*/


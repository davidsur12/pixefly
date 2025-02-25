import 'package:flutter/material.dart';

class ResizableStack extends StatefulWidget {
  final double initialWidth;
  final double initialHeight;
  final List<Widget> children;

  const ResizableStack({
    Key? key,
    this.initialWidth = 200,
    this.initialHeight = 200,
    required this.children,
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
    position = Offset(100, 100); // Posición inicial en la pantalla
  }

  void _updateSize(double dx, double dy, {bool fromLeft = false, bool fromTop = false}) {
    setState(() {
      if (fromLeft) {
        width -= dx;
        //calcular la posicion de widget esto deberia ir en una clase o un widget que mantenga la forma
        //para evitar cdigo rrepetido
       // position = position.translate(dx, 0);
      } else {
        width += dx;
      }

      if (fromTop) {
        height -= dy;
        //position = position.translate(0, dy);
      } else {
        height += dy;
      }

      // Límites del tamaño
      width = width.clamp(100.0, 500.0);
      height = height.clamp(100.0, 500.0);
    });
  }

  Widget _buildResizeHandle({required Alignment alignment, required Function(DragUpdateDetails) onDrag}) {
    return Positioned(
      left: alignment.x == -1 ? 0 : (alignment.x == 1 ? width - 15 : (width - 15) / 2),
      top: alignment.y == -1 ? 0 : (alignment.y == 1 ? height - 15 : (height - 15) / 2),
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
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Stack(children: widget.children),
          ),
          // Esquinas
        /*
          _buildResizeHandle(alignment: Alignment.topLeft, onDrag: (d) => _updateSize(d.delta.dx, d.delta.dy, fromLeft: true, fromTop: true)),
          _buildResizeHandle(alignment: Alignment.topRight, onDrag: (d) => _updateSize(d.delta.dx, d.delta.dy, fromTop: true)),
          _buildResizeHandle(alignment: Alignment.bottomLeft, onDrag: (d) => _updateSize(d.delta.dx, d.delta.dy, fromLeft: true)),
          _buildResizeHandle(alignment: Alignment.bottomRight, onDrag: (d) => _updateSize(d.delta.dx, d.delta.dy)),
          */

          // Bordes
          _buildResizeHandle(alignment: Alignment.centerLeft, onDrag: (d) => _updateSize(d.delta.dx, 0, fromLeft: true)),
          _buildResizeHandle(alignment: Alignment.centerRight, onDrag: (d) => _updateSize(d.delta.dx, 0)),
          _buildResizeHandle(alignment: Alignment.topCenter, onDrag: (d) => _updateSize(0, d.delta.dy, fromTop: true)),
          _buildResizeHandle(alignment: Alignment.bottomCenter, onDrag: (d) => _updateSize(0, d.delta.dy)),
        ],
      ),
    );
  }
}

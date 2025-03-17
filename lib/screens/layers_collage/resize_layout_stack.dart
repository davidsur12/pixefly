import 'dart:io';

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
  final File? image;


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
    this.image,
  }) : super(key: key);

  @override
  _ResizableStackState createState() => _ResizableStackState();
}


class _ResizableStackState extends State<ResizableStack> {
  late double width;
  late double height;
  late Offset position;
  bool isExpanded = false;
  Offset imagePosition = Offset.zero; // Nueva variable para la posición de la imagen
  bool isSelected = false; // ✅ Nuevo estado para controlar el borde

  void _toggleSelection() {
    setState(() {
      isSelected = !isSelected; // ✅ Alternar visibilidad del borde
    });
    widget.onTap?.call();
  }
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
        width = (width - dx).clamp(widget.minWidth!, widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(widget.minWidth!, widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
  }

  void onDoubleClick() {
    setState(() {
      isExpanded = !isExpanded;
      _centerImage();

    });
  }

  void _onDragImage(DragUpdateDetails details) {
    setState(() {
      double imageWidth = isExpanded ? width : width * 0.8; // Ajusta el tamaño de la imagen
      double imageHeight = isExpanded ? height : height * 0.8;

      double newX = (imagePosition.dx + details.delta.dx)
          .clamp(-imageWidth / 2, width - imageWidth / 2);
      double newY = (imagePosition.dy + details.delta.dy)
          .clamp(-imageHeight / 2, height - imageHeight / 2);

      imagePosition = Offset(newX, newY);
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
  Widget _buildImageWidget() {
    return Positioned(
      left: imagePosition.dx,
      top: imagePosition.dy,
      child: GestureDetector(
        onPanUpdate: _onDragImage, // Permite mover la imagen
        child: widget.image != null
            ? Image.file(
          widget.image!,
          width: width,
          height: height,
          fit: isExpanded ? BoxFit.contain : BoxFit.fill, // ✅ Cambia dinámicamente el ajuste
        )
            : Icon(Icons.image, size: 50),
      ),
    );
  }

  void _centerImage() {
    if (widget.image == null) return; // No hacer nada si no hay imagen

    if (isExpanded) { // Modo BoxFit.contain
      double imageWidth = width * 0.8;
      double imageHeight = height * 0.8;

      setState(() {
        imagePosition = Offset(
          (width - imageWidth) / 2,
          (height - imageHeight) / 2,
        );
      });
    } else { // Modo BoxFit.fill (se muestra normal)
      setState(() {
        imagePosition = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: _toggleSelection, // ✅ Cambiar selección al hacer clic
        onDoubleTap: onDoubleClick,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2) // ✅ Mostrar solo si está seleccionado
                    : null, // ❌ Sin borde cuando no está seleccionado
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Stack(
                children: [
                  _buildImageWidget(),
                ],
              ),
            ),
            if (isSelected) // ✅ Solo mostrar el resize handle si está seleccionado
              _buildResizeHandle(
                left: width - 10,
                top: height / 2 - 10,
                onDrag: (d) => _updateSize(d.delta.dx, 0),
              ),
          ],
        ),
      ),
    );
  }
}

  /*
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: onDoubleClick,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Stack(
                children: [
                  _buildImageWidget(), // Usa el widget _buildImageWidget
                ],
              ),
            ),
            _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)),
          ],
        ),
      ),
    );
  }
  */

  /*
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: onDoubleClick,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: imagePosition.dx,
                    top: imagePosition.dy,
                    child: GestureDetector(
                      onPanUpdate: _onDragImage, // Permite mover la imagen
                      child: widget.image != null
                          ? Image.file(
                        widget.image!,
                        width: width,
                        height: height,
                        fit: isExpanded ? BoxFit.cover : BoxFit.contain,
                      )
                          : Icon(Icons.image, size: 50),
                    ),
                  ),
                ],
              ),
            ),
            _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)),
          ],
        ),
      ),
    );
  }
  */


/*
class _ResizableStackState extends State<ResizableStack> {
  late double width;
  late double height;
  late Offset position;
  bool isExpanded = false;
  Offset imagePosition = Offset.zero; // Nueva variable para la posición de la imagen

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
        width = (width - dx).clamp(widget.minWidth!, widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(widget.minWidth!, widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
  }

  void onDoubleClick() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _onDragImage(DragUpdateDetails details) {
    setState(() {
      double imageWidth = isExpanded ? width : width * 0.8; // Ajusta el tamaño de la imagen
      double imageHeight = isExpanded ? height : height * 0.8;

      double newX = (imagePosition.dx + details.delta.dx)
          .clamp(-imageWidth / 2, width - imageWidth / 2);
      double newY = (imagePosition.dy + details.delta.dy)
          .clamp(-imageHeight / 2, height - imageHeight / 2);

      imagePosition = Offset(newX, newY);
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
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: onDoubleClick,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: imagePosition.dx,
                    top: imagePosition.dy,
                    child: GestureDetector(
                      onPanUpdate: _onDragImage, // Permite mover la imagen
                      child: widget.image != null
                          ? Image.file(
                        widget.image!,
                        width: width,
                        height: height,
                        fit: isExpanded ? BoxFit.cover : BoxFit.contain,
                      )
                          : Icon(Icons.image, size: 50),
                    ),
                  ),
                ],
              ),
            ),
            _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)),
          ],
        ),
      ),
    );
  }
}
*/

/*
class _ResizableStackState extends State<ResizableStack> {
  late double width;
  late double height;
  late Offset position;
  bool isExpanded = false;
  Offset imagePosition = Offset.zero; // Posición de la imagen

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
        width = (width - dx).clamp(widget.minWidth!, widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(widget.minWidth!, widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
  }

  void onDoubleClick() {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) {
        imagePosition = Offset.zero; // Reiniciar posición al cambiar de modo
      }
    });
  }

  // ✅ Mover la imagen dentro del contenedor sin salirse de los límites
  void _onDragImage(DragUpdateDetails details) {
    if (!isExpanded) return; // Solo permitir mover en modo expandido

    setState(() {
      double imageWidth = width;
      double imageHeight = height;

      double newX = (imagePosition.dx + details.delta.dx)
          .clamp(-imageWidth * 0.5, imageWidth * 0.5);
      double newY = (imagePosition.dy + details.delta.dy)
          .clamp(-imageHeight * 0.5, imageHeight * 0.5);

      imagePosition = Offset(newX, newY);
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
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: onDoubleClick,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: widget.image != null
                    ? GestureDetector(
                  onPanUpdate: _onDragImage, // ✅ Permite mover la imagen
                  child: Transform.translate(
                    offset: imagePosition,
                    child: Image.file(
                      widget.image!,
                      width: width * 1.2, // Ligeramente más grande para mover
                      height: height * 1.2,
                      fit: isExpanded ? BoxFit.cover : BoxFit.contain, // ✅ Ajuste dinámico
                    ),
                  ),
                )
                    : Icon(Icons.image, size: 50),
              ),
            ),
            _buildResizeHandle(
              left: width - 10,
              top: height / 2 - 10,
              onDrag: (d) => _updateSize(d.delta.dx, 0),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
class _ResizableStackState extends State<ResizableStack> {
  late double width;
  late double height;
  late Offset position;
  bool isExpanded = false;
  Offset imagePosition = Offset.zero; // Control de posición de la imagen

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
        width = (width - dx).clamp(widget.minWidth! , widget.maxWidth ?? double.infinity);
      } else {
        width = (width + dx).clamp(widget.minWidth! , widget.maxWidth ?? double.infinity);
      }
    });

    widget.onResize?.call(width, height);
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

  void onDoubleClick() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _onDragImage(DragUpdateDetails details) {
    setState(() {
      double newX = (imagePosition.dx + details.delta.dx)
          .clamp(-width / 2, width / 2);
      double newY = (imagePosition.dy + details.delta.dy)
          .clamp(-height / 2, height / 2);

      imagePosition = Offset(newX, newY);
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
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: onDoubleClick,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: _onDragImage, // Permite mover la imagen
                      child: widget.image != null
                          ? Image.file(
                        widget.image!,
                        width: width,
                        height: height,
                        fit: BoxFit.contain, // Ajuste corregido
                        alignment: Alignment.center,
                      )
                          : Icon(Icons.image, size: 50),
                    ),
                  ),
                ],
              ),
            ),
            _buildResizeHandle(left: width - 10, top: height / 2 - 10, onDrag: (d) => _updateSize(d.delta.dx, 0)),
          ],
        ),
      ),
    );
  }
}

*/






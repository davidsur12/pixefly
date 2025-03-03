import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/screens/layers_collage/screeen_capa_layout.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:provider/provider.dart';
import 'package:pixelfy/screens/layer/layer.dart';
import 'package:pixelfy/screens/layers_collage/resize_layout_stack.dart';

/***
 * editor principal donde podemos cambiar las opcines basicas del canvas
 */
class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  ImageEditorScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  double _lastWidth = 0;
  double _lastHeight = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final configLayout = context.watch<ConfigLayout>();
    final canvasSize = configLayout.ratio;

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_initialized) {
                _updateAspectRatioSize(context, constraints, canvasSize);
                setState(() {
                  _initialized = true;
                });
              }
            });

            return AspectRatio(
              aspectRatio: canvasSize.width / canvasSize.height,
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                    ...configLayout.layers.map((layer) {
                      return Positioned(
                        left: layer.dx,
                        top: layer.dy,
                        child: EditableLayer(
                          key: ValueKey(layer.id),
                          onDelete: configLayout.eliminarLayer,
                          layer: layer,
                          onUpdate: (updatedLayer) {
                            double maxWidth = _lastWidth;
                            double maxHeight = _lastHeight;
                            double clampedDx = updatedLayer.dx.clamp(0, maxWidth - updatedLayer.width);
                            double clampedDy = updatedLayer.dy.clamp(0, maxHeight - updatedLayer.height);

                            int index = configLayout.layers.indexWhere((l) => l.id == layer.id);
                            if (index != -1) {
                              configLayout.updateLayer(index, clampedDx, clampedDy, updatedLayer);
                            }
                          },
                          onSelect: _selectLayer,
                        ),
                      );
                    }).toList(),
                    _buildCornerDot(0, 0),
                    _buildCornerDot(1, 0),
                    _buildCornerDot(0, 1),
                    _buildCornerDot(1, 1),

                    // Posicionamiento correcto del icono después de obtener _lastWidth
                    if (_initialized)CapaLayoutCollage(width: _lastWidth, height: _lastHeight),


                    /*
                    if (_initialized) Positioned(
                      top: 20,
                      right: _lastWidth / 2,
                      child: Icon(
                        Icons.star,
                        size: 50,
                        color: Colors.amber,
                      ),
                    ),
            */
            /*
            ResizableHeart(
                      initialWidth: 200,
                      initialHeight: 200,
                      children: [
                        Center(
                          child: Text(
                            "❤️",
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ],
                    )
                    */
                    // ResizableStack con tamaño correcto después de inicialización
/*
                    if (_initialized) ResizableStack(
                      initialWidth: _lastWidth ,
                      initialHeight: _lastHeight,
                      children: [
                        Positioned(left: 50, top: 50, child: Icon(Icons.image, size: 50), ),
                      ],
                    ),
*/
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    final configLayout = context.watch<ConfigLayout>();
    final canvasSize = configLayout.ratio;

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateAspectRatioSize(context, constraints, canvasSize);
            });

            return AspectRatio(
              aspectRatio: canvasSize.width / canvasSize.height,
              child: Container(

                color: Colors.black,
                child: Stack(
                  children: [

                    Positioned.fill(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                    ...configLayout.layers.map((layer) {
                      return Positioned(
                        left: layer.dx,
                        top: layer.dy,
                        child: EditableLayer(
                          key: ValueKey(layer.id),
                          onDelete: configLayout.eliminarLayer,
                          layer: layer,
                          onUpdate: (updatedLayer) {
                            double maxWidth = _lastWidth;
                            double maxHeight = _lastHeight;
                            double clampedDx = updatedLayer.dx.clamp(0, maxWidth - updatedLayer.width);
                            double clampedDy = updatedLayer.dy.clamp(0, maxHeight - updatedLayer.height);

                            int index = configLayout.layers.indexWhere((l) => l.id == layer.id);
                            if (index != -1) {
                              configLayout.updateLayer(index, clampedDx, clampedDy, updatedLayer);
                            }
                          },
                          onSelect: _selectLayer,
                        ),
                      );
                    }).toList(),
                    _buildCornerDot(0, 0), // Esquina superior izquierda
                    _buildCornerDot(1, 0), // Esquina superior derecha
                    _buildCornerDot(0, 1), // Esquina inferior izquierda
                    _buildCornerDot(1, 1), // Esquina inferior
                    Positioned(
                      top: 20,  // Distancia desde arriba
                      right:  _lastWidth/2, // Distancia desde la derecha
                      child: Icon(
                        Icons.star,
                        size: 50,
                        color: Colors.amber,
                      ),
                    ),
                    ResizableStack(//corregir o consulytar el width correcto
                      initialWidth:  _lastWidth/2,//ancho inicioal
                        children: [
                          Positioned(left: 50, top: 50, child: Icon(Icons.image, size: 50), ),
                        ]),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  */
/*
  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double newWidth = constraints.maxWidth;
    double newHeight = constraints.maxWidth / (canvasSize.width / canvasSize.height);
    final configLayout = context.read<ConfigLayout>();

    // Si es la primera vez, solo actualizamos valores
    if (_lastWidth == 0 || _lastHeight == 0) {
      _lastWidth = newWidth;
      _lastHeight = newHeight;
      return;
    }

    double scaleX = newWidth / _lastWidth;
    double scaleY = newHeight / _lastHeight;

    // Obtener el centro del área de trabajo antes del cambio
    double centerXOld = _lastWidth / 2;
    double centerYOld = _lastHeight / 2;

    double centerXNew = newWidth / 2;
    double centerYNew = newHeight / 2;

    List<Layer> updatedLayers = configLayout.layers.map((layer) {
      // Obtener posición relativa respecto al centro
      double relativeDx = layer.dx - centerXOld;
      double relativeDy = layer.dy - centerYOld;

      // Escalar posición
      double newDx = centerXNew + (relativeDx * scaleX);
      double newDy = centerYNew + (relativeDy * scaleY);

      double newLayerWidth = layer.width * scaleX;
      double newLayerHeight = layer.height * scaleY;

      // Asegurar que el layer no se salga del área de trabajo
      newDx = newDx.clamp(0, newWidth - newLayerWidth);
      newDy = newDy.clamp(0, newHeight - newLayerHeight);

      return layer.copyWith(
        dx: newDx,
        dy: newDy,
        width: newLayerWidth,
        height: newLayerHeight,
      );
    }).toList();

    configLayout.setLayers(updatedLayers);

    _lastWidth = newWidth;
    _lastHeight = newHeight;
  }
*/

  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double availableWidth = constraints.maxWidth;
    double availableHeight = constraints.maxHeight;

    // Calcular el tamaño real del contenedor con AspectRatio
    double newWidth, newHeight;
    if (availableWidth / availableHeight > canvasSize.width / canvasSize.height) {
      // La altura es la restricción principal
      newHeight = availableHeight;
      newWidth = newHeight * (canvasSize.width / canvasSize.height);
    } else {
      // El ancho es la restricción principal
      newWidth = availableWidth;
      newHeight = newWidth / (canvasSize.width / canvasSize.height);
    }

    final configLayout = context.read<ConfigLayout>();

    if (_lastWidth > 0 && _lastHeight > 0) {
      double scaleX = newWidth / _lastWidth;
      double scaleY = newHeight / _lastHeight;

      List<Layer> updatedLayers = configLayout.layers.map((layer) {
        double newDx = layer.dx * scaleX;
        double newDy = layer.dy * scaleY;
        double newLayerWidth = layer.width * scaleX;
        double newLayerHeight = layer.height * scaleY;

        // Evitar que los elementos se desborden
        newDx = newDx.clamp(0, newWidth - newLayerWidth);
        newDy = newDy.clamp(0, newHeight - newLayerHeight);

        return layer.copyWith(
          dx: newDx,
          dy: newDy,
          width: newLayerWidth,
          height: newLayerHeight,
        );
      }).toList();

      configLayout.setLayers(updatedLayers);
    }

    // Actualizar valores solo si cambiaron
    if (_lastWidth != newWidth || _lastHeight != newHeight) {
      _lastWidth = newWidth;
      _lastHeight = newHeight;
    }
    print("el width actualizado es de $_lastWidth");
  }

/*
  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double newWidth = constraints.maxWidth;
    double newHeight = constraints.maxWidth / (canvasSize.width / canvasSize.height);
    final configLayout = context.read<ConfigLayout>();


    if (newWidth != _lastWidth || newHeight != _lastHeight) {
      double scaleX = newWidth / _lastWidth;
      double scaleY = newHeight / _lastHeight;

      List<Layer> updatedLayers = configLayout.layers.map((layer) {
        return layer.copyWith(
          dx: layer.dx * scaleX,
          dy: layer.dy * scaleY,
          width: layer.width * scaleX,
          height: layer.height * scaleY,
        );
      }).toList();
      print('nuevos valores: ${ context.read<ConfigLayout>().layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');

      configLayout.setLayers(updatedLayers);
      print("antiguo tamaño ancho: ${_lastWidth} y largo: ${_lastHeight}");
      print("nuevo tamaño ancho: ${newWidth} y largo: ${newHeight}");
      _lastWidth = newWidth;
      _lastHeight = newHeight;
    }
  }
*/

  void _selectLayer(String id) {
    final configLayout = context.read<ConfigLayout>();
    configLayout.setLayers(
      configLayout.layers.map((layer) {
        return layer.copyWith(isSelected: layer.id == id);
      }).toList(),
    );
  }

  /// Función para dibujar un punto en una de las esquinas
  Widget _buildCornerDot(double dx, double dy) {
    return Positioned(
      left: dx == 0 ? 0 : null, // Si dx == 0, posición a la izquierda
      right: dx == 1 ? 0 : null, // Si dx == 1, posición a la derecha
      top: dy == 0 ? 0 : null, // Si dy == 0, posición arriba
      bottom: dy == 1 ? 0 : null, // Si dy == 1, posición abajo
      child: Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.all(4), // Espaciado para que no quede pegado al borde
        decoration: BoxDecoration(
          color: Colors.red, // Color del punto
          shape: BoxShape.circle,
        ),
      ),
    );
  }

}



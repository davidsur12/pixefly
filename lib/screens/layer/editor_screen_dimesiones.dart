import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/screens/layers_collage/screeen_capa_layout.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:pixelfy/utils/size_ratio.dart';
import 'package:provider/provider.dart';
import 'package:pixelfy/screens/layer/layer.dart';


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
  void initState() {
    // TODO: implement initState
    super.initState();
    print("editor collge redibujado"
        "");
  }
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

                  //imagen de fondo

                  children: [
/*
                    Positioned.fill(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
*/
                  //los 4 puntos de refencia

                    _buildCornerDot(0, 0),
                    _buildCornerDot(1, 0),
                    _buildCornerDot(0, 1),
                    _buildCornerDot(1, 1),
                    //texto informativo

                    Text("el ancho es de ${_lastWidth}", style: TextStyle(color: Colors.green),),

                    // Posicionamiento correcto del icono después de obtener _lastWidth
                   // if (_initialized)CapaLayoutCollage(width: _lastWidth, height: _lastHeight),

                    //capa de cajas responsivas del diseño del layout
                    /*
                    aquie s deberia ir los layouts segun las imagenes y  el layout selecionado
                     */
                      CapaLayoutCollage(
                      //  key: ValueKey('$_lastWidth-$_lastHeight'), // Combinar ambos valores
                        key: ValueKey(_lastWidth), // Forzar reconstrucción cuando cambie el tamaño
                        width:  context.watch<SizeRatio>().width,
                        height:  context.watch<SizeRatio>().height,//_lastHeight,
                      ),

//estrella
                    Positioned(
                      top: 20,
                      left: 254,
                      //right: 0,//_lastWidth / 2,
                      child: Icon(
                        Icons.star,
                        size: 50,
                        color: Colors.amber,
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

  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double availableWidth = constraints.maxWidth;
    double availableHeight = constraints.maxHeight;
    final sizeProvider = Provider.of<SizeRatio>(context, listen: false);

    double newWidth, newHeight;
    if (availableWidth / availableHeight > canvasSize.width / canvasSize.height) {
      newHeight = availableHeight;
      newWidth = newHeight * (canvasSize.width / canvasSize.height);
    } else {
      newWidth = availableWidth;
      newHeight = newWidth / (canvasSize.width / canvasSize.height);
    }

    if (_lastWidth == newWidth && _lastHeight == newHeight) {
      return; // Evita actualizaciones innecesarias
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

    setState(() {
      _lastWidth = newWidth;
      _lastHeight = newHeight;
    });

    sizeProvider.cambioSize(_lastWidth, _lastHeight);
    print("el width actualizado es de $_lastWidth");
  }


/*
  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double availableWidth = constraints.maxWidth;
    double availableHeight = constraints.maxHeight;
    final sizeProvider = Provider.of<SizeRatio>(context, listen: false);


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
      sizeProvider.cambioSize(_lastWidth, _lastHeight );
    }
    print("el width actualizado es de $_lastWidth");
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



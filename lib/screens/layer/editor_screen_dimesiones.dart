import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:provider/provider.dart';
import 'package:pixelfy/screens/layer/layer.dart';


class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  ImageEditorScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  double _lastWidth = 0;
  double _lastHeight = 0;

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
                        left: 260.2779017857143,
                        top:  6.29464285714289,
                        child: Icon(Icons.abc_outlined, color: Colors.white,))
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
/*
class ImageEditorScreen extends StatefulWidget {
  final File imageFile;
  List<Layer> layers;

  ImageEditorScreen({Key? key, required this.imageFile, required this.layers})
      : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}


class _ImageEditorScreenState extends State<ImageEditorScreen> {
  double _lastWidth = 0;
  double _lastHeight = 0;


  @override
  Widget build(BuildContext context) {
    List<Layer> layers =  widget.layers; //[]; // 📌 Lista de capas
    final canvasSize = context.watch<ConfigLayout>().ratio;

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 📌 Verifica si el tamaño del área de trabajo ha cambiado
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateAspectRatioSize(context, constraints, canvasSize);
            });

            return AspectRatio(
              aspectRatio: canvasSize.width / canvasSize.height, // 📌 Cambia el ratio dinámicamente
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),  ...layers.map((layer) {
                      return Positioned(//se usa Positioned para cada elemento de la lista
                        left: layer.dx,
                        top: layer.dy,child: EditableLayer(

                        key: ValueKey(layer.id),
                        onDelete: _deleteLayer,
                        layer: layer,
                        onUpdate: (updatedLayer) {
                          setState(() {
                            double maxWidth = _lastWidth;   // Ancho del área de trabajo
                            double maxHeight = _lastHeight; // Alto del área de trabajo
                            double emojiWidth = updatedLayer.width;   // Ancho del emoji (ajusta según sea necesario)
                            double emojiHeight = updatedLayer.height; // Alto del emoji (ajusta según sea necesario)

                            // 📌 Asegurar que el emoji se mantenga dentro del área de trabajo
                            double clampedDx = updatedLayer.dx.clamp(0, maxWidth - emojiWidth);
                            double clampedDy = updatedLayer.dy.clamp(0, maxHeight - emojiHeight);

                            // 📌 Actualizar la posición restringida
                            int index = widget.layers.indexWhere((l) => l.id == layer.id);
                            if (index != -1) {
                              widget.layers[index] = updatedLayer.copyWith(dx: clampedDx, dy: clampedDy);
                            }
                          });
                        },
                        onSelect: _selectLayer,
                      ),

                      );
                    }).toList(),

                    // 📌 Puntos en las esquinas del AspectRatio
                    _buildCornerDot(0, 0), // Esquina superior izquierda
                    _buildCornerDot(1, 0), // Esquina superior derecha
                    _buildCornerDot(0, 1), // Esquina inferior izquierda
                    _buildCornerDot(1, 1), // Esquina inferior
                    ElevatedButton(onPressed: (){
                      print('📏 Antiguo tamaño consulta boton ($_lastWidth, $_lastHeight)');
                      // print('📌 Emojis reposicionados antiguas: ${context.watch<ConfigLayout>().layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');
                      print('📌 Emojis reposicionados antiguas: ${widget.layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');

                    }, child: Text("consulta de layers"))
                  ],
                ),
              ),
            );
          },
        ),
      ),
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

  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double newWidth = constraints.maxWidth;
    double newHeight = constraints.maxWidth / (canvasSize.width / canvasSize.height); // Ajustar altura con el nuevo ratio

    // Solo actualizar si el tamaño ha cambiado
    if (newWidth != _lastWidth || newHeight != _lastHeight) {
      double scaleX = newWidth / _lastWidth;
      double scaleY = newHeight / _lastHeight;

      setState(() {
        widget.layers = widget.layers.map((layer) {
          return layer.copyWith(
            dx: layer.dx * scaleX,
            dy: layer.dy * scaleY,
            width: layer.width * scaleX,
            height: layer.height * scaleY,
          );
        }).toList();

        _lastWidth = newWidth;
        _lastHeight = newHeight;
      });

      Offset position = (context.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;

      print(' AspectRatio actualizado:');
      print(' Posición (x, y): (${position.dx}, ${position.dy})');
      print(' Tamaño (width, height): ($_lastWidth, $_lastHeight)');
    }
  }

  void _selectLayer(String id) {
    setState(() {
      widget.layers = widget.layers.map((layer) {
        return layer.copyWith(isSelected: layer.id == id);
      }).toList();
    });
  }

  void _removeSelectedLayer() {
    setState(() {
      widget.layers.removeWhere((layer) => layer.isSelected);
    });
  }

  void _deleteLayer(String id) {
    setState(() {
      widget.layers = List.from(widget.layers)..removeWhere((layer) => layer.id == id);
    });
  }
}
*/

/*
class _ImageEditorScreenState extends State<ImageEditorScreen> {
  double _lastWidth = 0;
  double _lastHeight = 0;

  @override
  Widget build(BuildContext context) {
    List<Layer> layers = widget.layers; //[]; // 📌 Lista de capas
    final canvasSize = context.watch<ConfigLayout>().ratio;

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 📌 Verifica si el tamaño del área de trabajo ha cambiado
            WidgetsBinding.instance.addPostFrameCallback((_) {
              /*
              if (mounted) {
                setState(() {
                  _updateAspectRatioSize(context, constraints, canvasSize);
                });
              }
            */
              _updateAspectRatioSize(context, constraints, canvasSize);
            });

            return AspectRatio(
              aspectRatio: canvasSize.width / canvasSize.height,
              // 📌 Cambia el ratio dinámicamente
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
                    ...layers.map((layer) {
                      return Positioned(
                        //se usa Positioned para cada elemento de la lista
                        left: layer.dx,
                        top: layer.dy,
                        child: EditableLayer(
                          key: ValueKey('${layer.id}_${layer.dx}_${layer.dy}'), // Se actualiza cuando cambia la posición//ValueKey(layer.id),
                          onDelete: _deleteLayer,
                          layer: layer,
                          onUpdate: (updatedLayer) {
                            setState(() {


                              double maxWidth =
                                  _lastWidth; // Ancho del área de trabajo
                              double maxHeight =
                                  _lastHeight; // Alto del área de trabajo
                              double emojiWidth = updatedLayer
                                  .width; // Ancho del emoji (ajusta según sea necesario)
                              double emojiHeight = updatedLayer
                                  .height; // Alto del emoji (ajusta según sea necesario)

                              // 📌 Asegurar que el emoji se mantenga dentro del área de trabajo
                              double clampedDx = updatedLayer.dx
                                  .clamp(0, maxWidth - emojiWidth);
                              double clampedDy = updatedLayer.dy
                                  .clamp(0, maxHeight - emojiHeight);

                              // 📌 Actualizar la posición restringida
                              int index = widget.layers
                                  .indexWhere((l) => l.id == layer.id);
                              if (index != -1) {
                              //  context.read<ConfigLayout>().updateLayer(index, clampedDx, clampedDy, updatedLayer);

                                widget.layers[index] = updatedLayer.copyWith(
                                    dx: clampedDx, dy: clampedDy);

                              }
                            });
                          },
                          onSelect: _selectLayer,
                        ),

                        /*    child: EditableLayer(
                          key: ValueKey(layer.id),
                          onDelete: _deleteLayer,
                          layer: layer,
                          onUpdate: (updatedLayer) {
                            setState(() {
                              int index =
                              layers.indexWhere((l) => l.id == layer.id);
                              if (index != -1) {
                                layers[index] = updatedLayer;
                              }
                            });
                          },
                          onSelect: _selectLayer,
                        ),
                        */
                      );
                    }).toList(),

                    // 📌 Puntos en las esquinas del AspectRatio
                    _buildCornerDot(0, 0), // Esquina superior izquierda
                    _buildCornerDot(1, 0), // Esquina superior derecha
                    _buildCornerDot(0, 1), // Esquina inferior izquierda
                    _buildCornerDot(1, 1), // Esquina inferior derecha
                  ElevatedButton(onPressed: (){
                    print('📏 Antiguo tamaño consulta boton ($_lastWidth, $_lastHeight)');
                   // print('📌 Emojis reposicionados antiguas: ${context.watch<ConfigLayout>().layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');

                  }, child: Text("consulta de layers"))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Función para dibujar un punto en una de las esquinas
  Widget _buildCornerDot(double dx, double dy) {
    return Positioned(
      left: dx == 0 ? 0 : null,
      // Si dx == 0, posición a la izquierda
      right: dx == 1 ? 0 : null,
      // Si dx == 1, posición a la derecha
      top: dy == 0 ? 0 : null,
      // Si dy == 0, posición arriba
      bottom: dy == 1 ? 0 : null,
      // Si dy == 1, posición abajo
      child: Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.all(4),
        // Espaciado para que no quede pegado al borde
        decoration: BoxDecoration(
          color: Colors.red, // Color del punto
          shape: BoxShape.circle,
        ),
      ),
    );
  }



  void _updateAspectRatioSize(
      BuildContext context, BoxConstraints constraints, Size canvasSize){
    double newWidth = constraints.maxWidth;
    double newHeight = constraints.maxWidth / (canvasSize.width / canvasSize.height);

    if (newWidth != _lastWidth || newHeight != _lastHeight) {
      double widthRatio = newWidth / _lastWidth;
      double heightRatio = newHeight / _lastHeight;


      print('📏 Antiguo tamaño ($_lastWidth, $_lastHeight)');
    //  print('📌 Emojis reposicionados antiguas: ${context.watch<ConfigLayout>().layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');
/*
      List<Layer> listaLayers = Provider.of<ConfigLayout>(context, listen: false).layers;
      Provider.of<ConfigLayout>(context, listen: false).setLayers =
          listaLayers.map((layer) {
          // 📌 Guardar posición relativa antes del cambio
          print("______________________");

          double relativeDx = layer.dx / _lastWidth;
          double relativeDy = layer.dy / _lastHeight;
          print("posicion relativa antes del cambio  = $relativeDx y = $relativeDy ");

          // 📌 Recalcular la nueva posición proporcionalmente
          double newDx = relativeDx * newWidth;
          double newDy = relativeDy * newHeight;
          print("posicion relativa despues del cambio  = $newDx y = $newDy ");
          // 📌 Asegurar que los emojis no se salgan del área de trabajo
          newDx = newDx.clamp(0, newWidth - layer.width);
          newDy = newDy.clamp(0, newHeight - layer.height);
          print("posicion final del cambio  = $newDx y = $newDy ");
         // return layer.copyWith(dx: newDx, dy: newDy);
          return layer.copyWith(dx: 0, dy: 0);
        }).toList();
      */



      setState(() {

        _lastWidth = newWidth;
        _lastHeight = newHeight;
      });


      print('📏 Nuevo tamaño ($_lastWidth, $_lastHeight)');
      print('📌 Emojis reposicionados: ${widget.layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');
    //  print('📌 Emojis reposicionados: ${context.watch<ConfigLayout>().layers.map((e) => '(${e.dx}, ${e.dy})').toList()}');
    }
  }

  void _selectLayer(String id) {

    //context.read<ConfigLayout>().agregarLayer(id);//agrego el layer

    setState(() {

      widget.layers = widget.layers.map((layer) {
        return layer.copyWith(isSelected: layer.id == id);
      }).toList();
    });

  }

  void _removeSelectedLayer() {
    setState(() {
      widget.layers.removeWhere((layer) => layer.isSelected);
    });
  }

  void _deleteLayer(String id) {
    setState(() {
      widget.layers = List.from(widget.layers)
        ..removeWhere((layer) => layer.id == id);
    });
  }
}

*/
/*
class _ImageEditorScreenState extends State<ImageEditorScreen> {
  double _lastWidth = 0;
  double _lastHeight = 0;


  @override
  Widget build(BuildContext context) {
    List<Layer> layers =  widget.layers; //[]; // 📌 Lista de capas
    final canvasSize = context.watch<ConfigLayout>().ratio;

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 📌 Verifica si el tamaño del área de trabajo ha cambiado
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateAspectRatioSize(context, constraints, canvasSize);
            });

            return AspectRatio(
              aspectRatio: canvasSize.width / canvasSize.height, // 📌 Cambia el ratio dinámicamente
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),  ...layers.map((layer) {
                      return Positioned(//se usa Positioned para cada elemento de la lista
                        left: layer.dx,
                        top: layer.dy,child: EditableLayer(

                        key: ValueKey(layer.id),
                        onDelete: _deleteLayer,
                        layer: layer,
                        onUpdate: (updatedLayer) {
                          setState(() {
                            double maxWidth = _lastWidth;   // Ancho del área de trabajo
                            double maxHeight = _lastHeight; // Alto del área de trabajo
                            double emojiWidth = updatedLayer.width;   // Ancho del emoji (ajusta según sea necesario)
                            double emojiHeight = updatedLayer.height; // Alto del emoji (ajusta según sea necesario)

                            // 📌 Asegurar que el emoji se mantenga dentro del área de trabajo
                            double clampedDx = updatedLayer.dx.clamp(0, maxWidth - emojiWidth);
                            double clampedDy = updatedLayer.dy.clamp(0, maxHeight - emojiHeight);

                            // 📌 Actualizar la posición restringida
                            int index = widget.layers.indexWhere((l) => l.id == layer.id);
                            if (index != -1) {
                              widget.layers[index] = updatedLayer.copyWith(dx: clampedDx, dy: clampedDy);
                            }
                          });
                        },
                        onSelect: _selectLayer,
                      ),

                        /*    child: EditableLayer(
                          key: ValueKey(layer.id),
                          onDelete: _deleteLayer,
                          layer: layer,
                          onUpdate: (updatedLayer) {
                            setState(() {
                              int index =
                              layers.indexWhere((l) => l.id == layer.id);
                              if (index != -1) {
                                layers[index] = updatedLayer;
                              }
                            });
                          },
                          onSelect: _selectLayer,
                        ),
                        */
                      );
                    }).toList(),

                    // 📌 Puntos en las esquinas del AspectRatio
                    _buildCornerDot(0, 0), // Esquina superior izquierda
                    _buildCornerDot(1, 0), // Esquina superior derecha
                    _buildCornerDot(0, 1), // Esquina inferior izquierda
                    _buildCornerDot(1, 1), // Esquina inferior derecha
                  ],
                ),
              ),
            );
          },
        ),
      ),
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

  void _updateAspectRatioSize(BuildContext context, BoxConstraints constraints, Size canvasSize) {
    double newWidth = constraints.maxWidth;
    double newHeight = constraints.maxWidth / (canvasSize.width / canvasSize.height); // Ajustar altura con el nuevo ratio

    // Solo actualizar si el tamaño ha cambiado
    if (newWidth != _lastWidth || newHeight != _lastHeight) {
      _lastWidth = newWidth;
      _lastHeight = newHeight;

      Offset position = (context.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;

      print(' AspectRatio actualizado:');
      print(' Posición (x, y): (${position.dx}, ${position.dy})');
      print(' Tamaño (width, height): ($_lastWidth, $_lastHeight)');
    }
  }

  void _selectLayer(String id) {
    setState(() {
      widget.layers = widget.layers.map((layer) {
        return layer.copyWith(isSelected: layer.id == id);
      }).toList();
    });
  }

  void _removeSelectedLayer() {
    setState(() {
      widget.layers.removeWhere((layer) => layer.isSelected);
    });
  }

  void _deleteLayer(String id) {
    setState(() {
      widget.layers = List.from(widget.layers)..removeWhere((layer) => layer.id == id);
    });
  }
}

*/


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:provider/provider.dart';
import 'package:pixelfy/screens/layer/layer.dart';


class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  const ImageEditorScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  double _lastWidth = 0;
  double _lastHeight = 0;
  List<Layer> layers = []; // 📌 Lista de capas

  @override
  Widget build(BuildContext context) {
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
                    ),

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

      print('📍 AspectRatio actualizado:');
      print('🔹 Posición (x, y): (${position.dx}, ${position.dy})');
      print('📏 Tamaño (width, height): ($_lastWidth, $_lastHeight)');
    }
  }



  void _selectLayer(String id) {
    setState(() {
      layers = layers.map((layer) {
        return layer.copyWith(isSelected: layer.id == id);
      }).toList();
    });
  }

  void _removeSelectedLayer() {
    setState(() {
      layers.removeWhere((layer) => layer.isSelected);
    });
  }

  void _deleteLayer(String id) {
    setState(() {
      layers = List.from(layers)..removeWhere((layer) => layer.id == id);
    });
  }
}

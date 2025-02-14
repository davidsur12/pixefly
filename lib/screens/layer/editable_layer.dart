
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/layer.dart';

class EditableLayer extends StatefulWidget {
  final Layer layer;
  final Function(Layer) onUpdate;
  final Function(String) onDelete;

  final Function(String) onSelect; // ✅ Agregamos el parámetro

  const EditableLayer({
    Key? key,
    required this.layer,
    required this.onUpdate,
    required this.onDelete,
    required this.onSelect, // ✅ Asegurar que esté aquí
  }) : super(key: key);

  @override
  State<EditableLayer> createState() => _EditableLayerState();
}

class _EditableLayerState extends State<EditableLayer> {
  double _scale = 1.0; // Escala inicial
  double _previousScale = 1.0;
  Offset _position = Offset.zero; // Posición inicial

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.layer.dx, widget.layer.dy);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = _previousScale * details.scale; // Escalado
            _position += details.focalPointDelta; // Movimiento
          });

          // 🔹 Actualizar la capa en la lista principal
          widget.onUpdate(widget.layer.copyWith(
            dx: _position.dx,
            dy: _position.dy,
            size: _scale,
          ));
        },
        onTap: () {
          // 🔥 Al tocar, marcar la capa como seleccionada
         // widget.onUpdate(widget.layer.copyWith(isSelected: true));
          widget.onSelect(widget.layer.id); // ✅ Llamamos onSelect con el ID de la capa

        },
        onLongPress: () {
          // 🔥 Borrar capa al mantener presionado
          widget.onDelete(widget.layer.id);
        },
        child: Transform.scale(
          scale: _scale,
          child: Opacity(
            opacity: widget.layer.isSelected ? 0.7 : 1.0, // 🔵 Si está seleccionada, hacerla más opaca
            child: Text(
              widget.layer.content ?? "😀", // 🔹 Mostrar emoji
              style: TextStyle(fontSize: 50),
            ),
          ),
        ),
      ),
    );
  }
}

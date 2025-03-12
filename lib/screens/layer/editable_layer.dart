
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/layer.dart';

/*
class EditableLayer extends StatelessWidget {
  final Layer layer;
  final VoidCallback onDelete;
  final ValueChanged<String> onSelect; // <-- Asegurar que recibe un String
  final ValueChanged<Layer> onUpdate;

  const EditableLayer({
    Key? key,
    required this.layer,
    required this.onDelete,
    required this.onSelect,  // <-- Asegurar que es requerido
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('🟡 Emoji tocado: ${layer.id}');
        onSelect(layer.id); // <-- Llamar correctamente onSelect con el ID
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: layer.isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Text(layer.content ?? "nada", style: TextStyle(fontSize: layer.size)),
      ),
    );
  }
}

*/

class EditableLayer extends StatefulWidget {
  final Layer layer;
  final Function(Layer) onUpdate;
  final Function(String) onDelete;
  final Function(String) onSelect; // ✅

  const EditableLayer({
    Key? key,
    required this.layer,
    required this.onUpdate,
    required this.onDelete,
    required this.onSelect, // ✅
  }) : super(key: key);

  @override
  State<EditableLayer> createState() => _EditableLayerState();
}

class _EditableLayerState extends State<EditableLayer> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.layer.dx, widget.layer.dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = _previousScale * details.scale; // Escalar emoji
          _position += details.focalPointDelta; // Mover emoji
        });

        // 🔹 Actualizar la capa en la lista principal
        widget.onUpdate(widget.layer.copyWith(
          dx: _position.dx,
          dy: _position.dy,
          size: _scale,
        ));
      },
      onTap: () {
        widget.onSelect(widget.layer.id);
      },
      onLongPress: () {
        widget.onDelete(widget.layer.id);
      },
      child: Transform.scale(
        scale: _scale,
        child: Opacity(
          opacity: 1.0,//widget.layer.isSelected ? 0.5 : 1.0,
          child: Text(
            widget.layer.content ?? "😀",
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }
}



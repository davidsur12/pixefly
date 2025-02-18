
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/layer.dart';
import 'package:pixelfy/screens/widgets/widget_ratio.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          opacity: widget.layer.isSelected ? 0.7 : 1.0,
          child: Text(
            widget.layer.content ?? "😀",
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }
}


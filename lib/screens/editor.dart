import 'package:flutter/material.dart';
import 'package:pixelfy/main.dart';
import 'dart:io';
import 'package:pixelfy/screens/layer/layer.dart';
import 'package:pixelfy/screens/layer/editable_layer.dart';
import 'package:pixelfy/screens/widgets/widget_ratio.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:uuid/uuid.dart'; // 📌 Para generar IDs únicos
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  final File imageFile;

  const EditorScreen({super.key, required this.imageFile});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  List<Layer> layers = []; // 📌 Lista de capas
  final uuid = Uuid(); // 📌 Generador de IDs únicos
  Size? _canvasSize; //dimencion ratio selecionado


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
      layers = List.from(layers)
        ..removeWhere((layer) => layer.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño desde el Provider
    final canvasSize = context
        .watch<ConfigLayout>()
        .ratio;

    return Scaffold(
        appBar: AppBar(title: Text("Editor de Imágenes")),
        body: Center( // 📌 Centrar todo el área de trabajo
            child:
            AspectRatio(
              aspectRatio: canvasSize.width / canvasSize.height,
              child: Container(
                color: Colors.black,
                // 📌 Color para visualizar los límites del área de trabajo

                child:
                SizedBox.expand(
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
    left: layer.dx,
    top: layer.dy,
    child: EditableLayer(
    key: ValueKey(layer.id),
    onDelete: _deleteLayer,
    layer: layer,
    onUpdate: (updatedLayer) {
    setState(() {
    int index = layers.indexWhere((l) => l.id == layer.id);
    if (index != -1) {
    layers[index] = updatedLayer;
    }
    });
    },
    onSelect: _selectLayer,
    ),
    );
    }).toList(),
    ],
    ),
    ),


    ),
    ),
    ),
    bottomNavigationBar: _buildBottomMenu(),
    floatingActionButton: FloatingActionButton(
    onPressed: _removeSelectedLayer,
    child: Icon(Icons.delete),
    ),
    );
    }


  Widget _buildBottomMenu() {
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /*
          _menuButton(Icons.aspect_ratio, "Ratio", () {
            _showRatioPicker();
          }),*/
          WidgetRatio(),

          _menuButton(Icons.text_fields, "Texto", () {}),
          _menuButton(Icons.brush, "Dibujar", () {}),
          _menuButton(Icons.emoji_emotions, "Emojis", () {
            _showEmojiPicker(); // Abrimos la ventana de emojis
          }),
          _menuButton(Icons.image, "Imágenes", () {}),
        ],
      ),
    );
  }

  Widget _menuButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _emojiPicker();
      },
    );
  }

  Widget _emojiPicker() {
    List<String> emojis = ["😀", "😂", "😍", "😎", "🔥", "💀", "🎃", "👻"];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _addEmoji(emojis[index]); // Agrega el emoji y cierra la ventana
              Navigator.pop(context); //cierro el bottonshet
            },
            child: Center(
              child: Text(
                emojis[index],
                style: TextStyle(fontSize: 40),
              ),
            ),
          );
        },
      ),
    );
  }



  void _addEmoji(String emoji) {
    setState(() {
      layers.add(
        Layer(
          id: uuid.v4(), // Genera un ID único
          type: "emoji",
          content: emoji,
          dx: 150, // Posición inicial centrada en X
          dy: 250, // Posición inicial centrada en Y
          size: 50,
        ),
      );
    });
  }


}



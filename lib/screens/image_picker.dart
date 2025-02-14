import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelfy/screens/editor.dart';
import 'package:pixelfy/utils/cadenas.dart';

class ImagePickerImage extends StatefulWidget {
  const ImagePickerImage({super.key});

  @override
  State<ImagePickerImage> createState() => _ImagePickerImageState();
}

class _ImagePickerImageState extends State<ImagePickerImage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Cadenas.get("app_name")),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Icon(Icons.abc_outlined)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // 🔵 Bordes redondeados
                ),
                minimumSize: Size(150, 50),
                // 📏 Tamaño fijo: ancho 150, alto 50
                backgroundColor: Colors.blue,
                // 🎨 Color de fondo
                foregroundColor: Colors.white,
                // 🎨 Color del texto/icono
                elevation: 5, // 🏔️ Sombra para darle efecto elevado
              ),
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
              child: Text("Selecionar Imagenes"))
        ],
      ),
    );
  }

  // 📷 Método para seleccionar imagen de la galería o la cámara
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditorScreen(imageFile: File(pickedFile.path)),
        ),
      );
    }
  }

}

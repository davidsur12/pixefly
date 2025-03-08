import 'dart:io';

import 'package:flutter/material.dart';



import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';


class ImagePickerImage extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerImage> {
  static const platform = MethodChannel("com.pixelfy.image_picker");
  List<String> _directories = [];
  String? _selectedDirectory;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }
  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted ||
        await Permission.photos.request().isGranted) {
      _loadDirectories();
    } else {
      print("❌ Permiso denegado. No se puede acceder a las imágenes.");
      openAppSettings(); // Abre la configuración si el usuario niega el permiso
    }
  }

  Future<void> _loadDirectories() async {
    try {
      final List<dynamic> result = await platform.invokeMethod("getImageFolders");
      print("Carpetas detectadas: $result"); // <-- Agregar este print para depuración
      setState(() {
        _directories = result.cast<String>();
        _selectedDirectory = _directories.isNotEmpty ? _directories[0] : null;
        _loadImages();
      });
    } on PlatformException catch (e) {
      print("Error al obtener carpetas: ${e.message}");
    }
  }

  Future<void> _loadImages() async {
    if (_selectedDirectory == null) return;

    List<File> images = [];
    List<FileSystemEntity> files = Directory(_selectedDirectory!).listSync();

    for (var file in files) {
      if (file is File && _isImageFile(file.path)) {
        images.add(file);
      }
    }

    setState(() {
      _images = images;
    });
  }

  bool _isImageFile(String path) {
    return path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png');
  }

  Future<void> _loadRecentImages() async {
    List<File> allImages = [];

    for (String dirPath in _directories) {
      Directory dir = Directory(dirPath); // Convertir String en Directory
      if (!dir.existsSync()) continue; // Evitar errores si el directorio no existe

      List<FileSystemEntity> files = dir.listSync();
      for (var file in files) {
        if (file is File && _isImageFile(file.path)) {
          allImages.add(file);
        }
      }
    }

    // Ordenar por fecha de modificación (más recientes primero)
    allImages.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    // Tomar solo las últimas 50 imágenes
    setState(() {
      _images = allImages.take(50).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleccionar Imagen")),
      body: Column(
        children: [
          // Dropdown para seleccionar carpeta
          if (_directories.isNotEmpty)
            DropdownButton<String>(
              value: _selectedDirectory,
              items: _directories.map((dir) {
                return DropdownMenuItem(
                  value: dir,
                  child: Text(dir.split('/').last), // Muestra solo el nombre de la carpeta
                );
              }).toList(),
              onChanged: (newDir) {
                setState(() {
                  _selectedDirectory = newDir;
                  _loadImages();
                });
              },
            ),

          // Mostrar imágenes
          Expanded(
            child: _images.isEmpty
                ? Center(child: Text("No hay imágenes en esta carpeta"))
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print("Imagen seleccionada: ${_images[index].path}");
                  },
                  child: Image.file(
                    _images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



/*
class ImagePickerImage extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerImage> {
  List<Directory> _directories = [];
  Directory? _selectedDirectory;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    List<Directory> dirs = await getImageDirectories();
    setState(() {
      _directories = dirs;
      _selectedDirectory = dirs.isNotEmpty ? dirs[0] : null;
      _loadImages();
    });
  }

  Future<void> _loadImages() async {
    if (_selectedDirectory == null) return;

    List<File> images = [];
    List<FileSystemEntity> files = _selectedDirectory!.listSync();

    for (var file in files) {
      if (file is File && _isImageFile(file.path)) {
        images.add(file);
      }
    }

    setState(() {
      _images = images;
    });
  }

  bool _isImageFile(String path) {
    return path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleccionar Imagen")),
      body: Column(
        children: [
          // Dropdown para seleccionar carpeta
          DropdownButton<Directory>(
            value: _selectedDirectory,
            items: _directories.map((dir) {
              return DropdownMenuItem(
                value: dir,
                child: Text(dir.path.split('/').last), // Muestra solo el nombre de la carpeta
              );
            }).toList(),
            onChanged: (newDir) {
              setState(() {
                _selectedDirectory = newDir;
                _loadImages();
              });
            },
          ),

          // Mostrar imágenes
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Aquí puedes manejar la selección de la imagen
                    print("Imagen seleccionada: ${_images[index].path}");
                  },
                  child: Image.file(
                    _images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Directory>> getImageDirectories() async {
    Directory storageDir = Directory('/storage/emulated/0/');
    List<String> folders = [
      'DCIM',
      'Download',
      'Pictures',
      'Screenshots',
      'WhatsApp/Media/WhatsApp Images',
    ];

    List<Directory> directories = [];
    for (String folder in folders) {
      Directory dir = Directory('${storageDir.path}$folder');
      if (await dir.exists()) {
        directories.add(dir);
      }
    }
    return directories;
  }
}
*/



/*
class ImagePickerImage extends StatefulWidget {
  const ImagePickerImage({super.key});

  @override
  State<ImagePickerImage> createState() => _ImagePickerImageState();
}

class _ImagePickerImageState extends State<ImagePickerImage> {
  List<File> _images = []; // Lista para almacenar múltiples imágenes
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Imágenes"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.blue)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size(180, 50),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 5,
            ),
            onPressed: _pickImages, // Llamamos a la función para seleccionar imágenes
            child: Text("Seleccionar Imágenes"),
          ),
          const SizedBox(height: 20),
          // Vista previa de imágenes en una lista horizontal
          _images.isNotEmpty
              ? SizedBox(
            height: 100, // Altura del área de vista previa
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Desplazamiento horizontal
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        child: Image.file(
                          _images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index); // Eliminar imagen de la lista
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
              : Text("No hay imágenes seleccionadas", style: TextStyle(color: Colors.grey)),
        ],
      ),
      floatingActionButton: _images.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
       /*   Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorScreen(images: _images),
            ),
          );*/
        },
        label: Text("Editar imágenes"),
        icon: Icon(Icons.edit),
      )
          : null,
    );
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }
}

*/
/*
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
*/


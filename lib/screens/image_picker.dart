import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixelfy/screens/editor.dart';
import 'package:pixelfy/utils/cadenas.dart';
import 'package:pixelfy/utils/images_seleccionadas.dart';
import 'package:pixelfy/utils/toast_personalisados.dart';
import 'package:provider/provider.dart';


/****
 * Esta clase es un image picker personalisado que tiene las siguientes funciones
 * -) seleciona multiples images hasta  20 imagenes como maxino
 * -) agrega las magenes a una lista que sepuede visualisar  en la parte de abajo
 * -) puede eliminar una por una de las imagenes selcionadas o todas con el boton eliminar
 * -) entrega las imagenes selcionadas en una lista  List<File> _selectedImages
 *  -) al selecionar las imagenes en el  boton siguiente se se dirigue a la pantalla
 * EditorScreen que es eleditor de collaguecon las imagenes seleiconadas
 */

class ImagePickerImage extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerImage> {
  static const platform = MethodChannel("com.pixelfy.image_picker");
  List<String> _directories = [];
  String? _selectedDirectory;
  List<File> _images = [];
  List<File> _selectedImages = []; // Lista de imágenes seleccionadas

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    //pide y verifica permisos para poder acceder al almacenamiento del telefono
    if (await Permission.storage.request().isGranted ||
        await Permission.photos.request().isGranted) {
      _loadDirectories();
    } else {
      print("Permiso denegado. No se puede acceder a las imágenes.");
      openAppSettings();
    }
  }

  Future<void> _loadDirectories() async {
    //carga o detecta los directorios que contienen imagenes o fotos
    try {
      final List<dynamic> result =
          await platform.invokeMethod("getImageFolders");
      print("Carpetas detectadas: $result");

      setState(() {
        _directories = ["Recientes", ...result.cast<String>(), "Otro"];
        _selectedDirectory = "Recientes";
        _loadImages();
      });
    } on PlatformException catch (e) {
      print("Error al obtener carpetas: ${e.message}");
    }
  }

  Future<void> _openFileExplorer() async {
    String? selectedPath = await FilePicker.platform.getDirectoryPath();

    if (selectedPath != null) {
      setState(() {
        _selectedDirectory = selectedPath;
        _loadImages();
      });
    } else {
      setState(() {
        _selectedDirectory = "Recientes";
        _loadImages();
      });
    }
  }

  Future<void> _loadImages() async {
    if (_selectedDirectory == "Recientes") {
      _loadRecentImages();
      return;
    }

    if (_selectedDirectory == null || _selectedDirectory == "Otro") return;

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
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png');
  }

  Future<void> _loadRecentImages() async {
    List<File> allImages = [];

    for (String dirPath
        in _directories.where((dir) => dir != "Recientes" && dir != "Otro")) {
      Directory dir = Directory(dirPath);
      if (!dir.existsSync()) continue;

      List<FileSystemEntity> files = dir.listSync();
      for (var file in files) {
        if (file is File && _isImageFile(file.path)) {
          allImages.add(file);
        }
      }
    }

    allImages
        .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      _images = allImages.take(50).toList();
    });
  }

  void _selectImage(File image) {
    if (_selectedImages.length >= 20) {
      Fluttertoast.showToast(
        msg: Cadenas.get("limite"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _selectedImages.add(image);
    });
  }

  int _getImageCount(File image) {
    return _selectedImages.where((img) => img.path == image.path).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Color(0xFF13293e),
        iconTheme: IconThemeData(
          color: Colors.white, // Color del botón de retroceso
        ),
        title: Row(
        //  mainAxisAlignment: MainAxisAlignment.center,
          children: [
           // Icon(Icons.image, color: Colors.white),

            Text(Cadenas.get("app_name"), style: TextStyle(color: Colors.white) ,),
          ],
        ),
        /*
          flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

       */
       // centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                print("presionado");
                if(_selectedImages.isNotEmpty){
                  //si se han selecionado imagenes
                  Provider.of<ImagesSeleccionadas>(context, listen: false).imagenesSelecionadas(_selectedImages);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditorScreen(imageFile:  _selectedImages)),
                  );
                }
                else{
                  /*
                   si el ususario no a elecionado imagenes  muestr un toast
                  para que seleciona algunas imagenes
                  */
                  ToastPersonalisado.showToasSimple(context, Cadenas.get("imagenes_no_selecionadas"));

                }
                // Navegar a otra pantalla
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditorScreen(imageFile: imageFile)),
                )
                    */
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados
                ),
                backgroundColor: Color(0xFFf66b0e), // Color del botón
                foregroundColor: Colors.white, // Color del texto/icono
              ),
              child: Text(Cadenas.get("siguiente"), style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      )
,

        body: Column(
        children: [
          // Dropdown estilizado
          if (_directories.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF13293e), width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDirectory,
                    isExpanded: true,
                    icon: Icon(Icons.folder_open, color: Color(0xFF13293e)),
                    //menu desplegable con todas los directorios encontrados
                    items: _directories.map((dir) {
                      return DropdownMenuItem(
                        value: dir,
                        child: Text(
                          dir == Cadenas.get("recientes")
                              ? Cadenas.get("recientes")
                              : dir == Cadenas.get("otro")
                                  ? Cadenas.get("otro")
                                  : dir.split('/').last,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),

                    onChanged: (newDir) {
                      if (newDir == Cadenas.get("otro")) {
                        _openFileExplorer();
                      } else {
                        setState(() {
                          _selectedDirectory = newDir;
                          _loadImages();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

          // Galería de imágenes
          Expanded(
            child: _images.isEmpty
                ? Center(
                    child: Text(Cadenas.get("sin_imagenes"),
                        style: TextStyle(fontSize: 18, color: Colors.grey)))
                : GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final image = _images[index];
                      final count = _getImageCount(image);

                      return GestureDetector(
                        onTap: () => _selectImage(image),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                            ),
                            if (count > 0)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: CircleAvatar(
                                  backgroundColor:Color(0xFFf66b0e),
                                  radius: 14,
                                  child: Text(
                                    "$count",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Contador de imágenes seleccionadas con botón de eliminar
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Color(0xFF13293e)),
                        SizedBox(width: 8),
                        Text(
                          "Imágenes: ${_selectedImages.length}/20",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF13293e)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmationDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF13293e),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: Icon(Icons.delete, color: Colors.white),
                    label:
                        Text(Cadenas.get("eliminar"), style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

          // Lista de imágenes seleccionadas
          if (_selectedImages.isNotEmpty)
            Container(
              height: 110,
              padding: EdgeInsets.symmetric(vertical: 5),
              color: Colors.grey[200],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImages[index],
                              width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 14,
                            child: Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                Cadenas.get("no_seleccion"),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

// Diálogo de confirmación con mejor diseño
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(Cadenas.get("confirmacion")),
            ],
          ),
          content: Text(Cadenas.get("eliminar_imagenes"),
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text(Cadenas.get("cancelar"), style: TextStyle(color: Colors.grey[800])),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(Cadenas.get("eliminar"), style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

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


import 'dart:io';

import 'package:flutter/material.dart';

class ImagesSeleccionadas extends ChangeNotifier {

  List<File> _selectedImages=[];
  List<File> get selectedImages => _selectedImages;

  void imagenesSelecionadas (List<File> selectedImages){
    _selectedImages = selectedImages;
    print("las nuevas imagenes son $_selectedImages");
    notifyListeners();
  }


}

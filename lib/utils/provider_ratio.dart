
import 'package:flutter/material.dart';
import 'package:pixelfy/screens/layer/layer.dart';
import 'package:uuid/uuid.dart'; // 📌 Para generar IDs únicos



class ConfigLayout with ChangeNotifier {
  Size? _ratio = Size(1, 1);
  List<Layer> _layers = [];
  final uuid = Uuid();

  Size get ratio => _ratio ?? Size(1, 1);
  List<Layer> get layers => _layers;

  void setLayers(List<Layer> layers) {
    _layers = layers;
    notifyListeners();
  }

  void cambioRatio(Size ratio) {
    _ratio = ratio;
    notifyListeners();
  }

  void agregarLayer(String emoji) {
    _layers.add(
      Layer(
        id: uuid.v4(),
        type: "emoji",
        content: emoji,
        dx: 150,
        dy: 250,
        size: 50,
        width: 50,
        height: 50,
      ),
    );
    notifyListeners();
  }

  void eliminarLayer(String id) {
    _layers.removeWhere((layer) => layer.id == id);
    notifyListeners();
  }

  void updateLayer(int index, double clampedDx, double clampedDy, Layer updatedLayer) {
    _layers[index] = updatedLayer.copyWith(dx: clampedDx, dy: clampedDy);
    notifyListeners();
  }
}

/*
class ConfigLayout with ChangeNotifier {
  Size? _ratio = Size(1, 1);
  List<Layer> _layers = [];
  final uuid = Uuid();


  Size get ratio => _ratio ?? Size(1, 1);
  List<Layer> get layers => _layers ;
  set setLayers(List<Layer> layers){

    _layers = layers;
    notifyListeners();
  }

  void cambioRatio(Size ratio) {
    print("El ratio es de $ratio");
    _ratio = ratio;
    notifyListeners();
  }

  void agregarLayer(String emoji){

    //aqui solo agrega emojis mas adelante debe soprtar mas tipos de elementos
    _layers.add(
      Layer(
        id: uuid.v4(),
        // Genera un ID único
        type: "emoji",
        content: emoji,
        dx: 150,
        // Posición inicial centrada en X
        dy: 250,
        // Posición inicial centrada en Y
        size: 50,
        width: 50,   // ✅ Agregar width
        height: 50,
      ),
    );
    notifyListeners();

  }
  void eliminarLayer(String id) {

      _layers = List.from(layers)..removeWhere((layer) => layer.id == id);
      notifyListeners();
  }
  void updateLayer(int index, double clampedDx, double clampedDy, Layer updatedLayer){

    _layers[index] = updatedLayer.copyWith(
        dx: clampedDx, dy: clampedDy);
  }


}
*/
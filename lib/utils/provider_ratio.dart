
import 'package:flutter/material.dart';
class ConfigLayout with ChangeNotifier {
  Size? _ratio = Size(1, 1);

  Size get ratio => _ratio ?? Size(1, 1);

  void cambioRatio(Size ratio) {
    print("El ratio es de $ratio");
    _ratio = ratio;
    notifyListeners();
  }

}
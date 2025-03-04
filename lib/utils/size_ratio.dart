import 'package:flutter/material.dart';

class SizeRatio extends ChangeNotifier {
  double _width = 0;
  double _height = 0;

  double get width => _width;

  double get height => _height;

  void cambioSize(double width, double height) {
    _width = width;
    _height = height;
    print("valores cambiados width: $_width  height: $_height ");
    notifyListeners();
  }
}

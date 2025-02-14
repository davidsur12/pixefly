import 'dart:convert';
import 'package:flutter/services.dart';

class Cadenas {
  static Map<String, String>? _localizedStrings;

  static Future<void> loadStrings() async {
    final String jsonString = await rootBundle.loadString('assets/strings/strings.json');
    _localizedStrings = Map<String, String>.from(json.decode(jsonString));
  }

  static String get(String key) {
    return _localizedStrings?[key] ?? 'Texto no encontrado';
  }

  Future<Map<String, dynamic>> cargarStringsJson() async {
    String jsonString = await rootBundle.loadString('assets/strings/strings.json');
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data;
  }



}

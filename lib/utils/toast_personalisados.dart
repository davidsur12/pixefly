
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastPersonalisado{

static void showToasSimple(BuildContext context, String msg) {
Fluttertoast.showToast(
msg: msg,
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.BOTTOM, // Ubicación: BOTTOM, CENTER, TOP
backgroundColor: Colors.black54,
textColor: Colors.white,
fontSize: 16.0,
);
}
}




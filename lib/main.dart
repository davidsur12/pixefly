import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixelfy/blocs/image_cubit_backgraund.dart';
import 'package:pixelfy/cloud/appwrite_recursos.dart';
import 'package:pixelfy/screens/editor.dart';
import 'package:pixelfy/screens/home/screeen_home.dart';
import 'package:pixelfy/screens/image_picker.dart';
import 'package:pixelfy/utils/cadenas.dart';
import 'package:pixelfy/utils/images_seleccionadas.dart';

import 'package:provider/provider.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:pixelfy/utils/size_ratio.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para usar funciones async antes de runApp

   AppWrite.InstanciaAppWrite;//instacio AppWrite

  await iniciarAplicacion(); // Tu función async

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Cadenas.loadStrings();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigLayout()),
          ChangeNotifierProvider(create: (_) => SizeRatio()),
          ChangeNotifierProvider(create: (_) => ImagesSeleccionadas()),
        ],
        child: const MyApp(),
      )
    );
}
Future<void> iniciarAplicacion() async {
  /*
  esta funcion va adescargar el archivos
   */
  // Aquí va tu lógica, por ejemplo:
  print("Inicializando la app...");
  await Future.delayed(Duration(seconds: 2)); // Simula algo como cargar datos
  print("Aplicación inicializada.");
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(create: (_)=> ImagesCubitBackgraund() ,child: ScreenHome(),) //ScreenHome(),//ImagePickerImage() //Editor()//const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pixelfy/utils/toast_personalisados.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';


void conecionInternet(Future<void> Function() funcion, Function() error) {
  print("comprobando conecion 2 ");
  final listener =
      InternetConnection().onStatusChange.listen((InternetStatus status) {
    switch (status) {
      case InternetStatus.connected:
        // The internet is now connected
      print("si hay internet");
        funcion();
        break;
      case InternetStatus.disconnected:
        // The internet is now disconnected
      print("No hay internet");
      error();


        break;
    }
  });
}

void conecionInternet2(Future<void> Function() funcion, Function onError) async {
  bool isConnected = await InternetConnection().hasInternetAccess; // 🔍 Verifica conexión actual

  if (isConnected) {
    await funcion();
  } else {
    onError();
  }

  // Luego, sigue escuchando cambios de estado en la conexión
  InternetConnection().onStatusChange.listen((InternetStatus status) async {
    if (status == InternetStatus.connected) {
      await funcion();
    } else {
      onError();
    }
  });
}

void conecionInternet3(Future<void> Function() funcion, Function onError) async {
  bool isConnected = await InternetConnection().hasInternetAccess;

  // 🔍 Verificación adicional con una petición real a Google
  if (isConnected) {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        await funcion(); // ✅ Solo se ejecuta si hay realmente internet
        return;
      }
    } catch (e) {
      // Si hay un error en la petición, tratamos como si no hubiera conexión
    }
  }

  onError(); // ❌ Solo llega aquí si no hay internet real
}

void conecionInternet4(Future<void> Function() funcion, Function onError) async {
  print("Comprobando conexion a internet");
  bool isConnected = await InternetConnection().hasInternetAccess;


  // 🔍 Verificación adicional con una petición real a Google
  if (isConnected) {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        await funcion(); // ✅ Solo se ejecuta si hay realmente internet
        return;
      }
    } catch (e) {
      // Si hay un error en la petición, tratamos como si no hubiera conexión
      isConnected = false;
    }
  }

  if (!isConnected) {
    onError(); // ❌ Solo llega aquí si realmente no hay internet
  }

  // 🛠️ Escuchar cambios en la conexión a internet
  InternetConnection().onStatusChange.listen((InternetStatus status) async {
    if (status == InternetStatus.connected) {
      await funcion();
    } else if (status == InternetStatus.disconnected) {
      onError(); // ❌ Se ejecuta solo si cambia a "sin conexión"
    }
  });
}

// images_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class ImagesCubitBackgraund extends Cubit<int> {
  ImagesCubitBackgraund() : super(0);

  void notificarCambio() {
    emit(state + 1); // Cambia el estado
  }
}

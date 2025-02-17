// 📌 Clase para representar una capa
class Layer {
  final String id;
  final String type;
  final String? content;
  final double dx, dy, size;//pocicion y tamaño
   bool isSelected;//si esta selecionado

  //constructor
  Layer({

    required this.id,
    required this.type,
    this.content,
    required this.dx,
    required this.dy,
    required this.size,
    this.isSelected = false,
  });

  //  Método copyWith para actualizar solo los valores necesarios
  Layer copyWith({
    String? id,
    String? type,
    String? content,
    double? dx,
    double? dy,
    double? size,
    bool? isSelected,
  }) {
    print("valores actualizados");
    return Layer(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

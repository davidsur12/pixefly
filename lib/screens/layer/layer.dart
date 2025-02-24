// 📌 Clase para representar una capa
class Layer {
  final String id;
  final String type;
  final String? content;
  final double dx, dy, size;//pocicion y tamaño
   bool isSelected;//si esta selecionado
  final double width;  //  Add width
  final double height; //  Add height

  //constructor
  Layer({

    required this.id,
    required this.type,
    this.content,
    required this.dx,
    required this.dy,
    required this.size,
    this.isSelected = false,
    required this.width,   //
    required this.height,  //
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
    double? width,
    double? height,
  }) {
    print("valores actualizados x = ${this.dx}  y = ${this.dy}");
    return Layer(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

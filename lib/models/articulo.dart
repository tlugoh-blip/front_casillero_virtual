class Articulo {
  final int? id;
  final String nombre;
  final String talla;
  final String color;
  final String categoria;
  final String urlImagen;

  Articulo({
    this.id,
    required this.nombre,
    required this.talla,
    required this.color,
    required this.categoria,
    required this.urlImagen,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'],
      nombre: json['nombre'],
      talla: json['talla'],
      color: json['color'],
      categoria: json['categoria'],
      urlImagen: json['urlImagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'talla': talla,
      'color': color,
      'categoria': categoria,
      'urlImagen': urlImagen,
    };
  }
}

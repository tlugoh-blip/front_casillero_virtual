class Articulo {
  final int? id;
  final String nombre;
  final String talla;
  final String descripcion;
  final String categoria;
  final String color;
  final int valorUnitario; // precio in COP
  final String urlImagen;
  final double peso; // weight in pounds

  Articulo({
    this.id,
    required this.nombre,
    required this.talla,
    required this.descripcion,
    required this.categoria,
    required this.color,
    required this.valorUnitario,
    required this.urlImagen,
    required this.peso,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'],
      nombre: json['elNombre'],
      talla: json['talla'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      color: json['color'],
      valorUnitario: json['valorUnitario'],
      urlImagen: json['url'],
      peso: json['peso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elNombre': nombre,
      'talla': talla,
      'descripcion': descripcion,
      'categoria': categoria,
      'color': color,
      'valorUnitario': valorUnitario,
      'url': urlImagen,
      'peso': peso,
    };
  }
}

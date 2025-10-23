class Articulo {
  final int? id; // null al crear, solo se usa al recibir del backend
  final String nombre;
  final String talla;
  final String categoria;
  final String color;
  final int valorUnitario; // precio en COP
  final String url; // Debe llamarse 'url' para coincidir con backend
  final double peso; // peso en libras

  Articulo({
    this.id,
    required this.nombre,
    required this.talla,
    required this.categoria,
    required this.color,
    required this.valorUnitario,
    required this.url,
    required this.peso,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'],
      nombre: json['elNombre'], // coincide con @JsonProperty en backend
      talla: json['talla'],
      categoria: json['categoria'],
      color: json['color'],
      valorUnitario: json['valorUnitario'],
      url: json['url'],
      peso: (json['peso'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elNombre': nombre,
      'talla': talla,
      'categoria': categoria,
      'color': color,
      'valorUnitario': valorUnitario,
      'url': url,
      'peso': peso,
    };
  }
}

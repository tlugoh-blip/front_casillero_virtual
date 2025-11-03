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
    // Intentar obtener id por varias claves posibles
    int? parseId(Map<String, dynamic> j) {
      if (j.containsKey('id')) return (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}');
      if (j.containsKey('id_articulo')) return (j['id_articulo'] is int) ? j['id_articulo'] as int : int.tryParse('${j['id_articulo']}');
      if (j.containsKey('idArticulo')) return (j['idArticulo'] is int) ? j['idArticulo'] as int : int.tryParse('${j['idArticulo']}');
      return null;
    }

    int? id = parseId(json);

    // El backend puede enviar el nombre como 'elNombre' o 'nombre'
    String nombre = json['elNombre'] ?? json['nombre'] ?? '';

    // valorUnitario podría llegar como num o string
    int valor = 0;
    final vu = json['valorUnitario'] ?? json['valor'] ?? json['precio'];
    if (vu != null) {
      if (vu is int) valor = vu;
      else if (vu is double) valor = vu.toInt();
      else {
        valor = int.tryParse('$vu') ?? 0;
      }
    }

    double peso = 0.0;
    final p = json['peso'];
    if (p != null) {
      if (p is num) peso = p.toDouble();
      else peso = double.tryParse('$p') ?? 0.0;
    }

    return Articulo(
      id: id,
      nombre: nombre,
      talla: '${json['talla'] ?? ''}',
      categoria: '${json['categoria'] ?? ''}',
      color: '${json['color'] ?? ''}',
      valorUnitario: valor,
      url: '${json['url'] ?? ''}',
      peso: peso,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // El backend espera 'elNombre'
      'elNombre': nombre,
      'talla': talla,
      // Enviar categoria en minúsculas para consistencia
      'categoria': categoria.toLowerCase(),
      'color': color,
      'valorUnitario': valorUnitario,
      'url': url,
      'peso': peso,
    };
  }
}

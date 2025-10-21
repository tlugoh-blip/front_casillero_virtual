import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/api_service.dart';
import 'editarperfil_pantalla.dart';

class CasilleroPantalla extends StatefulWidget {
  const CasilleroPantalla({Key? key}) : super(key: key);

  @override
  State<CasilleroPantalla> createState() => _CasilleroPantallaState();
}

class _CasilleroPantallaState extends State<CasilleroPantalla> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  // Lista de categorías disponibles (ajustar si tu backend tiene otras)
  final List<String> _categorias = ['Todos', 'Ropa', 'Calzado', 'Accesorios'];

  @override
  void initState() {
    super.initState();
    // cargar items por defecto (puedes dejar vacío o hacer una búsqueda inicial)
    _loadDefaultItems();
  }

  void _loadDefaultItems() {
    setState(() {
      _items = [
        {
          'asset': 'assets/imagenes/tenisnike.png',
          'nombre': 'Zapatillas Nike Blancas',
          'precio': 'S/. 250',
          'stock': '10',
        },
        {
          'asset': 'assets/imagenes/pantaloneta.png',
          'nombre': 'Pantaloneta Beige',
          'precio': 'S/. 150',
          'stock': '5',
        },
        {
          'asset': 'assets/imagenes/hoodienike.png',
          'nombre': 'Hoodie Nike Morado',
          'precio': 'S/. 350',
          'stock': '3',
        },
      ];
    });
  }

  // Ahora aceptamos búsqueda por texto o por categoría
  Future<void> _search({String? query, String? categoria}) async {
    // si no hay query ni categoria, no hacemos nada
    if ((query == null || query.trim().isEmpty) && (categoria == null || categoria.trim().isEmpty)) return;
    setState(() => _loading = true);
    try {
      final resp = await ApiService.searchArticles(query: query, categoria: (categoria == 'Todos' ? null : categoria));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          setState(() {
            _items = data.map<Map<String, dynamic>>((e) {
              return {
                'asset': e['urlImagen'] ?? e['imagen'] ?? '',
                'nombre': e['nombre'] ?? e['titulo'] ?? 'Sin nombre',
                'precio': e['precio']?.toString() ?? '',
                'stock': e['stock']?.toString() ?? '',
                'raw': e,
              };
            }).toList();
          });
        } else {
          // Si el backend devuelve otro formato, intenta manejarlo o muestra vacío
          setState(() => _items = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respuesta inesperada del servidor')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openAnadirArticulo() async {
    final res = await Navigator.pushNamed(context, '/anadirarticulo');
    // si vuelve con verdadero, refrescar la lista (repetir última búsqueda)
    if (res == true) {
      if (_searchController.text.trim().isNotEmpty) {
        await _search(query: _searchController.text.trim());
      } else {
        // opcional: recargar default o hacer búsqueda vacía
        _loadDefaultItems();
      }
    }
  }

  // Muestra un menú modal con categorías y busca por la seleccionada
  void _showCategoryMenu() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categorias.map((cat) {
              return ListTile(
                title: Text(cat),
                onTap: () => Navigator.pop(context, cat),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      // Mostrar la categoría seleccionada en el campo de búsqueda (opcional)
      setState(() {
        _searchController.text = selected == 'Todos' ? '' : selected;
      });

      // Ejecutar la búsqueda por categoría
      await _search(categoria: selected == 'Todos' ? null : selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ENCABEZADO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/imagenes/upperblanco.png',
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Upper®',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditarPerfilPantalla()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔹 TÍTULO
            const Text(
              'Mis artículos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 BOTÓN AÑADIR ARTÍCULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: azulFondo,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _openAnadirArticulo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 26, color: azulFondo),
                      SizedBox(width: 8),
                      Text('Añadir artículo'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 CONTENEDOR PRINCIPAL
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar productos...',
                                suffixIcon: _loading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                                    : IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: _showCategoryMenu,
                                      ),
                              ),
                              onSubmitted: (v) => _search(query: v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de artículos
                    Expanded(
                      child: _items.isEmpty
                          ? const Center(child: Text('No hay artículos', style: TextStyle(color: Colors.black54)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final it = _items[index];
                                return _ArticuloCard(
                                  imagenAsset: it['asset'] ?? '',
                                  nombre: it['nombre'] ?? 'Sin nombre',
                                  precio: it['precio'] ?? '',
                                  stock: it['stock'] ?? '',
                                );
                              },
                            ),
                    ),

                    // 🔹 BOTÓN "IR A PAGAR"
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulFondo,
                            foregroundColor: Colors.white, // ✅ texto blanco
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/pagos');
                          },
                          child: const Text(
                            'Ir a pagar',
                            style: TextStyle(
                              color: Colors.white, // ✅ refuerzo de blanco en texto
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 MENÚ INFERIOR
            Container(
              decoration: const BoxDecoration(
                color: azulFondo,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.home,
                    label: 'Home',
                    onTap: () => Navigator.pushNamed(context, '/home'),
                  ),
                  _NavBarItem(icon: Icons.search, label: 'Buscar', onTap: () {}),
                  _NavBarItem(
                    icon: Icons.payment,
                    label: 'Pagos',
                    onTap: () => Navigator.pushNamed(context, '/pagos'),
                  ),
                  _NavBarItem(icon: Icons.inventory, label: 'Mi casillero', selected: true),
                  _NavBarItem(icon: Icons.history, label: 'Historial'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 CARD DE PRODUCTO
class _ArticuloCard extends StatelessWidget {
  final String imagenAsset;
  final String nombre;
  final String precio;
  final String stock;

  const _ArticuloCard({
    Key? key,
    required this.imagenAsset,
    required this.nombre,
    required this.precio,
    required this.stock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    Widget imageWidget;
    if (imagenAsset.startsWith('http')) {
      imageWidget = Image.network(
        imagenAsset,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 90,
          height: 90,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
      );
    } else if (imagenAsset.isNotEmpty) {
      imageWidget = Image.asset(
        imagenAsset,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Container(
        width: 90,
        height: 90,
        color: Colors.grey[200],
        child: const Icon(Icons.image),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(precio, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('Stock: $stock', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: azulFondo), onPressed: () {}),
                IconButton(icon: const Icon(Icons.delete, color: azulFondo), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 ÍTEM DE MENÚ INFERIOR
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF2D7DFE) : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF2D7DFE) : Colors.white,
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

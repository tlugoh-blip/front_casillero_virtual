import 'package:flutter/material.dart';
import 'editarperfil_pantalla.dart';
import '../api_service.dart';
import '../models/articulo.dart';

class CasilleroPantalla extends StatefulWidget {
  const CasilleroPantalla({Key? key}) : super(key: key);

  @override
  State<CasilleroPantalla> createState() => _CasilleroPantallaState();
}

class _CasilleroPantallaState extends State<CasilleroPantalla> {
  List<Articulo> _articulos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
  }

  Future<void> _cargarArticulos() async {
    try {
      final userId = await ApiService.getUserId();
      if (userId != null) {
        final articulos = await ApiService.getArticulosPorCasillero(userId);
        setState(() {
          _articulos = articulos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar artículos: $e')),
      );
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
                  onPressed: () async {
                    // ✅ Abre la pantalla de Añadir Artículo
                    final result = await Navigator.pushNamed(context, '/anadirarticulo');
                    if (result == true) {
                      _cargarArticulos(); // Recargar artículos después de añadir uno
                    }
                  },
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
                    // Lista de artículos
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _articulos.isEmpty
                              ? const Center(child: Text('No tienes artículos aún.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _articulos.length,
                                  itemBuilder: (context, index) {
                                    final articulo = _articulos[index];
                                    return _ArticuloCard(
                                      imagenUrl: articulo.urlImagen,
                                      nombre: articulo.nombre,
                                      talla: articulo.talla,
                                      color: articulo.color,
                                      categoria: articulo.categoria,
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
                  _NavBarItem(icon: Icons.search, label: 'Buscar'),
                  _NavBarItem(
                    icon: Icons.payment,
                    label: 'Pagos',
                    onTap: () => Navigator.pushNamed(context, '/pagos'),
                  ),
                  _NavBarItem(
                    icon: Icons.inventory,
                    label: 'Mi casillero',
                    selected: true,
                  ),
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
  final String imagenUrl;
  final String nombre;
  final String talla;
  final String color;
  final String categoria;

  const _ArticuloCard({
    Key? key,
    required this.imagenUrl,
    required this.nombre,
    required this.talla,
    required this.color,
    required this.categoria,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagenUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 90),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Talla: $talla', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('Color: $color', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('Categoría: $categoria', style: const TextStyle(fontSize: 14, color: Colors.black54)),
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

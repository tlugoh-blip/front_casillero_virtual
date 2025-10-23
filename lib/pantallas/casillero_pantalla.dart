import 'package:flutter/material.dart';
import 'editarperfil_pantalla.dart';
import '../api_service.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';

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
        // Obtener primero el casillero del usuario
        final casilleroId = await ApiService.getCasilleroId(userId);
        if (casilleroId != null) {
          final articulos = await ApiService.getArticulosPorCasillero(casilleroId);
          setState(() {
            _articulos = articulos;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró el casillero del usuario.')),
          );
        }
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
                    final result = await Navigator.pushNamed(context, '/anadirarticulo');
                    if (result == true) {
                      _cargarArticulos();
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
                    // Lista de artículos en Grid
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _articulos.isEmpty
                          ? const Center(child: Text('No tienes artículos aún.'))
                          : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _articulos.length,
                        itemBuilder: (context, index) {
                          final articulo = _articulos[index];
                          return _ArticuloMiniCard(articulo: articulo);
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
                            foregroundColor: Colors.white,
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
                              color: Colors.white,
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

// 🔹 MINI CARD PARA GRID
class _ArticuloMiniCard extends StatelessWidget {
  final Articulo articulo;

  const _ArticuloMiniCard({Key? key, required this.articulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return GestureDetector(
      onTap: () {
        // Aquí se puede abrir detalle del artículo o menú contextual
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  articulo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articulo.nombre,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Talla: ${articulo.talla}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    'Precio: ${CurrencyConverter.formatCop(articulo.valorUnitario)}',
                    style: const TextStyle(fontSize: 12, color: azulFondo),
                  ),
                ],
              ),
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

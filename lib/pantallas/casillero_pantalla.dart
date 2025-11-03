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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.person, color: Colors.white, size: 30),
                    onSelected: (value) async {
                      if (value == 'editar') {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditarPerfilPantalla()));
                      } else if (value == 'cerrar') {
                        await ApiService.clearUserId();
                        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar perfil')),
                      PopupMenuItem(value: 'cerrar', child: Text('Cerrar sesión')),
                    ],
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
                          return _ArticuloMiniCard(
                            articulo: articulo,
                            onEdit: () async {
                              // Navegar a pantalla de editar y recargar si hubo cambios
                              final result = await Navigator.pushNamed(
                                context,
                                '/editararticulo',
                                arguments: articulo,
                              );
                              if (result == true) {
                                _cargarArticulos();
                              }
                            },
                            onDelete: () async {
                              // Confirmación antes de eliminar
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Eliminar artículo'),
                                  content: const Text('¿Estás seguro que deseas eliminar este artículo?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                // Llamar al API para eliminar
                                if (articulo.id != null) {
                                  try {
                                    final userId = await ApiService.getUserId();
                                    if (userId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario no autenticado.')));
                                    } else {
                                      final casilleroId = await ApiService.getCasilleroId(userId);
                                      if (casilleroId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró el casillero del usuario.')));
                                      } else {
                                        final resp = await ApiService.deleteArticuloFromCasillero(casilleroId, articulo.id!);
                                        if (resp.statusCode == 200 || resp.statusCode == 204) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo eliminado')));
                                          _cargarArticulos();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: ${resp.statusCode} - ${resp.body}')));
                                        }
                                      }
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo sin ID, no se puede eliminar')));
                                }
                              }
                            },
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ArticuloMiniCard({Key? key, required this.articulo, this.onEdit, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      articulo.url,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                    ),
                  ),
                  // Botones editar/eliminar en la esquina superior derecha
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF002B68)),
                            onPressed: onEdit,
                            tooltip: 'Editar',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                            onPressed: onDelete,
                            tooltip: 'Eliminar',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

import 'package:flutter/material.dart';
import 'editarperfil_pantalla.dart';
import '../api_service.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';
import '../widgets/bottom_nav_bar.dart';

class CasilleroPantalla extends StatefulWidget {
  const CasilleroPantalla({Key? key}) : super(key: key);

  @override
  State<CasilleroPantalla> createState() => _CasilleroPantallaState();
}

class _CasilleroPantallaState extends State<CasilleroPantalla> {
  List<Articulo> _articulos = [];
  bool _isLoading = true;
  bool _handledRefresh = false;
  List<int> _pendingRemoved = [];
  bool _handledRemovedIds = false;

  // Valores calculados para el estimado
  double _pesoTotalLb = 0.0;
  double _costoEnvioUsd = 0.0;
  double _costoSeguroUsd = 0.0;
  double _impuestosUsd = 0.0;
  double _costoTotalUsd = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Si la ruta recibió argumentos con `{'refresh': true}`, recargar artículos
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      try { print('[CasilleroPantalla] didChangeDependencies args: $args'); } catch (_) {}

      // Si vienen removed_ids en cualquier caso, guardarlos y aplicarlos
      try {
        final rawRemoved = (args is Map) ? (args['removed_ids'] ?? args['removedIds'] ?? args['removedIdsList']) : null;
        if (!_handledRemovedIds && rawRemoved is List) {
          _handledRemovedIds = true;
          _pendingRemoved = rawRemoved.where((e) => e != null).map((e) {
            if (e is int) return e;
            return int.tryParse('$e');
          }).whereType<int>().toList();
          try { print('[CasilleroPantalla] pendingRemoved set to: $_pendingRemoved'); } catch (_) {}
          // Si ya cargamos artículos, aplicar el filtrado ahora
          if (!_isLoading && _articulos.isNotEmpty) {
            setState(() {
              _articulos = _articulos.where((a) => a.id == null || !_pendingRemoved.contains(a.id)).toList();
            });
            try { print('[CasilleroPantalla] applied removed_ids immediately, articulos ids now: ${_articulos.map((a) => a.id).toList()}'); } catch (_) {}
            _pendingRemoved = [];
            _recalcularEstimado();
          }
        }
      } catch (_) {}

      if (!_handledRefresh && args is Map && (args['refresh'] == true || args['refresh'] == 'true')) {
        _handledRefresh = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _cargarArticulos();
        });
      }
    } catch (_) {}
  }

  Future<void> _cargarArticulos() async {
    try {
      final userId = await ApiService.getUserId();
      if (userId != null) {
        // Obtener primero el casillero del usuario
        final casilleroId = await ApiService.getCasilleroId(userId);
        if (casilleroId != null) {
          final articulos = await ApiService.getArticulosPorCasillero(casilleroId);
          try { print('[CasilleroPantalla] _cargarArticulos loaded ${articulos.length} articulos. ids: ${articulos.map((a) => a.id).toList()}'); } catch (_) {}
           setState(() {
             _articulos = articulos;
             _isLoading = false;
           });
           // Si hay removed ids pendientes, aplicarlos localmente (filtrar)
           if (_pendingRemoved.isNotEmpty) {
             setState(() {
               _articulos = _articulos.where((a) => a.id == null || !_pendingRemoved.contains(a.id)).toList();
             });
             try { print('[CasilleroPantalla] after filtering, articulos ids: ${_articulos.map((a) => a.id).toList()}'); } catch (_) {}
             // limpiar pendientes
             _pendingRemoved = [];
           }
           _recalcularEstimado();
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

  // Estimación: usa peso (lb) de cada artículo; si peso==0 usa un valor por defecto según categoría/subcategoria.
  double _pesoEstimadoPorArticulo(Articulo a) {
    if (a.peso > 0) return a.peso;
    final cat = a.categoria.toLowerCase();
    // Mapeo de pesos por tipo común (libras)
    if (cat.contains('buso') || cat.contains('sudadera') || cat.contains('buzo')) return 1.2; // buso/buzo
    if (cat.contains('chaqueta') || cat.contains('campera') || cat.contains('abrigo')) return 2.0;
    if (cat.contains('pantalon') || cat.contains('jean')) return 1.3;
    if (cat.contains('pantaloneta') || cat.contains('short')) return 0.7;
    if (cat.contains('zapato') || cat.contains('tenis') || cat.contains('sneaker')) return 2.5;
    if (cat.contains('gorra') || cat.contains('accesorio')) return 0.3;
    if (cat.contains('camisa') || cat.contains('tee') || cat.contains('playera')) return 0.6;
    // Por defecto 1 lb
    return 1.0;
  }

  void _recalcularEstimado() {
    // Recalcula el peso total y costos en USD
    double pesoTotal = 0.0;
    int valorTotalCop = 0;
    for (final a in _articulos) {
      pesoTotal += _pesoEstimadoPorArticulo(a);
      valorTotalCop += a.valorUnitario;
    }

    // Fórmula asumida (puedes ajustar las tasas):
    // - Costo de envío por libra (USD)
    const double ratePerLbUsd = 6.0; // ejemplo: 6 USD por libra
    // - Seguro: 1% del valor total en USD
    const double seguroPct = 0.01;
    // - Impuestos/aranceles estimados: 5% del valor total en USD
    const double impuestosPct = 0.05;

    final valorTotalUsd = CurrencyConverter.copToUsd(valorTotalCop);
    final envioUsd = pesoTotal * ratePerLbUsd;
    final seguroUsd = valorTotalUsd * seguroPct;
    final impuestosUsd = valorTotalUsd * impuestosPct;
    final totalUsd = envioUsd + seguroUsd + impuestosUsd;

    setState(() {
      _pesoTotalLb = double.parse(pesoTotal.toStringAsFixed(2));
      _costoEnvioUsd = double.parse(envioUsd.toStringAsFixed(2));
      _costoSeguroUsd = double.parse(seguroUsd.toStringAsFixed(2));
      _impuestosUsd = double.parse(impuestosUsd.toStringAsFixed(2));
      _costoTotalUsd = double.parse(totalUsd.toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);
    // Reservar espacio inferior dinámico para que el último artículo, el card y el botón
    // no queden ocultos por la barra inferior fija.
    final double bottomNavHeight = 84.0;
    final double extraBottomSpace = 140.0; // espacio para el card + botón
    final double listBottomPadding = MediaQuery.of(context).padding.bottom + bottomNavHeight + extraBottomSpace;

    return Scaffold(
      backgroundColor: azulFondo,
      // Barra de navegación inferior fija
      bottomNavigationBar: const SizedBox(height: 84, child: BottomNavBar(selectedIndex: 3)),
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
                          : ListView(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, listBottomPadding),
                        children: [
                          if (_articulos.isEmpty)
                            const SizedBox(height: 200, child: Center(child: Text('No tienes artículos aún.')))
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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

                          // NUEVO: Estimado de costo de importación (ahora dentro del scroll)
                          if (!_isLoading && _articulos.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Estimado costo de importación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Peso total:'),
                                          Text('$_pesoTotalLb lb', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Envío (estimado):'),
                                          Text(CurrencyConverter.formatUsd(_costoEnvioUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Seguro (1%):'),
                                          Text(CurrencyConverter.formatUsd(_costoSeguroUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Impuestos (5%):'),
                                          Text(CurrencyConverter.formatUsd(_impuestosUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total estimado:'),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(CurrencyConverter.formatUsd(_costoTotalUsd), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_costoTotalUsd)), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // 🔹 BOTÓN "IR A PAGAR" (ahora dentro del scroll)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                                onPressed: _articulos.isEmpty
                                    ? null
                                    : () {
                                  Navigator.pushNamed(context, '/pagos', arguments: _articulos);
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
                  ],
                ),
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
                          decoration: BoxDecoration(color: Color.fromRGBO(255,255,255,0.8), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF002B68)),
                            onPressed: onEdit,
                            tooltip: 'Editar',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          decoration: BoxDecoration(color: Color.fromRGBO(255,255,255,0.8), shape: BoxShape.circle),
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

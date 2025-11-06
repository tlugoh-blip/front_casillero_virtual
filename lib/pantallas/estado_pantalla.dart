import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';

class EstadoPantalla extends StatefulWidget {
  const EstadoPantalla({Key? key}) : super(key: key);

  @override
  State<EstadoPantalla> createState() => _EstadoPantallaState();
}

class _EstadoPantallaState extends State<EstadoPantalla> {
  List<Articulo> _articulos = [];
  String _estado = 'En proceso'; // Valor por defecto
  bool _inited = false;
  String? _metodo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Map) {
        final art = args['articulos'];
        final m = args['metodo'];
        if (art is List<Articulo>) {
          _articulos = List<Articulo>.from(art);
        }
        if (m is String) _metodo = m;
      }
      _inited = true;
    }
  }

  Color _colorForEstado(String e) {
    switch (e.toLowerCase()) {
      case 'recibido':
        return Colors.green;
      case 'en proceso':
      case 'enproceso':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
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
            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/imagenes/upperblanco.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text('Upper®', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            const Text(
              'Estado del pedido',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Método de pago: ${_metodo ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    const Text('Artículos comprados del casillero:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    Expanded(
                      child: _articulos.isEmpty
                          ? const Center(child: Text('No hay artículos para mostrar.'))
                          : ListView.builder(
                              itemCount: _articulos.length,
                              itemBuilder: (ctx, i) {
                                final a = _articulos[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: SizedBox(width: 56, child: Image.network(a.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))),
                                    title: Text(a.nombre),
                                    subtitle: Text('Talla: ${a.talla}'),
                                    trailing: Text(CurrencyConverter.formatCop(a.valorUnitario)),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Campo estado actual
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(
                          label: Text(_estado, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: _colorForEstado(_estado),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Botones de acciones
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            ),
                            onPressed: () {
                              setState(() {
                                _estado = 'Recibido';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido marcado como recibido')));
                            },
                            child: const Text('Confirmar recibido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            ),
                            onPressed: () {
                              setState(() {
                                _estado = 'Cancelado';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido marcado como no recibido/cancelado')));
                            },
                            child: const Text('No recibido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Opcional: permitir cambiar a 'En proceso'
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          setState(() {
                            _estado = 'En proceso';
                          });
                        },
                        child: const Text('Marcar como en proceso', style: TextStyle(fontWeight: FontWeight.bold)),
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


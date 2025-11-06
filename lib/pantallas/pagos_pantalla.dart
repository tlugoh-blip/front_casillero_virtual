import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';

class PagosPantalla extends StatefulWidget {
  const PagosPantalla({Key? key}) : super(key: key);

  @override
  State<PagosPantalla> createState() => _PagosPantallaState();
}

class _PagosPantallaState extends State<PagosPantalla> {
  final List<Articulo> _articulos = [];
  String? _metodoSeleccionado;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is List<Articulo>) {
        _articulos.addAll(args);
      }
      _inited = true;
    }
  }

  int get _total => _articulos.fold(0, (s, a) => s + a.valorUnitario);

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado con logo y back
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
              'Método de pago',
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
                    const SizedBox(height: 8),
                    const Text('Selecciona un método de pago:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    // Opciones de pago (Radio - selección única)
                    RadioListTile<String>(
                      value: 'Efectivo',
                      groupValue: _metodoSeleccionado,
                      title: const Text('Efectivo'),
                      onChanged: (v) => setState(() => _metodoSeleccionado = v),
                    ),
                    RadioListTile<String>(
                      value: 'PSE',
                      groupValue: _metodoSeleccionado,
                      title: const Text('PSE'),
                      onChanged: (v) => setState(() => _metodoSeleccionado = v),
                    ),
                    RadioListTile<String>(
                      value: 'Tarjeta Débito',
                      groupValue: _metodoSeleccionado,
                      title: const Text('Tarjeta Débito'),
                      onChanged: (v) => setState(() => _metodoSeleccionado = v),
                    ),
                    RadioListTile<String>(
                      value: 'Tarjeta Crédito',
                      groupValue: _metodoSeleccionado,
                      title: const Text('Tarjeta Crédito'),
                      onChanged: (v) => setState(() => _metodoSeleccionado = v),
                    ),

                    const SizedBox(height: 12),
                    const Divider(),

                    // Resumen de compra
                    Text('Resumen (${_articulos.length} artículos)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _articulos.isEmpty
                          ? const Center(child: Text('No hay artículos para pagar.'))
                          : ListView.builder(
                              itemCount: _articulos.length,
                              itemBuilder: (ctx, i) {
                                final a = _articulos[i];
                                return ListTile(
                                  leading: SizedBox(width: 56, child: Image.network(a.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))),
                                  title: Text(a.nombre),
                                  subtitle: Text('Talla: ${a.talla}'),
                                  trailing: Text(CurrencyConverter.formatCop(a.valorUnitario)),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(CurrencyConverter.formatCop(_total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002B68))),
                      ],
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002B68),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        ),
                        onPressed: _metodoSeleccionado == null || _articulos.isEmpty
                            ? null
                            : () {
                                // Navegar a pantalla de estado pasando articulos y metodo
                                Navigator.pushNamed(
                                  context,
                                  '/estado',
                                  arguments: {
                                    'articulos': _articulos,
                                    'metodo': _metodoSeleccionado,
                                  },
                                );
                              },
                        child: const Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

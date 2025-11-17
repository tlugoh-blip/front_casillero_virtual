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

  // Nuevo: builder para tiles con imagen/icono (consistente con metodos_pago_pantalla)
  Widget _buildPaymentTile({
    required String id,
    required String title,
    IconData? icon,
    String? assetImage,
    String? subtitle,
  }) {
    final bool selected = _metodoSeleccionado == id;
    const Color azul = Color(0xFF002B68);

    return GestureDetector(
      onTap: () => setState(() => _metodoSeleccionado = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
          border: Border.all(color: selected ? Colors.blue.shade300 : Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: assetImage != null
                  ? Image.asset(
                      assetImage,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(icon ?? Icons.payment, size: 28, color: selected ? azul : Colors.black87),
                    )
                  : Icon(icon ?? Icons.payment, size: 28, color: selected ? azul : Colors.black87),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ]
                ],
              ),
            ),
            SizedBox(width: 36, child: Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? azul : Colors.grey, size: 28)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: SingleChildScrollView(
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

              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Selecciona un método de pago:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    // Reemplazo de RadioListTile por tiles con icono/imagen
                    _buildPaymentTile(
                      id: 'Efectivo',
                      title: 'Efectivo',
                      icon: Icons.attach_money,
                      subtitle: 'Paga en efectivo al recibir',
                    ),
                    _buildPaymentTile(
                      id: 'PSE',
                      title: 'PSE',
                      icon: Icons.account_balance_wallet,
                      assetImage: 'assets/imagenes/pse.jpg',
                      subtitle: 'Pago por transferencia bancaria PSE',
                    ),
                    _buildPaymentTile(
                      id: 'Tarjeta Débito',
                      title: 'Tarjeta Débito',
                      icon: Icons.payment,
                      assetImage: 'assets/imagenes/tarjetadebito.webp',
                      subtitle: 'Pago con débito bancario',
                    ),
                    _buildPaymentTile(
                      id: 'Tarjeta Crédito',
                      title: 'Tarjeta Crédito',
                      icon: Icons.credit_card,
                      assetImage: 'assets/imagenes/tarjetacredito.jpg',
                      subtitle: 'Paga con Visa, MasterCard, Amex',
                    ),

                    const SizedBox(height: 12),
                    const Divider(),

                    // Resumen de compra
                    Text('Resumen (${_articulos.length} artículos)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (_articulos.isEmpty)
                      const Center(child: Text('No hay artículos para pagar.'))
                    else ..._articulos.map((a) => ListTile(
                          leading: SizedBox(width: 56, child: Image.network(a.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))),
                          title: Text(a.nombre),
                          subtitle: Text('Talla: ${a.talla}'),
                          trailing: Text(CurrencyConverter.formatCop(a.valorUnitario)),
                        )),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(CurrencyConverter.formatCop(_total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002B68))),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const SizedBox(height: 8),
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
                                // Normalizar método para enviar al backend
                                String normalize(String? label) {
                                  if (label == null) return '';
                                  final l = label.toLowerCase();
                                  if (l.contains('credito')) return 'tarjeta';
                                  if (l.contains('debito') || l.contains('débito')) return 'debito';
                                  if (l.contains('pse')) return 'pse';
                                  if (l.contains('efectivo')) return 'efectivo';
                                  return label;
                                }

                                final metodoEnviar = normalize(_metodoSeleccionado);

                                // DEBUG: imprimir lo que vamos a enviar / navegar
                                try {
                                  print('[PagosPantalla] Continuar pressed. metodoSeleccionado: $_metodoSeleccionado');
                                  print('[PagosPantalla] Normalized metodo: $metodoEnviar, monto: $_total, articulos: ${_articulos.length}');
                                } catch (_) {}

                                // Si la opción es Tarjeta Crédito, abrir la pantalla de tarjeta con monto y articulos
                                if (_metodoSeleccionado == 'Tarjeta Crédito') {
                                  Navigator.pushNamed(
                                    context,
                                    '/tarjeta_credito',
                                    arguments: {
                                      'metodo': metodoEnviar,
                                      'monto': _total,
                                      'articulos': _articulos,
                                    },
                                  );
                                } else {
                                  // Navegar a pantalla de estado pasando articulos y metodo
                                  Navigator.pushNamed(
                                    context,
                                    '/estado',
                                    arguments: {
                                      'articulos': _articulos,
                                      'metodo': metodoEnviar,
                                    },
                                  );
                                }
                              },
                        child: const Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

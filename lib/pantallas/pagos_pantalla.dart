import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';
import '../api_service.dart';

// Campos para estimado de importación
// (se colocan en la parte superior del archivo por claridad)

class PagosPantalla extends StatefulWidget {
  const PagosPantalla({Key? key}) : super(key: key);

  @override
  State<PagosPantalla> createState() => _PagosPantallaState();
}

class _PagosPantallaState extends State<PagosPantalla> {
  final List<Articulo> _articulos = [];
  String? _metodoSeleccionado;
  bool _inited = false;

  // Estimado de importación
  double _pesoTotalLb = 0.0;
  double _costoEnvioUsd = 0.0;
  double _costoSeguroUsd = 0.0;
  double _impuestosUsd = 0.0;
  double _costoImportUsd = 0.0;
  int get _costoImportCop => CurrencyConverter.usdToCop(_costoImportUsd);
  int get _totalFinal => _total + _costoImportCop;

  double _pesoEstimadoPorArticulo(Articulo a) {
    if (a.peso > 0) return a.peso;
    final cat = a.categoria.toLowerCase();
    if (cat.contains('buso') || cat.contains('sudadera') || cat.contains('buzo')) return 1.2;
    if (cat.contains('chaqueta') || cat.contains('campera') || cat.contains('abrigo')) return 2.0;
    if (cat.contains('pantalon') || cat.contains('jean')) return 1.3;
    if (cat.contains('pantaloneta') || cat.contains('short')) return 0.7;
    if (cat.contains('zapato') || cat.contains('tenis') || cat.contains('sneaker')) return 2.5;
    if (cat.contains('gorra') || cat.contains('accesorio')) return 0.3;
    if (cat.contains('camisa') || cat.contains('tee') || cat.contains('playera')) return 0.6;
    return 1.0;
  }

  void _calcularEstimado() {
    double peso = 0.0;
    int valorCop = 0;
    for (final a in _articulos) {
      peso += _pesoEstimadoPorArticulo(a);
      valorCop += a.valorUnitario;
    }
    const double ratePerLbUsd = 6.0;
    const double seguroPct = 0.01;
    const double impuestosPct = 0.05;

    final valorUsd = CurrencyConverter.copToUsd(valorCop);
    final envioUsd = peso * ratePerLbUsd;
    final seguroUsd = valorUsd * seguroPct;
    final impuestosUsd = valorUsd * impuestosPct;
    final totalImportUsd = envioUsd + seguroUsd + impuestosUsd;

    setState(() {
      _pesoTotalLb = double.parse(peso.toStringAsFixed(2));
      _costoEnvioUsd = double.parse(envioUsd.toStringAsFixed(2));
      _costoSeguroUsd = double.parse(seguroUsd.toStringAsFixed(2));
      _impuestosUsd = double.parse(impuestosUsd.toStringAsFixed(2));
      _costoImportUsd = double.parse(totalImportUsd.toStringAsFixed(2));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is List<Articulo>) {
        _articulos.addAll(args);
        // calcular estimado si recibimos articulos
        _calcularEstimado();
      } else {
        // intentar obtener artículos desde el backend si no llegaron por args
        _fetchArticulosFromApi();
      }
      _inited = true;
    }
  }

  // Si no se recibieron artículos por argumentos, intentar obtenerlos del backend
  Future<void> _fetchArticulosFromApi() async {
    try {
      final userId = await ApiService.getUserId();
      if (userId == null) return;
      final casilleroId = await ApiService.getCasilleroId(userId);
      if (casilleroId == null) return;
      final articulos = await ApiService.getArticulosPorCasillero(casilleroId);
      if (articulos.isNotEmpty) {
        setState(() => _articulos.addAll(articulos));
        _calcularEstimado();
      }
    } catch (e) {
      try {
        print('[PagosPantalla] Error fetchArticulosFromApi: $e');
      } catch (_) {}
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

                    // NUEVO: Card con desglose de costo de importación
                    if (_articulos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Peso total', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('$_pesoTotalLb lb'),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Envío (estimado)'),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(CurrencyConverter.formatUsd(_costoEnvioUsd)), Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_costoEnvioUsd)), style: const TextStyle(color: Colors.black54))]),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Seguro (1%)'),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(CurrencyConverter.formatUsd(_costoSeguroUsd)), Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_costoSeguroUsd)), style: const TextStyle(color: Colors.black54))]),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Impuestos (5%)'),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(CurrencyConverter.formatUsd(_impuestosUsd)), Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_impuestosUsd)), style: const TextStyle(color: Colors.black54))]),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Costo importación'),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(CurrencyConverter.formatUsd(_costoImportUsd), style: const TextStyle(fontWeight: FontWeight.bold)), Text(CurrencyConverter.formatCop(_costoImportCop), style: const TextStyle(color: Colors.black54))]),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total (prendas + importación)', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(CurrencyConverter.formatCop(_totalFinal), style: const TextStyle(fontWeight: FontWeight.bold)), Text(CurrencyConverter.formatUsd(CurrencyConverter.copToUsd(_totalFinal)), style: const TextStyle(color: Colors.black54))]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Divider(),

                    // Botón de continuar
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

                                // Navegar a la pantalla de métodos de pago para mostrar el desglose
                                Navigator.pushNamed(
                                  context,
                                  '/metodos_pago',
                                  arguments: {
                                    'articulos': _articulos,
                                    'valorTotalCop': _total,
                                    'pesoTotalLb': _pesoTotalLb,
                                    'costoImportUsd': _costoImportUsd,
                                    // pasamos también el método seleccionado (normalizado)
                                    'metodoEnviar': metodoEnviar,
                                  },
                                );
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

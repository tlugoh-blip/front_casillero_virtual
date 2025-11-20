import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/articulo.dart';
import '../widgets/currency_converter.dart';
import '../api_service.dart';

class MetodosPagoPantalla extends StatefulWidget {
  const MetodosPagoPantalla({Key? key}) : super(key: key);

  @override
  State<MetodosPagoPantalla> createState() => _MetodosPagoPantallaState();
}

class _MetodosPagoPantallaState extends State<MetodosPagoPantalla> {
  String? _seleccion;
  bool _cargando = false;

  static const Color _azulFondo = Color(0xFF002B68);

  // Artículos y estimado
  List<Articulo> _articulos = [];
  bool _inicializado = false;
  bool _autoNavDone = false;
  double _pesoTotalLb = 0.0;
  int _valorTotalCop = 0;
  double _costoEnvioUsd = 0.0;
  double _costoSeguroUsd = 0.0;
  double _impuestosUsd = 0.0;
  double _costoImportUsd = 0.0;
  int get _costoImportCop => CurrencyConverter.usdToCop(_costoImportUsd);
  int get _totalFinalCop => _valorTotalCop + _costoImportCop;

  // Reutilizamos la misma lógica de estimación de peso que en Casillero
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

  void _calcularEstimadoDesdeArticulos(List<Articulo> articulos) {
    double pesoTotal = 0.0;
    int valorTotalCop = 0;
    for (final a in articulos) {
      pesoTotal += _pesoEstimadoPorArticulo(a);
      valorTotalCop += a.valorUnitario;
    }

    // Misma fórmula que en Casillero
    const double ratePerLbUsd = 6.0;
    const double seguroPct = 0.01;
    const double impuestosPct = 0.05;

    final valorTotalUsd = CurrencyConverter.copToUsd(valorTotalCop);
    final envioUsd = pesoTotal * ratePerLbUsd;
    final seguroUsd = valorTotalUsd * seguroPct;
    final impuestosUsd = valorTotalUsd * impuestosPct;
    final totalImportUsd = envioUsd + seguroUsd + impuestosUsd;

    setState(() {
      _articulos = articulos;
      _pesoTotalLb = double.parse(pesoTotal.toStringAsFixed(2));
      _valorTotalCop = valorTotalCop;
      _costoEnvioUsd = double.parse(envioUsd.toStringAsFixed(2));
      _costoSeguroUsd = double.parse(seguroUsd.toStringAsFixed(2));
      _impuestosUsd = double.parse(impuestosUsd.toStringAsFixed(2));
      _costoImportUsd = double.parse(totalImportUsd.toStringAsFixed(2));
    });
  }

  Future<void> _procesarPago() async {
    if (_seleccion == null) return;

    setState(() => _cargando = true);

    final metodo = _seleccion!;
    final descripcion = metodo == 'credit'
        ? 'Tarjeta de crédito'
        : metodo == 'debit'
        ? 'Tarjeta de débito'
        : 'PSE';

    try {
      final url = Uri.parse("http://localhost:8620/pagos/procesar");

      final respuesta = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "metodo": metodo,
          // Enviamos el monto final en COP (prendas + costo importación)
          "monto": _totalFinalCop,
          "descripcion": descripcion,
        }),
      );

      setState(() => _cargando = false);

      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Estado: ${data['status']} - ${data['mensaje']}"),
          ),
        );

        // Después de procesar, navegar a pantalla de estado como en pagos_pantalla
        Navigator.pushNamed(context, '/estado', arguments: {
          'metodo': metodo,
          'monto': _totalFinalCop,
          'respuesta': data,
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${respuesta.body}")),
        );
      }
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error conectando al servidor: $e")),
      );
    }
  }

  Widget _buildPaymentTile({
    required String id,
    required String title,
    required IconData? icon,
    String? assetImage,
    String? subtitle,
  }) {
    final bool selected = _seleccion == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _seleccion = id);
          // Si es tarjeta crédito/débito, ir directamente a la pantalla de tarjeta
          if (id == 'credit' || id == 'debit') {
            final route = id == 'credit' ? '/tarjeta_credito' : '/tarjeta_debito';
            final args = {
              'metodo': id == 'credit' ? 'tarjeta' : 'debito',
              'monto': _totalFinalCop,
              'prendas_cop': _valorTotalCop,
              'costo_import_cop': _costoImportCop,
              // pasar articulos como lista de Maps para que las pantallas de tarjeta los reciban
              'articulos': _articulos,
            };
            try {
              print('[MetodosPagoPantalla] Intentando navegar a $route con args: $args');
            } catch (_) {}
            // Mostrar snackbar breve para confirmar que se detectó el tap
            try {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abriendo $title...'), duration: const Duration(milliseconds: 700)));
            } catch (_) {}
            // Navegar en el siguiente frame para evitar problemas si el onTap se dispara durante build
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!context.mounted) return;
              try {
                await Navigator.pushNamed(context, route, arguments: args);
              } catch (e) {
                try {
                  print('[MetodosPagoPantalla] Error navegando a $route: $e');
                } catch (_) {}
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir $title')));
              }
            });
            return;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
            border: Border.all(
              color: selected ? Colors.blue.shade300 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Ajuste: usar el mismo ancho que en `pagos_pantalla` (56)
              SizedBox(
                width: 56,
                height: 56,
                child: assetImage != null
                    ? Image.asset(
                        assetImage,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          icon ?? Icons.payment,
                          size: 28,
                          color: selected ? _azulFondo : Colors.black87,
                        ),
                      )
                    : Icon(
                        icon ?? Icons.payment,
                        size: 28,
                        color: selected ? _azulFondo : Colors.black87,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              // Reemplazo del Radio (deprecado) por un icono indicador
              SizedBox(
                width: 36,
                child: Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? _azulFondo : Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarPago() {
    if (_seleccion == null) return;

    final metodo = _seleccion == 'credit'
        ? 'Tarjeta de crédito'
        : _seleccion == 'debit'
        ? 'Tarjeta de débito'
        : 'PSE';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text('¿Deseas pagar con $metodo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Si la selección es tarjeta de crédito, redirigir a la pantalla de tarjeta
              if (_seleccion == 'credit') {
                final args = {'metodo': metodo, 'monto': _totalFinalCop, 'prendas_cop': _valorTotalCop, 'costo_import_cop': _costoImportCop, 'articulos': _articulos};
                try { print('[MetodosPagoPantalla] Confirm dialog -> navegar a /tarjeta_credito args: $args'); } catch (_) {}
                if (context.mounted) Navigator.pushNamed(context, '/tarjeta_credito', arguments: args);
              } else if (_seleccion == 'debit') {
                final args = {'metodo': metodo, 'monto': _totalFinalCop, 'prendas_cop': _valorTotalCop, 'costo_import_cop': _costoImportCop, 'articulos': _articulos};
                try { print('[MetodosPagoPantalla] Confirm dialog -> navegar a /tarjeta_debito args: $args'); } catch (_) {}
                if (context.mounted) Navigator.pushNamed(context, '/tarjeta_debito', arguments: args);
              } else {
                // Para PSE procesar directamente
                _procesarPago();
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _inicializado y parsing de argumentos ahora se hacen en didChangeDependencies
    return Scaffold(
      backgroundColor: _azulFondo,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/imagenes/upperblanco.png',
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Upper®',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'Medios de pago',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selecciona un método de pago',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),

                    const SizedBox(height: 18),

                    // RESUMEN DE TOTALES
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Prendas', style: TextStyle(fontWeight: FontWeight.w600)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${_articulos.length} items', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    Text(CurrencyConverter.formatCop(_valorTotalCop)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Peso total', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('$_pesoTotalLb lb', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Desglose del costo de importación
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Envío (estimado)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyConverter.formatUsd(_costoEnvioUsd), style: const TextStyle(fontSize: 12)),
                                    Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_costoEnvioUsd)), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Seguro (1%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyConverter.formatUsd(_costoSeguroUsd), style: const TextStyle(fontSize: 12)),
                                    Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_costoSeguroUsd)), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Impuestos (5%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyConverter.formatUsd(_impuestosUsd), style: const TextStyle(fontSize: 12)),
                                    Text(CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_impuestosUsd)), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),

                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Costo importación (estimado)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyConverter.formatUsd(_costoImportUsd), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(CurrencyConverter.formatCop(_costoImportCop), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total a pagar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyConverter.formatCop(_totalFinalCop), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(CurrencyConverter.formatUsd(CurrencyConverter.copToUsd(_totalFinalCop)), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentTile(
                      id: 'credit',
                      title: 'Tarjeta de crédito',
                      icon: Icons.credit_card,
                      assetImage: 'assets/imagenes/tarjetacredito.jpg',
                      subtitle: 'Paga con Visa, MasterCard, Amex',
                    ),
                    _buildPaymentTile(
                      id: 'debit',
                      title: 'Tarjeta de débito',
                      icon: Icons.payment,
                      assetImage: 'assets/imagenes/tarjetadebito.webp',
                      subtitle: 'Debito bancario',
                    ),
                    _buildPaymentTile(
                      id: 'pse',
                      title: 'PSE',
                      icon: Icons.account_balance_wallet,
                      assetImage: 'assets/imagenes/pse.jpg',
                      subtitle: 'Pago por transferencia bancaria PSE',
                    ),

                    const Spacer(),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _articulos.isEmpty || _seleccion == null || _cargando ? null : _confirmarPago,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B66FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 6,
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                                _articulos.isEmpty
                                    ? 'Sin artículos'
                                    : 'Pagar — ${CurrencyConverter.formatCop(_totalFinalCop)}',
                           style: const TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        _calcularEstimadoDesdeArticulos(articulos);
      }
    } catch (e) {
      try {
        print('[MetodosPagoPantalla] Error fetchArticulosFromApi: $e');
      } catch (_) {}
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      final args = ModalRoute.of(context)?.settings.arguments;
      List<Articulo> articulosRecibidos = [];

      try {
        if (args is List<Articulo>) {
          articulosRecibidos = args;
        } else if (args is List) {
          articulosRecibidos = args.map((e) {
            if (e is Articulo) return e;
            if (e is Map) return Articulo.fromJson(Map<String, dynamic>.from(e));
            return null;
          }).whereType<Articulo>().toList();
        } else if (args is Map) {
          // Primero, si vienen valores pre-calculados, úsalos
          final maybeArt = args['articulos'] ?? args['articulosList'] ?? args['items'];
          if (maybeArt is List<Articulo>) {
            articulosRecibidos = maybeArt;
          } else if (maybeArt is List) {
            articulosRecibidos = maybeArt.map((e) {
              if (e is Articulo) return e;
              if (e is Map) return Articulo.fromJson(Map<String, dynamic>.from(e));
              return null;
            }).whereType<Articulo>().toList();
          }

          // Si vienen totales pre-calculados, úsalos directamente
          if (args.containsKey('valorTotalCop')) {
            final v = args['valorTotalCop'];
            if (v is int) _valorTotalCop = v;
            else if (v is double) _valorTotalCop = v.toInt();
            else if (v is String) _valorTotalCop = int.tryParse(v) ?? _valorTotalCop;
          }
          if (args.containsKey('pesoTotalLb')) {
            final p = args['pesoTotalLb'];
            if (p is num) _pesoTotalLb = double.parse(p.toString());
            else if (p is String) _pesoTotalLb = double.tryParse(p) ?? _pesoTotalLb;
          }
          if (args.containsKey('costoImportUsd')) {
            final c = args['costoImportUsd'];
            if (c is num) _costoImportUsd = double.parse(c.toString());
            else if (c is String) _costoImportUsd = double.tryParse(c) ?? _costoImportUsd;
          }
          // Si viene método preseleccionado del paso anterior, úsalo para _seleccion
          if (args.containsKey('metodoEnviar')) {
            final me = (args['metodoEnviar'] ?? '').toString().toLowerCase();
            if (me.contains('tarjeta') || me.contains('credito')) {
              _seleccion = 'credit';
            } else if (me.contains('debito')) {
              _seleccion = 'debit';
            } else if (me.contains('pse')) {
              _seleccion = 'pse';
            }
          }
        }
      } catch (e) {
        // ignorar parse errors
        articulosRecibidos = [];
      }

      if (articulosRecibidos.isNotEmpty) {
        // debug
        try {
          print('[MetodosPagoPantalla] Articulos recibidos: ${articulosRecibidos.length}');
        } catch (_) {}
        _calcularEstimadoDesdeArticulos(articulosRecibidos);
        // Si ya teníamos _seleccion (preseleccionado), navegar automáticamente a la pantalla correspondiente
        if (!_autoNavDone && (_seleccion == 'credit' || _seleccion == 'debit')) {
          final route = _seleccion == 'credit' ? '/tarjeta_credito' : '/tarjeta_debito';
          final argsNav = {
            'metodo': _seleccion == 'credit' ? 'Tarjeta de crédito' : 'Tarjeta de débito',
            'monto': _totalFinalCop,
            'prendas_cop': _valorTotalCop,
            'costo_import_cop': _costoImportCop,
            'articulos': _articulos,
          };
          _autoNavDone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.pushNamed(context, route, arguments: argsNav);
          });
        }
      } else {
        // intentar obtenerlos del API en background (si el usuario vino desde otra ruta)
        _fetchArticulosFromApi();
      }
      _inicializado = true;
    }
  }
}

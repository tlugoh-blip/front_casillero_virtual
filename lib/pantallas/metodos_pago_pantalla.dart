import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/articulo.dart';
import '../widgets/currency_converter.dart';
import '../api_service.dart';

class MetodosPagoPantalla extends StatefulWidget {
  const MetodosPagoPantalla({Key? key}) : super(key: key);

  @override
  State<MetodosPagoPantalla> createState() => _MetodosPagoPantallaState();
}

class _MetodosPagoPantallaState extends State<MetodosPagoPantalla> {
  // Estado
  String? _seleccion;
  bool _cargando = false;
  bool _inicializado = false;

  // Constante
  static const Color _azulFondo = Color(0xFF002B68);

  // Datos de Artículos y Costos
  List<Articulo> _articulos = [];
  double _pesoTotalLb = 0.0;
  int _valorTotalCop = 0;
  double _costoEnvioUsd = 0.0;
  double _costoSeguroUsd = 0.0;
  double _impuestosUsd = 0.0;
  double _costoImportUsd = 0.0;
  int get _costoImportCop => CurrencyConverter.usdToCop(_costoImportUsd);
  // El monto enviado al backend debe ser el total final
  int get _montoFinalAEnviar => _valorTotalCop + _costoImportCop;

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
      // Importante: Asegurar que valorUnitario sea int/Long, como espera el backend
      valorTotalCop += a.valorUnitario;
      pesoTotal += _pesoEstimadoPorArticulo(a);
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
      // Usar int.round() para Longs en el backend si el cálculo final lo requiere,
      // pero aquí mantenemos precisión. El monto a enviar es int.
      _pesoTotalLb = double.parse(pesoTotal.toStringAsFixed(2));
      _valorTotalCop = valorTotalCop;
      _costoEnvioUsd = double.parse(envioUsd.toStringAsFixed(2));
      _costoSeguroUsd = double.parse(seguroUsd.toStringAsFixed(2));
      _impuestosUsd = double.parse(impuestosUsd.toStringAsFixed(2));
      _costoImportUsd = double.parse(totalImportUsd.toStringAsFixed(2));
    });
  }

  // ==========================================
  // LÓGICA CLAVE: PROCESAR PAGO
  // ==========================================
  Future<void> _procesarPago() async {
    // 🚨 Problema lógico: Esta pantalla ya no debería procesar el pago directamente
    // para tarjetas. Debería navegar a la pantalla de tarjeta donde se obtienen
    // los datos (`numeroTarjeta`, `cvv`, etc.) y *luego* se llama a `ApiService.procesarPago`.
    // Sin embargo, si decides usar esta pantalla como fallback o para métodos como PSE,
    // esta es la lógica de corrección:

    if (_seleccion == null || _articulos.isEmpty) return;

    // Solo se debe llamar a ApiService.procesarPago si no es tarjeta,
    // o si los datos de la tarjeta ya se ingresaron en esta pantalla.
    if (_seleccion == 'credit' || _seleccion == 'debit') {
      // Si el método seleccionado es tarjeta, forzamos la navegación
      // al formulario para que el usuario ingrese los datos faltantes.
      // Luego, ese formulario se encargará de llamar a la API.
      _navegarATarjeta(forceSelection: _seleccion);
      return;
    }

    setState(() => _cargando = true);

    try {
      final userId = await ApiService.getUserId();
      if (userId == null) throw Exception('Usuario no identificado. Por favor, reinicie sesión.');
      final casilleroId = await ApiService.getCasilleroId(userId);
      if (casilleroId == null) throw Exception('No se encontró casillero asociado a su usuario.');

      // 🚨 CORRECCIÓN CLAVE: Obtener y validar IDs de artículos
      final articuloIds = _articulos.where((a) => a.id != null).map((a) => a.id!).toList();
      if (articuloIds.isEmpty) throw Exception('No hay IDs de artículos válidos para enviar al pago.');

      // 🚨 CORRECCIÓN CLAVE: Llamada a la API de Pago
      final data = await ApiService.procesarPago(
        casilleroId: casilleroId,
        metodo: _seleccion!, // ej: 'PSE'
        monto: _montoFinalAEnviar, // Monto total en COP (Long en backend)
        numeroTarjeta: null, // No aplica para PSE
        nombre: null,
        fecha: null,
        cvv: null,
        articuloIds: articuloIds, // Pasamos la lista de IDs (List<int>)
        persistir: true,
      );

      setState(() => _cargando = false);

      // Navegación al estado
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Estado: ${data['status']} - ${data['mensaje']}")),
        );

        Navigator.pushReplacementNamed(context, '/estado', arguments: {
          'metodo': _seleccion!,
          'monto': _montoFinalAEnviar,
          'respuesta': data,
          // Enviamos los Articulos como objetos Articulo o como Map para consistencia
          'articulos': _articulos,
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error procesando pago: $e')));
    }
  }

  // ==========================================
  // LÓGICA DE NAVEGACIÓN A PANTALLA DE TARJETA
  // ==========================================
  void _navegarATarjeta({String? forceSelection}) {
    final selection = forceSelection ?? _seleccion;

    if (selection == 'credit' || selection == 'debit') {
      final route = selection == 'credit' ? '/tarjeta_credito' : '/tarjeta_debito';
      final args = {
        'metodo': selection,
        'monto': _montoFinalAEnviar,
        'prendas_cop': _valorTotalCop,
        'costo_import_cop': _costoImportCop,
        'articulos': _articulos, // Pasar la lista de objetos Articulo
      };

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        try {
          // Usamos push para volver a esta pantalla si el usuario cancela la tarjeta
          await Navigator.pushNamed(context, route, arguments: args);
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el formulario de pago: $e')));
        }
      });
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
            _navegarATarjeta(forceSelection: id); // 🚨 Se llama la función unificada de navegación
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
              // ... (Contenido del Tile sin cambios)
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

  // ==========================================
  // DIÁLOGO DE CONFIRMACIÓN (REFACTORIZADO)
  // ==========================================
  void _confirmarPago() {
    if (_seleccion == null) return;

    // Si la selección es Tarjeta, redirigir al formulario, no procesar aquí.
    if (_seleccion == 'credit' || _seleccion == 'debit') {
      _navegarATarjeta();
      return;
    }

    // Lógica para otros métodos (ej. PSE, que requiere procesar directamente)
    final metodoNombre = _seleccion == 'pse' ? 'PSE' : 'este método';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text('¿Deseas pagar con $metodoNombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Llamamos a la función que intentará procesar el pago directamente (ej. PSE)
              _procesarPago();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _azulFondo,
      body: SafeArea(
        child: Column(
          children: [
            // ... (AppBar y diseño superior sin cambios)
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
                child: SingleChildScrollView(
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
                      // ... (Widget de resumen de totales sin cambios)
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
                                      Text(CurrencyConverter.formatCop(_montoFinalAEnviar), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(CurrencyConverter.formatUsd(CurrencyConverter.copToUsd(_montoFinalAEnviar)), style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
                      // Añadir de nuevo PSE si es un método de pago directo
                      _buildPaymentTile(
                        id: 'pse',
                        title: 'PSE',
                        icon: Icons.account_balance,
                        subtitle: 'Débito bancario en línea',
                      ),


                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _articulos.isEmpty || _seleccion == null || _cargando ? null : _confirmarPago, // Usar _confirmarPago
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
                                : 'Pagar — ${CurrencyConverter.formatCop(_montoFinalAEnviar)}',
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
            ),
          ],
        ),
      ),
    );
  }

  // Si no se recibieron artículos por argumentos, intentar obtenerlos del backend
  Future<void> _fetchArticulosFromApi() async {
    // ... (Lógica de fetch sin cambios, excepto por el `setState` interno)
    try {
      final userId = await ApiService.getUserId();
      if (userId == null) return;
      final casilleroId = await ApiService.getCasilleroId(userId);
      if (casilleroId == null) return;
      final articulos = await ApiService.getArticulosPorCasillero(casilleroId);
      if (articulos.isNotEmpty) {
        // Envolver en setState
        if (mounted) _calcularEstimadoDesdeArticulos(articulos);
      }
    } catch (e) {
      try {
        print('[MetodosPagoPantalla] Error fetchArticulosFromApi: $e');
      } catch (_) {}
    }
  }

  // ==========================================
  // LÓGICA CLAVE: didChangeDependencies (LIMPIEZA Y ORDEN)
  // ==========================================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      final args = ModalRoute.of(context)?.settings.arguments;
      List<Articulo> articulosRecibidos = [];
      String? metodoPreseleccionado;

      try {
        if (args is List<Articulo>) {
          articulosRecibidos = args;
        } else if (args is List) {
          // Mapeo más seguro para evitar TypeErrors si vienen como List<Map>
          articulosRecibidos = args.map((e) {
            if (e is Articulo) return e;
            if (e is Map) return Articulo.fromJson(Map<String, dynamic>.from(e));
            return null;
          }).whereType<Articulo>().toList();
        } else if (args is Map) {
          final Map<String, dynamic> argsMap = Map<String, dynamic>.from(args);
          final maybeArt = argsMap['articulos'] ?? argsMap['articulosList'] ?? argsMap['items'];

          if (maybeArt is List) {
            articulosRecibidos = maybeArt.map((e) {
              if (e is Articulo) return e;
              if (e is Map) return Articulo.fromJson(Map<String, dynamic>.from(e));
              return null;
            }).whereType<Articulo>().toList();
          }

          // Obtener la preselección (se usa en el primer build)
          if (argsMap.containsKey('metodoEnviar')) {
            metodoPreseleccionado = (argsMap['metodoEnviar'] ?? '').toString().toLowerCase();
            if (metodoPreseleccionado.contains('tarjeta') || metodoPreseleccionado.contains('credito')) {
              metodoPreseleccionado = 'credit';
            } else if (metodoPreseleccionado.contains('debito')) {
              metodoPreseleccionado = 'debit';
            } else if (metodoPreseleccionado.contains('pse')) {
              metodoPreseleccionado = 'pse';
            }
          }
        }
      } catch (e) {
        // Manejar errores de parsing
        articulosRecibidos = [];
        try { print('[MetodosPagoPantalla] Error al parsear argumentos: $e'); } catch (_) {}
      }

      if (mounted) {
        if (articulosRecibidos.isNotEmpty) {
          // 1. Calcular estimados y setear artículos
          _calcularEstimadoDesdeArticulos(articulosRecibidos);

          // 2. Setear preselección (si existe)
          if (metodoPreseleccionado != null) {
            setState(() {
              _seleccion = metodoPreseleccionado;
            });
          }

          // 3. Navegar automáticamente si aplica (Ej. venía de Tarjeta y debe volver)
          if (metodoPreseleccionado == 'credit' || metodoPreseleccionado == 'debit') {
            _navegarATarjeta(forceSelection: metodoPreseleccionado);
          }

        } else {
          // Si no hay artículos en argumentos, intentar el fetch API
          _fetchArticulosFromApi();
        }
      }
      _inicializado = true;
    }
  }
}
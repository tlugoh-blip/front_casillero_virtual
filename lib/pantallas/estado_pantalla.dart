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
  List<int> _removedIds = []; // ids de artículos que fueron comprados y deben eliminarse del casillero

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Map) {
        final art = args['articulos'];
        final m = args['metodo'];
        if (art is List) {
          try {
            _articulos = art.map((e) {
              if (e is Articulo) return e;
              if (e is Map) return Articulo.fromJson(Map<String, dynamic>.from(e));
              return null;
            }).whereType<Articulo>().toList();
          } catch (_) {
            _articulos = [];
          }
        }
        if (m is String) _metodo = m;

        // Determinar si el pago fue confirmado por la pantalla de tarjeta
        // Soportar varias claves posibles que el resto de la app pudiera enviar
        final dynamic pagoFlag = args['paymentConfirmed'] ?? args['pagoAprobado'] ?? args['pagado'] ?? args['confirmadoPago'];
        if (pagoFlag != null) {
          bool confirmado = false;
          if (pagoFlag is bool) confirmado = pagoFlag;
          else if (pagoFlag is String) {
            final s = pagoFlag.toLowerCase();
            confirmado = (s == 'true' || s == '1' || s == 'si' || s == 'sí');
          } else if (pagoFlag is num) {
            confirmado = pagoFlag == 1;
          }
          _estado = confirmado ? 'Recibido' : 'En proceso';
        }

        // Nuevo: si llegan datos de resultado de pago (respuesta del API), usarlos
        // Buscar primero en args['respuesta'] (usado por pantallas que pasan el resultado)
        dynamic pagoResult;
        if (args.containsKey('respuesta') && args['respuesta'] is Map) {
          pagoResult = args['respuesta'];
        } else if (args.containsKey('status') || args.containsKey('mensaje') || args.containsKey('id') || args.containsKey('metodo') || args.containsKey('metodoPago')) {
          // args mismo podría ser el resultado
          pagoResult = args;
        }

        if (pagoResult is Map) {
          try {
            print('[EstadoPantalla] pagoResult encontrado: $pagoResult');
          } catch (_) {}

          final statusRaw = (pagoResult['status'] ?? pagoResult['estado'] ?? pagoResult['estadoPago'])?.toString();
          if (statusRaw != null) {
            final s = statusRaw.toLowerCase();
            if (s.contains('aprob') || s.contains('aprobado') || s.contains('approved') || s.contains('ok') || s == 'true') {
              _estado = 'Aprobado';
            } else if (s.contains('rechaz') || s.contains('rejected')) {
              _estado = 'Rechazado';
            } else if (s.contains('pend') || s.contains('pending')) {
              _estado = 'Pendiente';
            } else {
              _estado = statusRaw[0].toUpperCase() + statusRaw.substring(1);
            }
          }

          // Obtener método desde resultado (dando preferencia a keys esperadas)
          final methodRaw = (pagoResult['metodo'] ?? pagoResult['metodoPago'] ?? pagoResult['paymentMethod'] ?? args['metodo'])?.toString();
          if (methodRaw != null && methodRaw.isNotEmpty) {
            final lower = methodRaw.toLowerCase();
            if (lower.contains('tarjeta') || lower.contains('card') || lower.contains('tarj')) {
              _metodo = 'Tarjeta Crédito';
            } else if (lower.contains('pse')) {
              _metodo = 'PSE';
            } else if (lower.contains('debito') || lower.contains('deb')) {
              _metodo = 'Tarjeta Débito';
            } else if (lower.contains('efectivo')) {
              _metodo = 'Efectivo';
            } else {
              _metodo = methodRaw;
            }
          }
        }

        // Capturar removed_ids si fueron enviados por la pantalla de pago
        try {
          final rawRemoved = args['removed_ids'] ?? args['removedIds'] ?? args['removedIdsList'];
          if (rawRemoved is List) {
            _removedIds = rawRemoved.where((e) => e != null).map((e) {
              if (e is int) return e;
              return int.tryParse('$e');
            }).whereType<int>().toList();
          }
        } catch (_) {
          _removedIds = [];
        }
      }
      _inited = true;
    }
  }

  Color _colorForEstado(String e) {
    switch (e.toLowerCase()) {
      case 'aprobado':
      case 'recibido':
        return Colors.green;
      case 'en proceso':
      case 'enproceso':
      case 'pendiente':
        return Colors.orange;
      case 'cancelado':
      case 'rechazado':
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Cerrar y volver al casillero',
                    onPressed: () {
                      // Ir a la pantalla principal del casillero, limpiar la pila y forzar recarga
                      // además pasamos la lista de ids que se compraron para que el casillero los elimine localmente
                      Navigator.pushNamedAndRemoveUntil(context, '/casillero', (route) => false, arguments: {'refresh': true, 'removed_ids': _removedIds});
                    },
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

                    // Acciones manuales eliminadas: el estado solo se muestra y se determina
                    // a partir de la información proveniente de la pantalla de pago.
                    const SizedBox(height: 12),
                    // Si la pantalla recibió info de borrado/comprados, mostrar resumen
                    Builder(builder: (ctx) {
                      final args = ModalRoute.of(context)?.settings.arguments;
                      // Priorizar mostrar los IDs removidos (caso normal cuando viene desde pago)
                      try {
                        if (_removedIds.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('Se registraron ${_removedIds.length} artículos como comprados.', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                          );
                        }
                      } catch (_) {}

                      if (args is Map && (args.containsKey('deleted_count') || args.containsKey('failed_count'))) {
                        final int dc = (args['deleted_count'] is int) ? args['deleted_count'] : int.tryParse('${args['deleted_count'] ?? 0}') ?? 0;
                        final int fc = (args['failed_count'] is int) ? args['failed_count'] : int.tryParse('${args['failed_count'] ?? 0}') ?? 0;
                        final List<dynamic> fidsRaw = args['failed_ids'] ?? [];
                        final failedIds = fidsRaw.where((e) => e != null).map((e) => e.toString()).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dc > 0) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('Se eliminaron $dc artículos del casillero.', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                            if (fc > 0) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('No se pudieron eliminar $fc artículos: ${failedIds.join(', ')}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
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

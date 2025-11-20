import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import '../models/articulo.dart';

// Formatter que inserta automáticamente '/' después de los dos primeros dígitos
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Normalizar solo a dígitos
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    String formatted;
    if (digits.length == 0) {
      formatted = '';
    } else if (digits.length == 1) {
      formatted = digits;
    } else if (digits.length == 2) {
      // insertar la barra inmediatamente después de MM
      formatted = digits + '/';
    } else {
      formatted = digits.substring(0, 2) + '/' + digits.substring(2);
    }

    // Mover el cursor al final para comportamiento sencillo y predecible
    final selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class TarjetaCreditoPantalla extends StatefulWidget {
  const TarjetaCreditoPantalla({Key? key}) : super(key: key);

  @override
  State<TarjetaCreditoPantalla> createState() => _TarjetaCreditoPantallaState();
}

class _TarjetaCreditoPantallaState extends State<TarjetaCreditoPantalla> {
  final Color azulFondo = const Color(0xFF002B68); // azul igual que home y editar perfil
  final Color azulOscuro = const Color(0xFF0648A5); // azul oscuro igual que home y editar perfil

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  double _monto = 0.0; // monto enviado desde la pantalla anterior
  String _metodoFromArgs = 'Tarjeta Crédito';
  bool _initedArgs = false;
  List<dynamic> _articulosCompradas = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initedArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        // intentar leer monto y método
        if (args.containsKey('monto')) {
          final m = args['monto'];
          if (m is int) _monto = m.toDouble();
          else if (m is double) _monto = m;
          else if (m is String) {
            final parsed = double.tryParse(m);
            if (parsed != null) _monto = parsed;
          }
        }
        if (args.containsKey('metodo')) {
          // usar el método tal cual fue pasado por la pantalla anterior
          _metodoFromArgs = args['metodo']?.toString() ?? _metodoFromArgs;
        }
        // si vienen articulos, intentar mapear (aceptar List<Map> o List dinámico)
        if (args.containsKey('articulos')) {
          try {
            final raw = args['articulos'];
            if (raw is List) {
              // Guardar la lista tal cual (puede contener Articulo o Map)
              _articulosCompradas = raw.toList();
            }
          } catch (_) {
            _articulosCompradas = [];
          }
        }
      }
      _initedArgs = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: SingleChildScrollView( // 🔹 evita overflow en pantallas pequeñas
          child: Column(
            children: [
              // BOTÓN REGRESAR
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // TÍTULO
              const Text(
                "Tarjeta de crédito",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              // IMAGEN DE TARJETA
              // IMAGEN DE TARJETA
              Container(
                width: 350,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge, // 🔥 IMPORTANTE: recorta bordes para que la imagen ocupe todo
                child: Image.asset(
                  "assets/imagenes/credito.png",
                  fit: BoxFit.cover, // 🔥 La imagen ahora SÍ llena todo el contenedor
                ),
              ),

              const SizedBox(height: 24),

              // FORMULARIO
              Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                  decoration: BoxDecoration(
                    color: azulOscuro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputCampoNumeroTarjeta(),
                      const SizedBox(height: 18),
                      _inputCampoExpiry(),
                      const SizedBox(height: 18),
                      _inputCampoCVC(),
                      const SizedBox(height: 18),
                      _inputCampoNombre(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // BOTÓN PAGAR
              SizedBox(
                width: double.infinity,
                height: 62,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validar el formulario antes de proceder
                      if (_formKey.currentState?.validate() ?? false) {
                        // Mostrar dialogo de carga
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final numero = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
                          final expiry = _expiryController.text; // MM/AA
                          final cvc = _cvcController.text;
                          final nombre = _nameController.text.trim();

                          // DEBUG: mostrar el payload que enviaremos
                          try {
                            print('[TarjetaCreditoPantalla] Enviando pago con payload: ');
                            print('  metodo: $_metodoFromArgs');
                            print('  monto: $_monto');
                            print('  nombre: $nombre');
                            print('  numeroTarjeta: $numero');
                            print('  fecha: $expiry');
                          } catch (_) {}

                          // Llamar al API para procesar pago y persistirlo
                          final result = await ApiService.procesarPago(
                            metodo: _metodoFromArgs,
                            monto: _monto, // uso del monto real pasado en arguments
                            numeroTarjeta: numero,
                            nombre: nombre,
                            fecha: expiry,
                            cvv: cvc,
                            persistir: true,
                          );

                          // Asegurar que la respuesta tenga 'nombre' y 'metodo' (fallback a lo enviado)
                          try {
                            if (result['nombre'] == null || (result['nombre'] is String && (result['nombre'] as String).trim().isEmpty)) {
                              result['nombre'] = nombre;
                            }
                            if (result['metodo'] == null || (result['metodo'] is String && (result['metodo'] as String).trim().isEmpty)) {
                              result['metodo'] = _metodoFromArgs;
                            }
                          } catch (_) {}

                          // Cerrar el dialogo de carga
                          if (context.mounted) Navigator.of(context).pop();

                          // Mostrar resultado y navegar a estado
                          final status = result['status'] ?? result['status'];
                          final mensaje = result['mensaje'] ?? 'Pago procesado';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$status: $mensaje')),
                          );

                          // Navegar a la pantalla de estado (si existe ruta '/estado')
                          // Si el pago fue exitoso, intentar eliminar los artículos comprados del casillero
                          if (context.mounted) {
                            final List<int> deletedIds = [];
                            final List<int> failedIds = [];
                            try {
                              final userId = await ApiService.getUserId();
                              if (userId != null && _articulosCompradas.isNotEmpty) {
                                final casilleroId = await ApiService.getCasilleroId(userId);
                                if (casilleroId != null) {
                                  for (final a in _articulosCompradas) {
                                    try {
                                      int? aid;
                                      if (a is Articulo) aid = a.id;
                                      else if (a is Map) {
                                        final dynamic idRaw = a['id'] ?? a['id_articulo'] ?? a['idArticulo'];
                                        aid = idRaw is int ? idRaw : int.tryParse('$idRaw');
                                      }
                                      if (aid != null) {
                                        final resp = await ApiService.deleteArticuloFromCasillero(casilleroId, aid);
                                        if (resp.statusCode == 200 || resp.statusCode == 204) {
                                          deletedIds.add(aid);
                                        } else {
                                          failedIds.add(aid);
                                          try { print('[TarjetaCreditoPantalla] delete failed $aid -> ${resp.statusCode} ${resp.body}'); } catch (_) {}
                                        }
                                      }
                                    } catch (e) {
                                      try { print('[TarjetaCreditoPantalla] error deleting articulo: $e'); } catch (_) {}
                                    }
                                  }
                                }
                              }
                            } catch (e) {
                              try { print('[TarjetaCreditoPantalla] general error deleting articulos: $e'); } catch (_) {}
                            }

                            // Mostrar resumen de eliminación
                            try {
                              if (deletedIds.isNotEmpty) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Se eliminaron ${deletedIds.length} artículos del casillero.')));
                              if (failedIds.isNotEmpty) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudieron eliminar ${failedIds.length} artículos: ${failedIds.join(', ')}')));
                            } catch (_) {}

                            final argsNav = {
                              'respuesta': result,
                              'articulos': _articulosCompradas,
                              'paymentConfirmed': true,
                              'removed_ids': deletedIds,
                              'failed_ids': failedIds,
                              'deleted_count': deletedIds.length,
                              'failed_count': failedIds.length,
                            };
                            Navigator.pushNamed(context, '/estado', arguments: argsNav);
                          }

                        } catch (e) {
                          // Cerrar el dialogo si hay error
                          if (context.mounted) Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al procesar el pago: ${e.toString()}')),
                          );
                        }

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Corrige los errores antes de continuar')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B66FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Pagar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 WIDGET DE CAMPO EDITABLE
  Widget _inputCampoNumeroTarjeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número de tarjeta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: '1234123412341234',
            hintStyle: TextStyle(color: Colors.white54),
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          validator: (value) {
            if (value == null) return 'Número inválido';
            final digitsOnly = value.replaceAll(RegExp(r"\D"), '');
            if (digitsOnly.length != 16) return 'El número debe tener exactamente 16 dígitos';
            return null;
          },
        ),
      ],
    );
  }

  Widget _inputCampoExpiry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de expiración (MM/AA)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _expiryController,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4), // limitar a 4 dígitos (MMYY)
            ExpiryDateInputFormatter(),
          ],
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'MM/AA',
            hintStyle: TextStyle(color: Colors.white54),
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Fecha requerida';
            final regex = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$');
            final match = regex.firstMatch(value);
            if (match == null) return 'Formato inválido (MM/AA)';

            final mm = int.parse(match.group(1)!);
            final yy = int.parse(match.group(2)!);

            final now = DateTime.now();
            final currentMM = now.month;
            final currentYY = now.year % 100;

            if (mm == currentMM && yy == currentYY) {
              return 'La fecha no puede ser igual al mes/año actual';
            }

            // Opcional: también puedes evitar fechas ya vencidas (<= actual)
            // final exp = DateTime(2000 + yy, mm);
            // if (!exp.isAfter(DateTime(now.year, now.month))) return 'La tarjeta está vencida';

            return null;
          },
        ),
      ],
    );
  }

  Widget _inputCampoCVC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Código CVC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _cvcController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: '123',
            hintStyle: TextStyle(color: Colors.white54),
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          validator: (value) {
            if (value == null) return 'Código inválido';
            final digitsOnly = value.replaceAll(RegExp(r"\D"), '');
            if (digitsOnly.length != 3) return 'El CVC debe tener exactamente 3 dígitos';
            return null;
          },
        ),
      ],
    );
  }

  Widget _inputCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre en la tarjeta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Como aparece en la tarjeta',
            hintStyle: TextStyle(color: Colors.white54),
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Nombre requerido';
            return null;
          },
        ),
      ],
    );
  }
}

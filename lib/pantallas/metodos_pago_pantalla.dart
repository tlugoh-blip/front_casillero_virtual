import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MetodosPagoPantalla extends StatefulWidget {
  const MetodosPagoPantalla({Key? key}) : super(key: key);

  @override
  State<MetodosPagoPantalla> createState() => _MetodosPagoPantallaState();
}

class _MetodosPagoPantallaState extends State<MetodosPagoPantalla> {
  String? _seleccion;
  bool _cargando = false;

  static const Color _azulFondo = Color(0xFF002B68);

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
          "monto": 50000,
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
          'monto': 50000,
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

    return GestureDetector(
      onTap: () => setState(() => _seleccion = id),
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
                Navigator.pushNamed(context, '/tarjeta_credito', arguments: {
                  'metodo': metodo,
                  'monto': 50000,
                });
              } else {
                // Para PSE o débito procesar directamente
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
                        onPressed:
                        _seleccion == null || _cargando ? null : _confirmarPago,
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
                            : const Text(
                          'Pagar',
                          style: TextStyle(
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
}

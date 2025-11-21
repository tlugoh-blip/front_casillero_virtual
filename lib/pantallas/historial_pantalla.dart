import 'package:flutter/material.dart';
import 'dart:convert';
import '../api_service.dart';
import '../widgets/currency_converter.dart';
import 'package:http/http.dart' as http; // Se añade el import de http para manejar errores específicos

class HistorialPantalla extends StatefulWidget {
  const HistorialPantalla({Key? key}) : super(key: key);

  @override
  State<HistorialPantalla> createState() => _HistorialPantallaState();
}

class _HistorialPantallaState extends State<HistorialPantalla> {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _pagos = [];

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  // =======================================================
  // CARGA DE PAGOS
  // =======================================================
  Future<void> _loadPagos() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lista = await ApiService.getPagos();

      setState(() {
        _pagos = lista;
      });
    } catch (e) {
      // Manejo de errores de red o API más específicos
      String errorMessage = 'Error al cargar el historial.';
      if (e is http.ClientException) {
        errorMessage = 'Error de conexión: Verifica tu red o el servidor.';
      } else if (e is Exception) {
        errorMessage = e.toString().contains("404") ? 'Ruta no encontrada.' : e.toString().replaceFirst('Exception:', 'Error API:');
      }

      setState(() {
        _error = errorMessage;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // =======================================================
  // CONSTRUCCIÓN DEL TILE DE PAGO
  // =======================================================
  Widget _buildPaymentTile(Map<String, dynamic> p) {
    final metodo = (p['metodo'] ?? p['metodoPago'] ?? '').toString();
    final nombre = (p['elNombre'] ?? p['nombre'])?.toString() ?? '—';
    final status = p['status']?.toString() ?? '';
    final mensaje = p['mensaje']?.toString() ?? '';
    final fecha = p['fecha']?.toString() ?? '';

    // Conversión segura de monto
    int montoInt = 0;
    final rawMonto = p['monto'] ?? p['total'] ?? 0;
    if (rawMonto is int) montoInt = rawMonto;
    else if (rawMonto is double) montoInt = rawMonto.round();
    else if (rawMonto is String) montoInt = int.tryParse(rawMonto) ?? 0;

    final numeroMask = p['numeroTarjetaMask']?.toString() ?? '';

    // Lógica de ícono/imagen de método de pago
    String? assetImage;
    IconData? fallbackIcon;
    final lower = metodo.toLowerCase();
    if (lower.contains('tarjeta')) assetImage = 'assets/imagenes/tarjetacredito.jpg';
    else if (lower.contains('pse')) assetImage = 'assets/imagenes/pse.jpg';
    else if (lower.contains('debito')) assetImage = 'assets/imagenes/tarjetadebito.webp';
    else if (lower.contains('efectivo')) fallbackIcon = Icons.attach_money;
    else fallbackIcon = Icons.payment;

    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          // Usamos el objeto original como fallback si la llamada al API falla
          Map<String, dynamic> payment = Map<String, dynamic>.from(p);
          final pagoIdRaw = p['id'] ?? p['ID'];
          final pagoId = pagoIdRaw is int ? pagoIdRaw : (pagoIdRaw != null ? int.tryParse(pagoIdRaw.toString()) : null);

          // Obtener datos frescos (asegura que tengamos la última estructura, incluyendo artículos)
          if (pagoId != null) {
            final fresh = await ApiService.getPagoById(pagoId);
            if (fresh != null) payment = Map<String, dynamic>.from(fresh);
          }

          final args = Map<String, dynamic>.from(payment);

          // Normalizar datos para la pantalla de estado
          args['nombre'] = (payment['elNombre'] ?? payment['nombre'])?.toString() ?? '—';
          final rawM = payment['monto'];
          if (rawM is int) args['monto'] = rawM;
          else if (rawM is double) args['monto'] = rawM.round();
          else if (rawM is String) args['monto'] = int.tryParse(rawM) ?? 0;

          // Extraer artículos pagados
          dynamic artsRaw = payment['articulosPagados'] ?? payment['articulos'];

          List<Map<String, dynamic>> articulos = [];
          if (artsRaw is List) {
            for (final a in artsRaw) {
              if (a is Map) {
                // 💡 MEJORA: Asegurar que se añada el mapa completo.
                // Esto garantiza que el campo 'imagen' (ArticuloDTO) esté disponible.
                articulos.add(Map<String, dynamic>.from(a));
              }
              else {
                // Fallback si el artículo no es un mapa (solo para evitar crasheos)
                articulos.add({'nombre': a.toString(), 'precio': 0, 'imagen': ''});
              }
            }
          }

          args['articulos'] = articulos; // El argumento que espera la pantalla /estado

          Navigator.pop(context);
          Navigator.pushNamed(context, '/estado', arguments: args);
        } catch (e) {
          // Si falla la carga fresca del API, navegamos con los datos del tile
          Navigator.pop(context);

          // Crear args con los datos mínimos del tile para evitar crasheo total
          final fallbackArgs = {
            'nombre': nombre,
            'monto': montoInt,
            'status': status,
            'mensaje': mensaje,
            'metodo': metodo,
            'numeroTarjetaMask': numeroMask,
            'fecha': fecha,
            // Asumimos que no podemos obtener los artículos, pasamos una lista vacía
            'articulos': [],
          };

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar detalles: ${e.toString().split(':')[0]}.')),
          );

          // Navegar con datos incompletos pero seguros
          Navigator.pushNamed(context, '/estado', arguments: fallbackArgs);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: assetImage != null
                  ? Image.asset(assetImage, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(fallbackIcon ?? Icons.payment))
                  : Icon(fallbackIcon ?? Icons.payment, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyConverter.formatCop(montoInt),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002B68)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('$metodo · ${numeroMask.isNotEmpty ? numeroMask : fecha}', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          status,
                          style: TextStyle(
                              color: status == 'RECHAZADO' ? Colors.red : (status == 'PENDIENTE' ? Colors.orange : Colors.green),
                              fontWeight: FontWeight.w600
                          )
                      ),
                      Text(mensaje, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // BUILD PRINCIPAL
  // =======================================================
  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);
    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                      'assets/imagenes/upperblanco.png',
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                          'Upper®',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                      )
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Historial de pagos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text('Error: $_error', textAlign: TextAlign.center,))
                    : _pagos.isEmpty
                    ? const Center(child: Text('No hay pagos registrados.'))
                    : RefreshIndicator(
                  onRefresh: _loadPagos,
                  child: ListView.builder(
                    itemCount: _pagos.length,
                    itemBuilder: (ctx, i) => _buildPaymentTile(_pagos[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

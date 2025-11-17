import 'package:flutter/material.dart';
import '../api_service.dart';
import '../widgets/currency_converter.dart';

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

  Future<void> _loadPagos() async {
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
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildPaymentTile(Map<String, dynamic> p) {
    final metodoRaw = (p['metodo'] ?? p['metodoPago'] ?? '')?.toString() ?? '';
    final metodo = metodoRaw.toString();
    final nombre = (p['nombre'] ?? p['elNombre'])?.toString() ?? '—';
    final status = p['status']?.toString() ?? '';
    final mensaje = p['mensaje']?.toString() ?? '';
    final fecha = p['fecha']?.toString() ?? '';

    int montoInt = 0;
    try {
      final m = p['monto'];
      if (m is int) montoInt = m;
      else if (m is double) montoInt = m.round();
      else if (m is String) montoInt = int.tryParse(m) ?? 0;
    } catch (_) {}

    final numeroMask = p['numeroTarjetaMask']?.toString() ?? '';

    String? assetImage;
    IconData? fallbackIcon;
    final lower = metodo.toLowerCase();
    if (lower.contains('tarjeta') || lower.contains('tarj')) {
      assetImage = 'assets/imagenes/tarjetacredito.jpg';
    } else if (lower.contains('pse')) {
      assetImage = 'assets/imagenes/pse.jpg';
    } else if (lower.contains('efectivo')) {
      fallbackIcon = Icons.attach_money;
    } else if (lower.contains('debito') || lower.contains('deb')) {
      assetImage = 'assets/imagenes/tarjetadebito.webp';
    } else {
      fallbackIcon = Icons.payment;
    }

    return GestureDetector(
      onTap: () {
        // navegar a estado con el pago como argumento
        Navigator.pushNamed(context, '/estado', arguments: p);
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
                      Text(status, style: TextStyle(color: status == 'RECHAZADO' ? Colors.red : (status == 'PENDIENTE' ? Colors.orange : Colors.green), fontWeight: FontWeight.w600)),
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
                  Image.asset('assets/imagenes/upperblanco.png', height: 80, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('Upper®', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
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
                        ? Center(child: Text('Error: $_error'))
                        : _pagos.isEmpty
                            ? const Center(child: Text('No hay pagos registrados.'))
                            : RefreshIndicator(
                                onRefresh: _loadPagos,
                                child: ListView.builder(
                                  itemCount: _pagos.length,
                                  itemBuilder: (ctx, i) {
                                    final p = _pagos[i];
                                    return _buildPaymentTile(p);
                                  },
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


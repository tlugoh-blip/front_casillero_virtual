import 'package:flutter/material.dart';
import '../widgets/currency_converter.dart';
import '../widgets/bottom_nav_bar.dart';

class CostoImportacionPantalla extends StatefulWidget {
  const CostoImportacionPantalla({Key? key}) : super(key: key);

  @override
  State<CostoImportacionPantalla> createState() => _CostoImportacionPantallaState();
}

class _CostoImportacionPantallaState extends State<CostoImportacionPantalla> {
  final Color _azulFondo = const Color(0xFF002B68);
  final _formKey = GlobalKey<FormState>();

  final List<String> _tipos = ['Ropa', 'Calzado', 'Accesorio'];
  final List<String> _subRopa = ['Camisa', 'Pantalón', 'Pantaloneta', 'Buzo', 'Chaqueta'];
  final List<String> _subCalzado = ['Tenis', 'Chanclas', 'Botas'];
  final List<String> _subAccesorio = ['Gorra', 'Bolso', 'Otro'];

  List<_LineaArticulo> _lineas = [
    _LineaArticulo(tipo: 'Ropa', subcategoria: 'Camisa', cantidad: 1)
  ];

  final TextEditingController _cantidadCtrl = TextEditingController(text: '1');

  bool _mostrandoResultado = false;

  double _pesoPorUnidadLb(String tipoPrincipal, String subcat) {
    final s = subcat.toLowerCase();
    if (tipoPrincipal == 'Calzado') return 2.5;
    if (tipoPrincipal == 'Accesorio') return 0.3;
    if (s.contains('buzo') || s.contains('sudadera')) return 1.2;
    if (s.contains('chaqueta')) return 2.0;
    if (s.contains('pantalón') || s.contains('pantalon')) return 1.3;
    if (s.contains('pantaloneta')) return 0.7;
    if (s.contains('tenis')) return 2.5;
    if (s.contains('gorra')) return 0.3;
    if (s.contains('camisa')) return 0.6;
    return 1.0;
  }

  void _calcular() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    const double ratePerLbUsd = 3.0;
    const double seguroPct = 0.005;
    const double impuestosPct = 0.04;

    double pesoTotal = 0.0;
    double valorPrendasUsd = 0.0;

    for (final linea in _lineas) {
      final qty = linea.cantidad <= 0 ? 1 : linea.cantidad;
      final pesoUnit = _pesoPorUnidadLb(linea.tipo, linea.subcategoria);
      pesoTotal += pesoUnit * qty;
      final valorUnitUsd = _valorUnitarioEstimadoUsd(linea.tipo, linea.subcategoria);
      valorPrendasUsd += valorUnitUsd * qty;
    }

    final envioUsd = pesoTotal * ratePerLbUsd;
    final seguroUsd = valorPrendasUsd * seguroPct;
    final impuestosUsd = valorPrendasUsd * impuestosPct;
    final totalImportUsd = envioUsd + seguroUsd + impuestosUsd;
    final totalAproximadoUsd = valorPrendasUsd + totalImportUsd;

    setState(() {
      _mostrandoResultado = true;
      _ultimoResultado = _ResultadoEstimado(
        pesoTotalLb: double.parse(pesoTotal.toStringAsFixed(2)),
        envioUsd: double.parse(envioUsd.toStringAsFixed(2)),
        seguroUsd: double.parse(seguroUsd.toStringAsFixed(2)),
        impuestosUsd: double.parse(impuestosUsd.toStringAsFixed(2)),
        valorPrendasUsd: double.parse(valorPrendasUsd.toStringAsFixed(2)),
        totalUsd: double.parse(totalAproximadoUsd.toStringAsFixed(2)),
      );
    });
  }

  double _valorUnitarioEstimadoUsd(String tipoPrincipal, String subcat) {
    double valorUnitUsd = 12.0;
    final s = subcat.toLowerCase();

    if (tipoPrincipal == 'Calzado') {
      if (s.contains('tenis')) return 35.0;
      if (s.contains('chancla')) return 12.0;
      if (s.contains('bota')) return 45.0;
      return 30.0;
    }

    if (tipoPrincipal == 'Accesorio') return 8.0;

    if (s.contains('buzo')) return 28.0;
    if (s.contains('chaqueta')) return 55.0;
    if (s.contains('pantaloneta')) return 10.0;
    if (s.contains('camisa')) return 14.0;

    return valorUnitUsd;
  }

  _ResultadoEstimado _ultimoResultado = const _ResultadoEstimado.empty();

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18.0);

    return Scaffold(
      backgroundColor: _azulFondo,
      bottomNavigationBar:
      const SizedBox(height: 84, child: BottomNavBar(selectedIndex: 1)),

      // 🔥🔥🔥 TU APPBAR CORREGIDO EXACTAMENTE COMO LO ESCRIBISTE 🔥🔥🔥
      appBar: AppBar(
        backgroundColor: _azulFondo,
        elevation: 0,
        toolbarHeight: 110,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          children: const [
            SizedBox(height: 6),
            Text(
              'Costo aproximado de importación',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
          ],
        ),
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/imagenes/upperblanco.png',
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Artículos a estimar',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: List.generate(_lineas.length, (index) {
                          final linea = _lineas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          initialValue: linea.tipo,
                                          items: _tipos
                                              .map((e) =>
                                              DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e)))
                                              .toList(),
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() {
                                              linea.tipo = v;
                                              if (v == 'Ropa')
                                                linea.subcategoria =
                                                    _subRopa.first;
                                              else if (v == 'Calzado')
                                                linea.subcategoria =
                                                    _subCalzado.first;
                                              else
                                                linea.subcategoria =
                                                    _subAccesorio.first;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          initialValue: linea.subcategoria,
                                          items: (linea.tipo == 'Ropa'
                                              ? _subRopa
                                              : linea.tipo == 'Calzado'
                                              ? _subCalzado
                                              : _subAccesorio)
                                              .map((e) =>
                                              DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e)))
                                              .toList(),
                                          onChanged: (v) => setState(() =>
                                          linea.subcategoria =
                                              v ?? linea.subcategoria),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          initialValue:
                                          linea.cantidad.toString(),
                                          keyboardType:
                                          TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Cantidad',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                          ),
                                          validator: (val) {
                                            final n =
                                            int.tryParse(val ?? '');
                                            if (n == null || n <= 0)
                                              return 'Ingresa cantidad válida';
                                            return null;
                                          },
                                          onChanged: (v) => setState(() =>
                                          linea.cantidad =
                                              int.tryParse(v) ?? 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: _lineas.length == 1
                                            ? null
                                            : () => setState(() =>
                                            _lineas.removeAt(index)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _lineas.add(
                              _LineaArticulo(
                                  tipo: 'Ropa',
                                  subcategoria: 'Camisa',
                                  cantidad: 1))),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar artículo'),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _calcular,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B66FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Calcular costo',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      const Text('Resultado estimado',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      _mostrandoResultado
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._lineas.map((l) {
                            final pesoUnit = _pesoPorUnidadLb(
                                l.tipo, l.subcategoria);
                            final lineUsd =
                                _valorUnitarioEstimadoUsd(
                                    l.tipo, l.subcategoria) *
                                    l.cantidad;
                            final lineCop =
                            CurrencyConverter.usdToCop(lineUsd);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${l.cantidad} x ${l.subcategoria}',
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pesoUnit.toStringAsFixed(2)} lb por unidad',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${CurrencyConverter.formatUsd(lineUsd)} • ${CurrencyConverter.formatCop(lineCop)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Peso total'),
                                Text(
                                  '${_ultimoResultado.pesoTotalLb} lb',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                )
                              ]),
                          const SizedBox(height: 6),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Envío (estimado)'),
                                Text(
                                  '${CurrencyConverter.formatUsd(_ultimoResultado.envioUsd)} • ${CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_ultimoResultado.envioUsd))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                )
                              ]),
                          const SizedBox(height: 6),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Seguro (1%)'),
                                Text(
                                  '${CurrencyConverter.formatUsd(_ultimoResultado.seguroUsd)} • ${CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_ultimoResultado.seguroUsd))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                )
                              ]),
                          const SizedBox(height: 6),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Impuestos (5%)'),
                                Text(
                                  '${CurrencyConverter.formatUsd(_ultimoResultado.impuestosUsd)} • ${CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_ultimoResultado.impuestosUsd))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                )
                              ]),
                          const Divider(),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Valor prendas'),
                                Text(
                                  '${CurrencyConverter.formatUsd(_ultimoResultado.valorPrendasUsd)} • ${CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_ultimoResultado.valorPrendasUsd))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total aproximado'),
                                Text(
                                  '${CurrencyConverter.formatUsd(_ultimoResultado.totalUsd)} • ${CurrencyConverter.formatCop(CurrencyConverter.usdToCop(_ultimoResultado.totalUsd))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                )
                              ]),
                        ],
                      )
                          : const SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                              'Ingrese los datos y pulse "Calcular costo"'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineaArticulo {
  String tipo;
  String subcategoria;
  int cantidad;

  _LineaArticulo({
    required this.tipo,
    required this.subcategoria,
    this.cantidad = 1,
  });
}

class _ResultadoEstimado {
  final double pesoTotalLb;
  final double envioUsd;
  final double seguroUsd;
  final double impuestosUsd;
  final double valorPrendasUsd;
  final double totalUsd;

  const _ResultadoEstimado({
    required this.pesoTotalLb,
    required this.envioUsd,
    required this.seguroUsd,
    required this.impuestosUsd,
    required this.valorPrendasUsd,
    required this.totalUsd,
  });

  const _ResultadoEstimado.empty()
      : pesoTotalLb = 0,
        envioUsd = 0,
        seguroUsd = 0,
        impuestosUsd = 0,
        valorPrendasUsd = 0,
        totalUsd = 0;
}

import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/api_service.dart';

class AnadirArticuloPantalla extends StatefulWidget {
  const AnadirArticuloPantalla({Key? key}) : super(key: key);

  @override
  State<AnadirArticuloPantalla> createState() => _AnadirArticuloPantallaState();
}

class _AnadirArticuloPantallaState extends State<AnadirArticuloPantalla> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  String? _categoriaSeleccionada;
  final List<String> _categorias = ['Ropa', 'Calzado', 'Accesorios'];
  bool _loading = false;

  // Currency handling
  String _monedaSeleccionada = 'USD'; // 'USD' o 'COP'
  double _exchangeRate = 4000.0; // 1 USD = 4000 COP (valor por defecto)

  @override
  void dispose() {
    _nombreController.dispose();
    _tallaController.dispose();
    _colorController.dispose();
    _urlController.dispose();
    _precioController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);
    const azulClaro = Color(0xFF0E3E8A);

    return Scaffold(
      backgroundColor: azulFondo,
      appBar: AppBar(
        backgroundColor: azulFondo,
        elevation: 0,
        // 🔹 Se elimina el título "Mi casillero"
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Upper
              Image.asset(
                'assets/imagenes/upperblanco.png',
                height: 130,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'Upper®',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Añadir artículo',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),

              // Contenedor principal del formulario
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: azulClaro,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildTextField('Nombre', _nombreController),
                    const SizedBox(height: 16),
                    _buildTextField('Talla', _tallaController),
                    const SizedBox(height: 16),
                    _buildTextField('Color', _colorController),
                    const SizedBox(height: 16),

                    // Categoría Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _categoriaSeleccionada,
                      dropdownColor: azulClaro,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: _categorias
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoriaSeleccionada = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo URL con ícono
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixIcon: Icon(Icons.link, color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Precio y selector de moneda
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _precioController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Precio',
                              labelStyle: const TextStyle(color: Colors.white),
                              prefixText: _monedaSeleccionada == 'USD' ? '\$ ' : 'COP ',
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _monedaSeleccionada,
                            dropdownColor: azulClaro,
                            decoration: const InputDecoration(
                              labelText: 'Moneda',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: ['USD', 'COP']
                                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                // Mantener el valor visual pero no transformar automáticamente el número
                                _monedaSeleccionada = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Mostrar conversión rápida y valor que se enviará en COP si hay precio
                    if (_precioController.text.trim().isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mostrar referencia de conversión
                            Text(
                              _monedaSeleccionada == 'USD'
                                  ? 'Referencia: ${( (_parseDouble(_precioController.text.trim()) ?? 0) * _exchangeRate).toStringAsFixed(2)} COP'
                                  : 'Referencia: ${( (_parseDouble(_precioController.text.trim()) ?? 0) / _exchangeRate).toStringAsFixed(2)} USD',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            // Mostrar explícitamente el valor que se enviará en COP
                            Builder(builder: (context) {
                              final p = _parseDouble(_precioController.text.trim()) ?? 0.0;
                              final int valorUnitarioCOP = _monedaSeleccionada == 'USD' ? (p * _exchangeRate).round() : p.round();
                              return Text(
                                'Se enviará: $valorUnitarioCOP COP (valorUnitario)',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              );
                            }),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Campo peso
                    TextField(
                      controller: _pesoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D7DFE),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _loading ? null : _onGuardarPressed,
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                            : const Text(
                                'Guardar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onGuardarPressed() async {
    final nombre = _nombreController.text.trim();
    final talla = _tallaController.text.trim();
    final color = _colorController.text.trim();
    final url = _urlController.text.trim();
    final categoria = _categoriaSeleccionada ?? '';
    final precioText = _precioController.text.trim();
    final pesoText = _pesoController.text.trim();

    if (nombre.isEmpty || talla.isEmpty || color.isEmpty || categoria.isEmpty || precioText.isEmpty || pesoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa todos los campos')));
      return;
    }

    final precio = _parseDouble(precioText);
    final peso = _parseDouble(pesoText);
    if (precio == null || peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Precio o peso no válido')));
      return;
    }

    // Calcular valorUnitario en COP (long/int) que espera el backend
    int valorUnitarioCOP;
    if (_monedaSeleccionada == 'USD') {
      valorUnitarioCOP = (precio * _exchangeRate).round();
    } else {
      // Ya está en COP
      valorUnitarioCOP = precio.round();
    }

    // Si la URL es data URL, informamos al usuario (hemos decidido omitirla en la petición)
    final bool isDataUrl = _urlController.text.trim().toLowerCase().startsWith('data:');
    if (isDataUrl) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La imagen es muy grande (data URL). Se omitirá en la petición. Considera usar una URL pública o subir la imagen por separado.'),
        duration: Duration(seconds: 4),
      ));
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiService.addArticle(
        nombre: nombre,
        talla: talla,
        color: color,
        categoria: categoria,
        url: url,
        valorUnitario: valorUnitarioCOP,
        peso: peso,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo guardado correctamente')));
        Navigator.pop(context, true); // indica éxito para que la pantalla anterior refresque
      } else {
        // Mostrar el cuerpo de la respuesta para ayudar a depurar (si viene texto o JSON)
        final body = resp.body;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: ${resp.statusCode} - $body')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  double? _parseDouble(String s) {
    try {
      return double.parse(s.replaceAll(',', '.'));
    } catch (_) {
      return null;
    }
  }

  // 🔹 Widget reutilizable para los TextFields
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

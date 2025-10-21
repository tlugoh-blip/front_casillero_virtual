import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/api_service.dart';

class AnadirArticuloPantalla extends StatefulWidget {
  final Map<String, dynamic>? articulo; // si se pasa, estamos editando
  const AnadirArticuloPantalla({Key? key, this.articulo}) : super(key: key);

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

  String _monedaSeleccionada = 'USD';
  double _exchangeRate = 4000.0; // 1 USD = 4000 COP

  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    _loadUsuarioId();
    if (widget.articulo != null) _fillFromArticulo(widget.articulo!);
  }

  Future<void> _loadUsuarioId() async {
    final id = await ApiService.getUserId();
    setState(() => _usuarioId = id);
  }

  void _fillFromArticulo(Map<String, dynamic> a) {
    _nombreController.text = a['nombre']?.toString() ?? '';
    _tallaController.text = a['talla']?.toString() ?? '';
    _colorController.text = a['color']?.toString() ?? '';
    _categoriaSeleccionada = (a['categoria'] as String?) ?? '';
    _urlController.text = a['url']?.toString() ?? '';
    _precioController.text = (a['valorUnitario'] ?? '').toString();
    _pesoController.text = (a['peso'] ?? '').toString();
  }

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
    final bool isEdit = widget.articulo != null;

    return Scaffold(
      backgroundColor: azulFondo,
      appBar: AppBar(
        backgroundColor: azulFondo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(isEdit ? 'Editar artículo' : 'Añadir artículo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              const SizedBox(height: 28),
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
                    DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada != '' ? _categoriaSeleccionada : null,
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
                      items: _categorias.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _categoriaSeleccionada = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen (opcional)',
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
                            value: _monedaSeleccionada,
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
                                .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) => setState(() => _monedaSeleccionada = v ?? 'USD'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D7DFE),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _loading ? null : _onGuardarPressed,
                        child: _loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                            : Text(isEdit ? 'Actualizar' : 'Guardar',
                            style: const TextStyle(color: Colors.white)),
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

    if (nombre.isEmpty ||
        talla.isEmpty ||
        color.isEmpty ||
        categoria.isEmpty ||
        precioText.isEmpty ||
        pesoText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Por favor completa todos los campos')));
      return;
    }

    final precio = _parseDouble(precioText);
    final peso = _parseDouble(pesoText);
    if (precio == null || peso == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Precio o peso no válido')));
      return;
    }

    if (_usuarioId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }

    int valorUnitarioCOP =
    _monedaSeleccionada == 'USD' ? (precio * _exchangeRate).round() : precio.round();

    setState(() => _loading = true);
    try {
      final bool isEdit = widget.articulo != null;

      final resp = isEdit
          ? await ApiService.updateArticle(
        articleId: widget.articulo!['id'],
        nombre: nombre,
        talla: talla,
        color: color,
        categoria: categoria,
        url: url.isEmpty ? null : url,
        valorUnitario: valorUnitarioCOP,
        peso: peso,
      )
          : await ApiService.addArticleByUsuario(
        usuarioId: _usuarioId!,
        nombre: nombre,
        talla: talla,
        color: color,
        categoria: categoria,
        url: url.isEmpty ? null : url,
        valorUnitario: valorUnitarioCOP,
        peso: peso,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEdit ? 'Artículo actualizado' : 'Artículo guardado correctamente')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${resp.statusCode} - ${resp.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
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

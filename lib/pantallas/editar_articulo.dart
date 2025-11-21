import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';

class EditarArticuloPantalla extends StatefulWidget {
  final Articulo? articulo;
  const EditarArticuloPantalla({Key? key, this.articulo}) : super(key: key);

  @override
  State<EditarArticuloPantalla> createState() => _EditarArticuloPantallaState();
}

class _EditarArticuloPantallaState extends State<EditarArticuloPantalla> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada; // agregado
  final List<String> _categorias = ['Ropa', 'Calzado', 'Accesorios'];
  final List<String> _subcategoriasRopa = ['Buso', 'Chaqueta', 'Pantaloneta', 'Pantalon']; // agregado

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si recibimos un artículo, rellenar los campos para editar
    final a = widget.articulo;
    if (a != null) {
      _nombreController.text = a.nombre;
      _tallaController.text = a.talla;
      _colorController.text = a.color;
      // Pre-fill price in USD as a numeric string (e.g. 12.00) so parsing works when saving
      final usd = CurrencyConverter.copToUsd(a.valorUnitario);
      // Usamos entero en el campo de precio (USD) para mantener consistencia con el inputFormatter
      _precioController.text = usd.round().toString();
      _pesoController.text = a.peso.toString();
      _urlController.text = a.url;
      // Asegurarnos de que el valor inicial del Dropdown coincide exactamente
      // con uno de los elementos de la lista `_categorias`.
      // Algunos artículos pueden venir con la categoría en minúsculas
      // (ej. "calzado") mientras que la lista tiene "Calzado".
      // Buscamos una coincidencia case-insensitive y usamos el valor
      // de la lista para evitar la excepción de DropdownButton.
      if (a.categoria.isNotEmpty) {
        final categoriaRaw = a.categoria;
        // Si la categoría viene concatenada como "Ropa > Buso" la parseamos
        if (categoriaRaw.contains('>')) {
          final parts = categoriaRaw.split('>');
          final main = parts[0].trim();
          final sub = parts.length > 1 ? parts[1].trim() : null;
          final match = _categorias.firstWhere(
            (c) => c.toLowerCase() == main.toLowerCase(),
            orElse: () => main,
          );
          _categoriaSeleccionada = match;
          if (sub != null && _subcategoriasRopa.any((s) => s.toLowerCase() == sub.toLowerCase())) {
            _subcategoriaSeleccionada =
                _subcategoriasRopa.firstWhere((s) => s.toLowerCase() == sub.toLowerCase());
          }
        } else {
          final match = _categorias.firstWhere(
            (c) => c.toLowerCase() == categoriaRaw.toLowerCase(),
            orElse: () => categoriaRaw,
          );
          _categoriaSeleccionada = match;
        }
      } else {
        _categoriaSeleccionada = null;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tallaController.dispose();
    _colorController.dispose();
    _precioController.dispose();
    _pesoController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);
    const azulClaro = Color(0xFF0E3E8A);

    final isEditing = widget.articulo != null;

    return Scaffold(
      backgroundColor: azulFondo,
      appBar: AppBar(
        backgroundColor: azulFondo,
        elevation: 0,
        title: Text(isEditing ? 'Editar artículo' : 'Añadir artículo'),
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

              const SizedBox(height: 8),

              // Contenedor principal del formulario
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: azulClaro,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      'Nombre',
                      _nombreController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9ÁÉÍÓÚáéíóúÑñüÜ\s'-]")),
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Talla',
                      _tallaController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      'Color',
                      _colorController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÁÉÍÓÚáéíóúÑñüÜ\s'-]")),
                        LengthLimitingTextInputFormatter(30),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // -------------------------
                    // Categoría (ahora después de Color)
                    // -------------------------
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
                          // Reset subcategoria si cambia la categoría
                          if (_categoriaSeleccionada != 'Ropa') {
                            _subcategoriaSeleccionada = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Subcategoría visible sólo si la categoría es Ropa
                    if (_categoriaSeleccionada == 'Ropa')
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _subcategoriaSeleccionada,
                            dropdownColor: azulClaro,
                            decoration: const InputDecoration(
                              labelText: 'Subcategoría (ropa)',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: _subcategoriasRopa
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _subcategoriaSeleccionada = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Campo Precio: aceptar solo dígitos (USD entero), máximo 999999
                    TextField(
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Precio (USD)',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixIcon: Icon(Icons.attach_money, color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    if (_precioController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Equivalente: ${CurrencyConverter.formatCop(CurrencyConverter.usdToCop(double.tryParse(_precioController.text) ?? 0.0))}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Campo Peso con label dinámico según subcategoría
                    TextField(
                      controller: _pesoController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: _subcategoriaSeleccionada != null
                            ? 'Peso (libras) - estimado para ${_subcategoriaSeleccionada!}'
                            : 'Peso (libras)',
                        labelStyle: const TextStyle(color: Colors.white),
                        suffixIcon: const Icon(Icons.scale, color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
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
                        onPressed: _isLoading ? null : _guardarArticulo,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEditing ? 'Guardar cambios' : 'Guardar',
                                style: const TextStyle(color: Colors.white),
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

  // 🔹 Widget reutilizable para los TextFields
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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

  Future<void> _guardarArticulo() async {
    final nombre = _nombreController.text.trim();
    final talla = _tallaController.text.trim();
    final color = _colorController.text.trim();
    // Precio mostrado en USD -> convertir a COP para enviar
    final precioUsd = double.tryParse(_precioController.text.trim()) ?? 0.0;
    final precio = CurrencyConverter.usdToCop(precioUsd);
    final peso = double.tryParse(_pesoController.text.trim()) ?? 0.0;
    final categoria = _categoriaSeleccionada;
    final subcategoria = _subcategoriaSeleccionada; // agregado
    final urlImagen = _urlController.text.trim();

    // Validaciones básicas de presencia
    if (nombre.isEmpty ||
        talla.isEmpty ||
        color.isEmpty ||
        precioUsd == 0.0 ||
        peso == 0.0 ||
        categoria == null ||
        urlImagen.isEmpty ||
        (categoria == 'Ropa' && subcategoria == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    // Validaciones de formato
    // Nombre: permitir letras y números
    final RegExp alnumReg = RegExp(r"^[A-Za-z0-9ÁÉÍÓÚáéíóúÑñüÜ\s'-]+$");
    // Color: solo letras
    final RegExp lettersReg = RegExp(r"^[A-Za-zÁÉÍÓÚáéíóúÑñüÜ\s'-]+$");
    if (!alnumReg.hasMatch(nombre)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre solo debe contener letras o números.')));
      return;
    }
    if (!lettersReg.hasMatch(color)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El color solo debe contener letras.')));
      return;
    }

    final RegExp tallaReg = RegExp(r'^[A-Za-z0-9]{1,2}$');
    if (!tallaReg.hasMatch(talla)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La talla debe tener máximo 2 caracteres alfanuméricos.')));
      return;
    }

    if (precioUsd <= 0 || precioUsd > 999999) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El precio debe ser un número entre 1 y 999999.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Si estamos editando, usar updateArticulo
      if (widget.articulo != null && widget.articulo!.id != null) {
        final userId = await ApiService.getUserId();
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado.')),
          );
          return;
        }

        final casilleroId = await ApiService.getCasilleroId(userId);
        if (casilleroId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró el casillero del usuario.')),
          );
          return;
        }

        final categoriaFinal = (categoria == 'Ropa' && subcategoria != null)
            ? '$categoria > $subcategoria'
            : categoria;

        final articuloActualizado = Articulo(
          id: widget.articulo!.id,
          nombre: nombre,
          talla: talla,
          categoria: categoriaFinal,
          color: color,
          valorUnitario: precio,
          url: urlImagen,
          peso: peso,
        );

        final resp = await ApiService.updateArticuloInCasillero(casilleroId, widget.articulo!.id!, articuloActualizado);
        if (resp.statusCode == 200 || resp.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Artículo actualizado correctamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar artículo: ${resp.statusCode} - ${resp.body}')),
          );
        }
      } else {
        // Añadir nuevo (igual que antes)
        final userId = await ApiService.getUserId();
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado.')),
          );
          return;
        }

        final casilleroId = await ApiService.getCasilleroId(userId);
        if (casilleroId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró un casillero para este usuario.')),
          );
          return;
        }

        final categoriaFinal = (categoria == 'Ropa' && subcategoria != null)
            ? '$categoria > $subcategoria'
            : categoria;

        final articulo = Articulo(
          nombre: nombre,
          talla: talla,
          categoria: categoriaFinal,
          color: color,
          valorUnitario: precio,
          url: urlImagen,
          peso: peso,
        );

        final response = await ApiService.addArticulo(casilleroId, articulo);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Artículo guardado correctamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar artículo: ${response.statusCode} - ${response.body}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

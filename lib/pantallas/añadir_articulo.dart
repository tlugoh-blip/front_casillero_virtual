import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/articulo.dart';
import '../widgets/currency_converter.dart';

class AnadirArticuloPantalla extends StatefulWidget {
  const AnadirArticuloPantalla({Key? key}) : super(key: key);

  @override
  State<AnadirArticuloPantalla> createState() => _AnadirArticuloPantallaState();
}

class _AnadirArticuloPantallaState extends State<AnadirArticuloPantalla> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();

  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  final List<String> _categorias = ['Ropa', 'Calzado', 'Accesorios'];

  // Subcategorías por categoría
  final Map<String, List<String>> _subcategorias = {
    'Ropa': ['Buso', 'Chaqueta', 'Pantaloneta', 'Pantalón', 'Camisa'],
    'Calzado': ['Tenis', 'Sandalias', 'Botas'],
    'Accesorios': ['Gorra', 'Cinturón', 'Bolso'],
  };

  // Pesos estimados en libras por subcategoría (valores aproximados)
  final Map<String, double> _pesoEstimado = {
    'Buso': 0.6,
    'Chaqueta': 1.2,
    'Pantaloneta': 0.4,
    'Pantalón': 0.8,
    'Camisa': 0.5,
    'Tenis': 0.8,
    'Sandalias': 0.3,
    'Botas': 1.5,
    'Gorra': 0.15,
    'Cinturón': 0.4,
    'Bolso': 0.7,
  };

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);
    const azulClaro = Color(0xFF0E3E8A);

    return Scaffold(
      backgroundColor: azulFondo,
      appBar: AppBar(
        backgroundColor: azulFondo,
        elevation: 0,
        // Se elimina el título "Mi casillero"
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

                    // Categoría Dropdown (ahora aparece justo después de Color)
                    DropdownButtonFormField<String>(
                      initialValue: _categoriaSeleccionada,
                      dropdownColor: azulClaro,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: _categorias
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoriaSeleccionada = value;
                          // reset subcategoria y peso cuando cambia la categoría
                          _subcategoriaSeleccionada = null;
                          _pesoController.text = '';
                        });
                      },
                    ),

                    const SizedBox(height: 12),
                    // Si se seleccionó una categoría, mostrar subcategorías (si existen)
                    if (_categoriaSeleccionada != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _subcategoriaSeleccionada,
                              dropdownColor: azulClaro,
                              decoration: const InputDecoration(
                                labelText: 'Subcategoría',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: (_subcategorias[_categoriaSeleccionada] ?? [])
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _subcategoriaSeleccionada = value;
                                  // Pre-fill peso estimado si existe
                                  if (value != null && _pesoEstimado.containsKey(value)) {
                                    _pesoController.text = _pesoEstimado[value]!.toStringAsFixed(2);
                                  } else {
                                    _pesoController.text = '';
                                  }
                                });
                              },
                            ),

                            const SizedBox(height: 12),
                            // Campo Peso (prefill sugerido, editable)
                            TextField(
                              controller: _pesoController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Peso (libras)',
                                labelStyle: const TextStyle(color: Colors.white),
                                hintText: _subcategoriaSeleccionada != null ? 'Peso estimado para $_subcategoriaSeleccionada' : 'Introduce peso en libras',
                                hintStyle: const TextStyle(color: Colors.white54),
                                suffixIcon: const Icon(Icons.scale, color: Colors.white),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Campo Precio: ahora el usuario ingresa en USD y mostramos el equivalente en COP
                    TextField(
                      controller: _precioController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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

  Future<void> _guardarArticulo() async {
    final nombre = _nombreController.text.trim();
    final talla = _tallaController.text.trim();
    final color = _colorController.text.trim();
    // Precio ingresado por el usuario en USD -> convertir a COP para el backend
    final precioUsd = double.tryParse(_precioController.text.trim()) ?? 0.0;
    final precio = CurrencyConverter.usdToCop(precioUsd);
    final peso = double.tryParse(_pesoController.text.trim()) ?? 0.0;
    final categoria = _categoriaSeleccionada;
    final urlImagen = _urlController.text.trim();

    if (nombre.isEmpty || talla.isEmpty || color.isEmpty || precioUsd == 0.0 || peso == 0.0 || categoria == null || urlImagen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await ApiService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado.')),
        );
        return;
      }

      //  Nuevo paso: obtener el ID del casillero desde el backend
      final casilleroId = await ApiService.getCasilleroId(userId);
      if (casilleroId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró un casillero para este usuario.')),
        );
        return;
      }

      // Crear objeto artículo
      final articulo = Articulo(
        nombre: nombre,
        talla: talla,
        categoria: categoria,
        color: color,
        valorUnitario: precio,
        url: urlImagen,
        peso: peso,
      );

      //  Enviar el artículo al casillero correcto
      final response = await ApiService.addArticulo(casilleroId, articulo);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Artículo guardado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar artículo: ${response.statusCode}')),
        );
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

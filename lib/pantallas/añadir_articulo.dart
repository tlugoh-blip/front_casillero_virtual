import 'package:flutter/material.dart';

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

  String? _categoriaSeleccionada;
  final List<String> _categorias = ['Ropa', 'Calzado', 'Accesorios'];

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
                      value: _categoriaSeleccionada,
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('Artículo guardado correctamente'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
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
}

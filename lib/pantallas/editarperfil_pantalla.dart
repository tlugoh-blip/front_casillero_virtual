import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/api_service.dart';

class EditarPerfilPantalla extends StatefulWidget {
  const EditarPerfilPantalla({Key? key}) : super(key: key);

  @override
  _EditarPerfilPantallaState createState() => _EditarPerfilPantallaState();
}

class _EditarPerfilPantallaState extends State<EditarPerfilPantalla> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String _base64Image = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await ApiService.getUserId();
      if (userId != null) {
        final userData = await ApiService.getUsuario(userId);
        if (userData != null) {
          setState(() {
            // Mapeo según el JSON de ejemplo: 'elNombre', 'apellidos', 'cedula', 'email', 'telefono', 'contrasenia', 'direccionEntrega', 'imagen'
            _nombreController.text = userData['elNombre'] ?? '';
            _apellidosController.text = userData['apellidos'] ?? '';
            _cedulaController.text = userData['cedula'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _telefonoController.text = userData['telefono'] ?? '';
            _direccionController.text = userData['direccionEntrega'] ?? '';
            // Aquí asignamos la imagen Base64 que viene del backend
            _base64Image = (userData['imagen'] ?? '').toString().replaceAll('\n', '').replaceAll('\r', '').trim();
            if ((userData['imagen'] ?? '').toString().length > 100) {
              print("IMAGEN BASE64 RECIBIDA (primeros 100 caracteres): ${userData['imagen']?.toString().substring(0, 100)}...");
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  // El método para seleccionar imagen no está disponible en web
  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad no disponible en web')),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await ApiService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no identificado')),
        );
        return;
      }

      final response = await ApiService.updateUsuario(
        id: userId,
        nombre: _nombreController.text,
        apellidos: _apellidosController.text.isNotEmpty ? _apellidosController.text : null,
        cedula: _cedulaController.text.isNotEmpty ? _cedulaController.text : null,
        email: _emailController.text,
        telefono: _telefonoController.text,
        direccionEntrega: _direccionController.text,
        imagen: _base64Image.isNotEmpty ? _base64Image : null,
      );

      // Mostrar información de depuración y cuerpo de respuesta
      print('DEBUG UI: Update response status: ${response.statusCode}');
      print('DEBUG UI: Update response body: ${response.body}');

      String respPreview = response.body;
      if (respPreview.length > 200) respPreview = respPreview.substring(0, 200) + '...';

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado exitosamente. Respuesta: $respPreview')),
        );

        // Refrescar los datos desde el servidor para verificar si la BD cambió
        await _loadUserData();

        // Si quieres, puedes cerrar la pantalla después de una comprobación manual
        // Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: ${response.statusCode} - $respPreview')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366), // Azul oscuro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo Upper (nuevo upperblanco más grande)
                  Image.asset(
                    'assets/imagenes/upperblanco.png',
                    height: 79, // Aumentado el tamaño
                    fit: BoxFit.contain,
                  ),
                  // Botón cerrar
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Título
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Editar Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Imagen de perfil con botón de cámara
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipOval(
                    child: Container(
                      width: 112,
                      height: 112,
                      color: Colors.white,
                      child: _base64Image.isNotEmpty
                          ? Image.network(
                              'data:image/jpeg;base64,$_base64Image',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('⚠️ Error al mostrar imagen: $error');
                                return const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              size: 56,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickImage, // Solo muestra mensaje
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Campos de texto
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Orden: nombre (primero), apellidos, cedula, email, telefono, direccionEntrega
                      _buildTextField('Nombre', _nombreController),
                      const SizedBox(height: 16),
                      _buildTextField('Apellidos', _apellidosController),
                      const SizedBox(height: 16),
                      _buildTextField('Cédula', _cedulaController),
                      const SizedBox(height: 16),
                      _buildTextField('Email', _emailController),
                      const SizedBox(height: 16),
                      _buildTextField('Teléfono', _telefonoController),
                      const SizedBox(height: 16),
                      _buildTextField('Dirección de delivery', _direccionController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

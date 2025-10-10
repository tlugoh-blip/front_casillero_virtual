import 'package:flutter/material.dart';
import '../api_service.dart';

class RegistrarPantalla extends StatefulWidget {
  const RegistrarPantalla({super.key});

  @override
  State<RegistrarPantalla> createState() => _RegistrarPantallaState();
}

class _RegistrarPantallaState extends State<RegistrarPantalla> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final TextEditingController confirmarClaveController = TextEditingController();
  bool ocultarClave = true;
  bool ocultarConfirmarClave = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  'assets/imagenes/logo_upper.jpeg',
                  height: 200, // Logo más grande
                ),
                const SizedBox(height: 8), // Menos espacio debajo del logo
                const Text(
                  'Registrate',
                  style: TextStyle(
                    fontSize: 26, // Letra más pequeña
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Empieza completando los siguientes campos.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    hintText: 'Nombre completo',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Teléfono',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Correo electronico',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: claveController,
                  obscureText: ocultarClave,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarClave ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black38,
                      ),
                      onPressed: () {
                        setState(() {
                          ocultarClave = !ocultarClave;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmarClaveController,
                  obscureText: ocultarConfirmarClave,
                  decoration: InputDecoration(
                    hintText: 'Confirmar contraseña',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarConfirmarClave ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black38,
                      ),
                      onPressed: () {
                        setState(() {
                          ocultarConfirmarClave = !ocultarConfirmarClave;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23408E),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final nombre = nombreController.text.trim();
                      final telefono = telefonoController.text.trim();
                      final email = correoController.text.trim();
                      final contrasenia = claveController.text;
                      final confirmar = confirmarClaveController.text;
                      if (nombre.isEmpty || telefono.isEmpty || email.isEmpty || contrasenia.isEmpty || confirmar.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, completa todos los campos.')),
                        );
                        return;
                      }
                      if (contrasenia != confirmar) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Las contraseñas no coinciden.')),
                        );
                        return;
                      }
                      try {
                        final response = await ApiService.register(
                          nombre: nombre,
                          telefono: telefono,
                          email: email,
                          contrasenia: contrasenia,
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
                          );
                          // Puedes navegar a la pantalla de login aquí si lo deseas
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ' + (response.body.isNotEmpty ? response.body : 'No se pudo registrar.'))),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error de conexión: $e')),
                        );
                      }
                    },
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: navegar a login
                      },
                      child: const Text(
                        'Inicia sesión aquí',
                        style: TextStyle(
                          color: Color(0xFF23408E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

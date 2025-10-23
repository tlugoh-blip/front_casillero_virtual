import 'package:flutter/material.dart';
import '../api_service.dart';

class RegistrarPantalla extends StatefulWidget {
  const RegistrarPantalla({super.key});

  @override
  State<RegistrarPantalla> createState() => _RegistrarPantallaState();
}

class _RegistrarPantallaState extends State<RegistrarPantalla> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final TextEditingController confirmarClaveController = TextEditingController();
  final TextEditingController fechaNacimientoController = TextEditingController();
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
                // Botón de devolver
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF23408E)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/imagenes/logo_upper.jpeg',
                  height: 200, // Logo más grande
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registrate',
                  style: TextStyle(
                    fontSize: 26,
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
                // Campo nombre
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    hintText: 'Nombre',
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
                // Campo apellido
                TextField(
                  controller: apellidoController,
                  decoration: InputDecoration(
                    hintText: 'Apellido',
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
                // Campo cédula
                TextField(
                  controller: cedulaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Cédula',
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
                // Campo teléfono
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
                // Campo correo
                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
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
                // Campo contraseña
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
                // Campo confirmar contraseña
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
                const SizedBox(height: 16),
                // Campo fecha de nacimiento
                TextField(
                  controller: fechaNacimientoController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    hintText: 'Fecha de nacimiento (yyyy-MM-dd)',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
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
                      final apellidos = apellidoController.text.trim();
                      final cedula = cedulaController.text.trim();
                      final telefono = telefonoController.text.trim();
                      final email = correoController.text.trim();
                      final contrasenia = claveController.text;
                      final confirmar = confirmarClaveController.text;
                      final fechaNacimiento = fechaNacimientoController.text.trim();
                      if (nombre.isEmpty || apellidos.isEmpty || cedula.isEmpty || telefono.isEmpty || email.isEmpty || contrasenia.isEmpty || confirmar.isEmpty || fechaNacimiento.isEmpty) {
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
                          apellidos: apellidos,
                          cedula: cedula,
                          email: email,
                          telefono: telefono,
                          contrasenia: contrasenia,
                          fechaNacimiento: fechaNacimiento,
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
                          );
                          Navigator.pushReplacementNamed(context, '/login'); // Cambiado para redirigir a la pantalla de inicio de sesión
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
                        Navigator.pushReplacementNamed(context, '/login');
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

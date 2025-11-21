import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';

// Formatter para fecha de nacimiento en formato yyyy/MM/dd
class BirthDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Mantener solo dígitos
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    // Construir partes
    final year = digits.length >= 4 ? digits.substring(0, 4) : digits;
    final month = digits.length >= 5 ? (digits.length >= 6 ? digits.substring(4, 6) : digits.substring(4)) : '';
    final day = digits.length >= 7 ? digits.substring(6) : '';

    String formatted = year;
    if (month.isNotEmpty) formatted += '/$month';
    if (day.isNotEmpty) formatted += '/$day';

    // Colocar el cursor al final (suficiente para este uso simple)
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

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
                // Campo nombre (solo letras, espacios, guion y apóstrofe)
                TextField(
                  controller: nombreController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÁÉÍÓÚáéíóúÑñüÜ\s'-]")),
                    LengthLimitingTextInputFormatter(50),
                  ],
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
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÁÉÍÓÚáéíóúÑñüÜ\s'-]")),
                    LengthLimitingTextInputFormatter(50),
                  ],
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
                // Campo cédula (solo dígitos, máximo 10)
                TextField(
                  controller: cedulaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8), // limitar dígitos a 8 (yyyy MM dd)
                    BirthDateInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Fecha de nacimiento (yyyy/MM/dd)',
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

                      // Validar que cédula y teléfono sean exactamente 10 dígitos numéricos
                      final RegExp tenDigits = RegExp(r'^\d{10}$');
                      if (!tenDigits.hasMatch(cedula)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('La cédula debe contener exactamente 10 dígitos numéricos.')),
                        );
                        return;
                      }
                      if (!tenDigits.hasMatch(telefono)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El teléfono debe contener exactamente 10 dígitos numéricos.')),
                        );
                        return;
                      }

                      // Validar formato de correo electrónico (más permisiva: permite TLD largos y más caracteres en local-part)
                      final RegExp emailRegExp = RegExp(
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
                      );
                      if (!emailRegExp.hasMatch(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El correo electrónico no tiene un formato válido.')),
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

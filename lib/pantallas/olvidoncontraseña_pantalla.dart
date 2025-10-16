import 'package:flutter/material.dart';

class OlvidoContrasenaPantalla extends StatefulWidget {
  const OlvidoContrasenaPantalla({Key? key}) : super(key: key);

  @override
  _OlvidoContrasenaPantallaState createState() => _OlvidoContrasenaPantallaState();
}

class _OlvidoContrasenaPantallaState extends State<OlvidoContrasenaPantalla> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _recuperarContrasena() async {
    setState(() {
      _isLoading = true;
    });

    // Simulación del proceso de recuperación
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Correo de recuperación enviado correctamente"),
        backgroundColor: Colors.green,
      ),
    );

    // Aquí puedes redirigir a otra pantalla
    // Navigator.pushNamed(context, '/restablecer_contrasena');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366), // Fondo azul oscuro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Logo y icono perfil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/imagenes/upperblanco.png',
                    height: 79,
                    fit: BoxFit.contain,
                  ),
                  const Icon(Icons.person, color: Colors.white, size: 32),
                ],
              ),

              const SizedBox(height: 32),

              // Título principal
              const Text(
                "Olvidé contraseña",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Ingresa tu correo electrónico para\nrestablecer tu contraseña",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // Campo: Correo electrónico
              _buildTextField("Correo electrónico", _emailController),

              const SizedBox(height: 20),

              // Campo: Confirmar correo
              _buildTextField("Confirmar correo electrónico", _confirmEmailController),

              const SizedBox(height: 40),

              // Botón de recuperación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _recuperarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Recuperar",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Texto final
              const Text(
                "Revisa tu bandeja de entrada después de enviar.",
                style: TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "ejemplo@correo.com",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

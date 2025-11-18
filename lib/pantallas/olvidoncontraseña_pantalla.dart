import 'package:flutter/material.dart';

class OlvidoContrasenaPantalla extends StatelessWidget {
  const OlvidoContrasenaPantalla({Key? key}) : super(key: key);

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
                  // Botón para volver a Login
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      // Navegar a la pantalla de login reemplazando la actual
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),

                  // Logo centrado
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/imagenes/upperblanco.png',
                        height: 85,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Icono de perfil (espaciado fijo para mantener equilibrio visual)
                  const SizedBox(
                    width: 48,
                    child: Center(child: Icon(Icons.person, color: Colors.white, size: 32)),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Título principal
              const Text(
                "Olvidé contraseña",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26, // reducido de 32 a 26
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
              _buildTextField("Correo electrónico"),

              const SizedBox(height: 20),

              // Campo: Confirmar correo
              _buildTextField("Confirmar correo electrónico"),

              const SizedBox(height: 40),

              // Botón de recuperación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Acción del botón eliminada
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
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

  Widget _buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "ejemplo@correo.com",
            hintStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.15),
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

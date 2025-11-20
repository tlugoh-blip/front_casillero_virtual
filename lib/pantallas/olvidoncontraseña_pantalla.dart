import 'package:flutter/material.dart';
import '../api_service.dart';

class OlvidoContrasenaPantalla extends StatefulWidget {
  const OlvidoContrasenaPantalla({Key? key}) : super(key: key);

  @override
  State<OlvidoContrasenaPantalla> createState() => _OlvidoContrasenaPantallaState();
}

class _OlvidoContrasenaPantallaState extends State<OlvidoContrasenaPantalla> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();

  bool loading = false;

  // =====================================================
  // 1. Buscar usuario por correo
  // 2. Tomar el ID
  // 3. Llamar a enviarContrasenia(id)
  // =====================================================
  Future<void> enviarCorreo() async {
    final email = emailController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (email.isEmpty || confirmar.isEmpty) {
      _mostrarAlerta("Error", "Debes completar ambos campos.");
      return;
    }

    if (email != confirmar) {
      _mostrarAlerta("Error", "Los correos no coinciden.");
      return;
    }

    setState(() => loading = true);

    try {
      // 1️⃣ Obtener ID del usuario por email
      final int? userId = await ApiService.getIdPorEmail(email);

      if (userId == null) {
        _mostrarAlerta("Error", "No existe un usuario con ese correo.");
        setState(() => loading = false);
        return;
      }

      // 2️⃣ Enviar contraseña al correo
      final mensaje = await ApiService.enviarContrasenia(userId);

      // Mostrar alerta y al aceptar redirigir al login
      _mostrarAlerta("Éxito", mensaje, onOk: () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      _mostrarAlerta("Error", "Ocurrió un problema al procesar la solicitud.");
    }

    setState(() => loading = false);
  }

  void _mostrarAlerta(String titulo, String mensaje, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),

                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/imagenes/upperblanco.png',
                        height: 85,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 48,
                    child: Center(child: Icon(Icons.person, color: Colors.white, size: 32)),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                "Olvidé contraseña",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Ingresa tu correo electrónico para\nrecibir tu contraseña",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 40),

              _buildTextField("Correo electrónico", emailController),
              const SizedBox(height: 20),
              _buildTextField("Confirmar correo electrónico", confirmarController),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : enviarCorreo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: loading
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
            hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
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

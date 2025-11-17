import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'login_pantalla.dart';
import 'Registrar_pantalla.dart';

class WelcomePantalla extends StatelessWidget {
  const WelcomePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imagenes/fondo_welcome.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Espacio grande para separar de la imagen superior
                const SizedBox(height: 120),
                CustomButton(
                  text: "Iniciar Sesión",
                  color: Colors.white,
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPantalla()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "Registrarse",
                  color: Colors.white,
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrarPantalla()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Botón de desarrollo para explorar rápidamente todas las pantallas
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  onPressed: () {
                    // Navega al launcher ('/') que contiene los botones para revisar todas las pantallas
                    Navigator.pushNamed(context, '/');
                  },
                  child: const Text('Explorar pantallas (dev)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

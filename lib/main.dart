import 'package:flutter/material.dart';
import 'pantallas/login_pantalla.dart';
import 'pantallas/olvidoncontraseña_pantalla.dart';
import 'pantallas/home_pantalla.dart';
import 'pantallas/Registrar_pantalla.dart';
import 'pantallas/casillero_pantalla.dart';
import 'pantallas/pagos_pantalla.dart';
import 'pantallas/añadir_articulo.dart'; // ✅ cambiado (sin ñ y con guion bajo)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casillero Virtual',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',

      routes: {
        '/': (context) => const LauncherPantalla(),
        '/login': (context) => const LoginPantalla(),
        '/olvidocontrasena': (context) => const OlvidoContrasenaPantalla(),
        '/home': (context) => const HomePantalla(),
        '/register': (context) => const RegistrarPantalla(),
        '/casillero': (context) => const CasilleroPantalla(),
        '/pagos': (context) => const PagosPantalla(),
        '/anadirarticulo': (context) => const AnadirArticuloPantalla(), // ✅ corregido
      },
    );
  }
}

// 🔹 Pantalla simple de pruebas
class LauncherPantalla extends StatelessWidget {
  const LauncherPantalla({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selector de pantallas'),
        backgroundColor: const Color(0xFF23408E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Abrir Login'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Abrir Registro'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/olvidocontrasena'),
                  child: const Text('Abrir Olvidé contraseña'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  child: const Text('Abrir Home'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/casillero'),
                  child: const Text('Abrir Casillero'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/pagos'),
                  child: const Text('Abrir Pagos'),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ NUEVO BOTÓN
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/anadirarticulo'),
                  child: const Text('Abrir Añadir Artículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

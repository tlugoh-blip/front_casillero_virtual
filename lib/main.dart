import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/pantallas/historial_pantalla.dart';

import 'pantallas/login_pantalla.dart';
import 'pantallas/olvidoncontraseña_pantalla.dart';
import 'pantallas/home_pantalla.dart';
import 'pantallas/Registrar_pantalla.dart';
import 'pantallas/casillero_pantalla.dart';
import 'pantallas/pagos_pantalla.dart';
import 'pantallas/estado_pantalla.dart';
import 'pantallas/añadir_articulo.dart';
import 'pantallas/welcome_pantalla.dart';
import 'pantallas/editar_articulo.dart';
import 'models/articulo.dart';
import 'pantallas/metodos_pago_pantalla.dart';

// 🔹 Nueva pantalla que creamos
import 'pantallas/TarjetaCreditoPantalla.dart';

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
      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomePantalla(),
        '/': (context) => const LauncherPantalla(),
        '/login': (context) => const LoginPantalla(),
        '/olvidocontrasena': (context) => const OlvidoContrasenaPantalla(),
        '/home': (context) => const HomePantalla(),
        '/register': (context) => const RegistrarPantalla(),
        '/casillero': (context) => const CasilleroPantalla(),
        '/pagos': (context) => const PagosPantalla(),
        '/metodos_pago': (context) => const MetodosPagoPantalla(),
        '/estado': (context) => const EstadoPantalla(),
        '/historial': (context) => const HistorialPantalla(),
        '/anadirarticulo': (context) => const AnadirArticuloPantalla(),
        '/editararticulo': (context) {
          final articuloArg = ModalRoute.of(context)!.settings.arguments as Articulo?;
          return EditarArticuloPantalla(articulo: articuloArg);
        },

        // ⭐ NUEVA RUTA PARA LA PANTALLA DE TARJETA DE CRÉDITO
        '/tarjeta_credito': (context) => const TarjetaCreditoPantalla(),
      },
    );
  }
}

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

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/anadirarticulo'),
                  child: const Text('Abrir Añadir Artículo'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/metodos_pago'),
                  child: const Text('Abrir Métodos de pago'),
                ),
              ),

              const SizedBox(height: 12),

              // ⭐ BOTÓN PARA PROBAR LA NUEVA PANTALLA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/tarjeta_credito'),
                  child: const Text('Abrir Tarjeta de Crédito'),
                ),
              ),

              const SizedBox(height: 12),

              // ⭐ BOTÓN PARA PROBAR LA NUEVA PANTALLA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/estado'),
                  child: const Text('Abrir Estado del Pedido'),
                ),
              ),

              const SizedBox(height: 12),

              // ⭐ BOTÓN PARA PROBAR LA NUEVA PANTALLA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/historial'),
                  child: const Text('Abrir Historial Compras'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

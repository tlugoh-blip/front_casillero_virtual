import 'package:flutter/material.dart';
import 'pantallas/login_pantalla.dart';
import 'pantallas/olvidoncontraseña_pantalla.dart'; // Asegúrate de que el nombre del archivo esté bien escrito

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

      // Pantalla inicial
      initialRoute: '/login',

      // Rutas de navegación
      routes: {
        '/login': (context) => const LoginPantalla(),
        '/olvidocontrasena': (context) => const OlvidoContrasenaPantalla(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/pantallas/login_pantalla.dart';
import 'pantallas/welcome_pantalla.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePantalla(),
      routes: {
        '/welcome': (context) => const WelcomePantalla(),
        // Puedes agregar más rutas aquí si lo necesitas
      },
    );
  }
}

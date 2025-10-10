import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/pantallas/login_pantalla.dart';
import 'pantallas/home_pantalla.dart';
import 'pantallas/welcome_pantalla.dart';
import 'pantallas/Registrar_pantalla.dart';

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
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePantalla(),
        '/login': (context) => const LoginPantalla(),
        '/register': (context) => const RegistrarPantalla(),
        '/home': (context) => const HomePantalla(),
      },
    );
  }
}
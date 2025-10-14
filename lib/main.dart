import 'package:flutter/material.dart';
import 'pantallas/home_pantalla.dart';
import 'pantallas/editarperfil_pantalla.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Upper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePantalla(),
        '/editar-perfil': (context) => const EditarPerfilPantalla(),
      },
    );
  }
}
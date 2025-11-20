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
import 'pantallas/costo_importacion_pantalla.dart';

// ⭐ Nuevas pantallas
import 'pantallas/TarjetaCreditoPantalla.dart';
import 'pantallas/TarjetaDebitoPantalla.dart';

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
        '/costo_import': (context) => const CostoImportacionPantalla(),
        '/estado': (context) => const EstadoPantalla(),
        '/historial': (context) => const HistorialPantalla(),
        '/anadirarticulo': (context) => const AnadirArticuloPantalla(),

        '/editararticulo': (context) {
          final articuloArg =
          ModalRoute.of(context)!.settings.arguments as Articulo?;
          return EditarArticuloPantalla(articulo: articuloArg);
        },

        // ⭐ Rutas nuevas
        '/tarjeta_credito': (context) => const TarjetaCreditoPantalla(),
        '/tarjeta_debito': (context) => const TarjetaDebitoPantalla(),
      },
    );
  }
}

class LauncherPantalla extends StatelessWidget {
  const LauncherPantalla({Key? key}) : super(key: key);

  Widget _buildButton(BuildContext context, String label, String route, {bool outlined = false}) {
    final btn = outlined
        ? OutlinedButton(onPressed: () => Navigator.pushNamed(context, route), child: Text(label))
        : ElevatedButton(onPressed: () => Navigator.pushNamed(context, route), child: Text(label));
    return SizedBox(width: double.infinity, child: btn);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Abrir Login', 'route': '/login', 'outlined': false},
      {'label': 'Abrir Registro', 'route': '/register', 'outlined': false},
      {'label': 'Abrir Olvidé contraseña', 'route': '/olvidocontrasena', 'outlined': false},
      {'label': 'Abrir Home', 'route': '/home', 'outlined': true},
      {'label': 'Abrir Casillero', 'route': '/casillero', 'outlined': true},
      {'label': 'Abrir Pagos', 'route': '/pagos', 'outlined': true},
      {'label': 'Abrir Añadir Artículo', 'route': '/anadirarticulo', 'outlined': true},
      {'label': 'Abrir Métodos de pago', 'route': '/metodos_pago', 'outlined': true},
      {'label': 'Abrir Calculadora de Costo de Importación', 'route': '/costo_import', 'outlined': true},
      {'label': 'Abrir Tarjeta de Crédito', 'route': '/tarjeta_credito', 'outlined': false},
      {'label': 'Abrir Tarjeta de Débito', 'route': '/tarjeta_debito', 'outlined': false},
      {'label': 'Abrir Estado del Pedido', 'route': '/estado', 'outlined': false},
      {'label': 'Abrir Historial Compras', 'route': '/historial', 'outlined': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Selector de pantallas'), backgroundColor: const Color(0xFF23408E)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final it = items[i];
            return _buildButton(ctx, it['label'] as String, it['route'] as String, outlined: it['outlined'] as bool);
          },
        ),
      ),
    );
  }
}

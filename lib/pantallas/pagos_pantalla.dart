import 'package:flutter/material.dart';

class PagosPantalla extends StatelessWidget {
  const PagosPantalla({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Aquí irán las opciones de pago y resumen de transacciones',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}


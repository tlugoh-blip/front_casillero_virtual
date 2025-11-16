import 'package:flutter/material.dart';

class TarjetaCreditoPantalla extends StatefulWidget {
  const TarjetaCreditoPantalla({Key? key}) : super(key: key);

  @override
  State<TarjetaCreditoPantalla> createState() => _TarjetaCreditoPantallaState();
}

class _TarjetaCreditoPantallaState extends State<TarjetaCreditoPantalla> {
  final Color azulFondo = const Color(0xFF0A57D0);
  final Color azulOscuro = const Color(0xFF0648A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: SingleChildScrollView( // 🔹 evita overflow en pantallas pequeñas
          child: Column(
            children: [
              // BOTÓN REGRESAR
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // TÍTULO
              const Text(
                "Tarjeta de crédito",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              // IMAGEN DE TARJETA
              // IMAGEN DE TARJETA
              Container(
                width: 350,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge, // 🔥 IMPORTANTE: recorta bordes para que la imagen ocupe todo
                child: Image.asset(
                  "assets/imagenes/credito.png",
                  fit: BoxFit.cover, // 🔥 La imagen ahora SÍ llena todo el contenedor
                ),
              ),

              const SizedBox(height: 24),

              // FORMULARIO
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                decoration: BoxDecoration(
                  color: azulOscuro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputCampo("Número de tarjeta"),
                    const SizedBox(height: 18),
                    _inputCampo("Fecha de expiración (MM/AA)"),
                    const SizedBox(height: 18),
                    _inputCampo("Código CVC"),
                    const SizedBox(height: 18),
                    _inputCampo("Nombre en la tarjeta"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BOTÓN PAGAR
              SizedBox(
                width: double.infinity,
                height: 62,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B66FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Pagar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 WIDGET DE CAMPO EDITABLE
  Widget _inputCampo(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        TextField(
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

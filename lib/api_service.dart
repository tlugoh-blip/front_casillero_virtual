import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia esta URL por la de tu backend real
  static const String baseUrl = 'http://localhost:8620';

  // Ejemplo de función para login
  static Future<http.Response> login(String email, String contrasenia) async {
    final url = Uri.parse('$baseUrl/usuario/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'contrasenia': contrasenia}),
    );
    return response;
  }

  // Función para registrar usuario con todos los campos de la pantalla
  static Future<http.Response> register({
    required String nombre,
    required String telefono,
    required String email,
    required String contrasenia,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
        'contrasenia': contrasenia,
      }),
    );
    return response;
  }

  // Puedes agregar más funciones para otros endpoints aquí
}

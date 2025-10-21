import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    required String apellidos,
    required String cedula,
    required String email,
    required String telefono,
    required String contrasenia,
    required String fechaNacimiento, // formato: yyyy-MM-dd
  }) async {
    final url = Uri.parse('$baseUrl/usuario/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'elNombre': nombre,
        'apellidos': apellidos,
        'cedula': cedula,
        'email': email,
        'telefono': telefono,
        'contrasenia': contrasenia,
        'fechaNacimiento': fechaNacimiento,
      }),
    );
    return response;
  }

  // Función para buscar artículos. Se puede buscar por texto (query) o por categoria.
  static Future<http.Response> searchArticles({String? query, String? categoria}) async {
    final Map<String, String> params = {};
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (categoria != null && categoria.trim().isNotEmpty) params['categoria'] = categoria.trim();

    Uri uri = Uri.parse('$baseUrl/articulo/search');
    if (params.isNotEmpty) uri = uri.replace(queryParameters: params);

    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    return response;
  }

  // Función para agregar artículo
  // Enviamos únicamente los campos esperados por la entidad `articulo` del backend:
  // elNombre, talla, categoria (minúscula), valorUnitario (int COP), url, peso (double), color
  static Future<http.Response> addArticle({
    required String nombre,
    required String talla,
    required String color,
    required String categoria,
    required String url,
    required int valorUnitario, // en COP, entero
    required double peso, // en kg
  }) async {
    final uri = Uri.parse('$baseUrl/articulo/add');

    final Map<String, dynamic> body = {
      'nombre': nombre,
      'talla': talla,
      // enviar categoria en minúsculas para consistencia
      'categoria': categoria.toLowerCase(),
      'valorUnitario': valorUnitario,
      // 'url': url, // añadiremos condicionalmente
      'peso': peso,
      'color': color,
    };

    // Si la URL es una data URL (base64) la omitimos y la dejamos que el backend trate otro flujo de imagen
    try {
      if (url != null && url.trim().isNotEmpty && !url.trim().toLowerCase().startsWith('data:')) {
        body['url'] = url;
      } else if (url != null && url.trim().toLowerCase().startsWith('data:')) {
        // Debug: notificar que omitimos la data URL para evitar errores de tamaño
        print('[ApiService.addArticle] Omitiendo campo url porque contiene una data URL (base64).');
      }
    } catch (_) {}

    // Debug: imprimir body antes de enviar (quitar en producción)
    try {
      print('[ApiService.addArticle] POST $uri');
      print('[ApiService.addArticle] body: ' + jsonEncode(body));
    } catch (_) {}

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Debug: imprimir respuesta del servidor
    try {
      print('[ApiService.addArticle] response: ${response.statusCode}');
      print('[ApiService.addArticle] response body: ${response.body}');
      try {
        final parsed = jsonDecode(response.body);
        print('[ApiService.addArticle] parsed response: $parsed');
      } catch (_) {}
    } catch (_) {}

    return response;
  }

  // Función para actualizar usuario
  static Future<http.Response> updateUsuario({
    required int id,
    required String nombre,
    required String email,
    required String telefono,
    required String direccionEntrega,
    String? imagen, // base64 string, optional
  }) async {
    final url = Uri.parse('$baseUrl/usuario/update/$id');
    final body = {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccionEntrega': direccionEntrega,
    };
    if (imagen != null) {
      body['imagen'] = imagen;
    }
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response;
  }

  // Función para obtener el ID del usuario guardado en shared preferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Función para guardar el ID del usuario en shared preferences (usar después del login)
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
  }

  // Función para obtener datos del usuario por ID
  static Future<Map<String, dynamic>?> getUsuario(int id) async {
    final url = Uri.parse('$baseUrl/usuario/get/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Puedes agregar más funciones para otros endpoints aquí
}

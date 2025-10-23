import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/articulo.dart';

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

  // Función para obtener el ID del casillero asociado a un usuario
  static Future<int?> getCasilleroId(int userId) async {
    final url = Uri.parse('$baseUrl/casillero/id/$userId'); // endpoint correcto
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['casilleroId']; // clave correcta
    } else {
      print('Error al obtener casillero: ${response.statusCode}');
      return null;
    }
  }

  // Función para añadir artículo a un casillero (usando userId como casilleroId)
  static Future<http.Response> addArticulo(int casilleroId, Articulo articulo) async {
    final url = Uri.parse('$baseUrl/articulo/add/$casilleroId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
    return response;
  }

  // Función para obtener artículos por casillero (usando userId como casilleroId)
  static Future<List<Articulo>> getArticulosPorCasillero(int casilleroId) async {
    // URL corregida
    final url = Uri.parse('$baseUrl/articulo/get/$casilleroId');
    final response = await http.get(url);

    print("Respuesta cruda de la API: ${response.body}"); // depuración

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      print("JSON parseado: $jsonData"); // depuración
      return jsonData.map((e) => Articulo.fromJson(e)).toList();
    } else {
      print("Error HTTP: ${response.statusCode}");
      throw Exception('Error al cargar los artículos');
    }
  }

}

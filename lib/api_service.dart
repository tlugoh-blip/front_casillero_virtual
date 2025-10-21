import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Cambia esta URL por la de tu backend real
  static const String baseUrl = 'http://localhost:8620';
  // Logo por defecto que usaremos si no se envía una URL
  static const String defaultLogoUrl = 'https://upload.wikimedia.org/wikipedia/commons/2/20/Adidas_Logo.svg';

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
  static Future<http.Response> searchArticles({String? query, String? categoria, int? casilleroId}) async {
    // casilleroId puede pasarse explícitamente; si no se pasa intentamos leerlo de SharedPreferences
    int? id = casilleroId ?? await getUserId();
    if (id == null) {
      final body = jsonEncode({'error': 'casilleroId no disponible'});
      print('[ApiService.searchArticles] casilleroId no disponible');
      return http.Response(body, 400, headers: {'Content-Type': 'application/json'});
    }

    final Map<String, String> params = {'casilleroId': id.toString()};
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (categoria != null && categoria.trim().isNotEmpty) params['categoria'] = categoria.trim();

    final uri = Uri.parse('$baseUrl/articulo/search').replace(queryParameters: params);
    try {
      print('[ApiService.searchArticles] GET $uri');
      final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});
      print('[ApiService.searchArticles] response: ${resp.statusCode}');
      print('[ApiService.searchArticles] body: ${resp.body}');
      return resp;
    } catch (e) {
      print('[ApiService.searchArticles] error: $e');
      rethrow;
    }
  }

  // Función para agregar artículo
  // Ahora requiere userId para asociarlo al casillero del usuario (se pasa en la ruta)
  static Future<http.Response> addArticle({
    required int casilleroId,
    required String nombre,
    required String talla,
    required String color,
    required String categoria,
    String? url,
    required int valorUnitario, // en COP, entero
    required double peso, // en kg
  }) async {
    final uri = Uri.parse('$baseUrl/articulo/add/$casilleroId');

    final Map<String, dynamic> body = {
      'nombre': nombre,
      'talla': talla,
      'categoria': categoria.toLowerCase(),
      'valorUnitario': valorUnitario,
      'peso': peso,
      'color': color,
      'url': (url != null && url.trim().isNotEmpty && !url.trim().toLowerCase().startsWith('data:')) ? url : defaultLogoUrl,
    };

    try {
      print('[ApiService.addArticle] POST $uri');
      print('[ApiService.addArticle] body: ${jsonEncode(body)}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      print('[ApiService.addArticle] response: ${response.statusCode}');
      print('[ApiService.addArticle] response body: ${response.body}');
      return response;
    } catch (e) {
      print('[ApiService.addArticle] error: $e');
      rethrow;
    }
  }

  // Función para agregar artículo asociado a un usuario
  static Future<http.Response> addArticleByUsuario({
    required int usuarioId,
    required String nombre,
    required String talla,
    required String color,
    required String categoria,
    String? url,
    required int valorUnitario,
    required double peso,
  }) async {
    final String endpoint = '$baseUrl/addByUsuario/$usuarioId';
    final Map<String, dynamic> body = {
      'nombre': nombre,
      'talla': talla,
      'color': color,
      'categoria': categoria,
      'url': url,
      'valorUnitario': valorUnitario,
      'peso': peso,
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  // Obtener artículos asociados a un usuario (casillero)
  static Future<http.Response> getArticlesByUser(int casilleroId) async {
    final uri = Uri.parse('$baseUrl/articulo/get/$casilleroId');
    try {
      print('[ApiService.getArticlesByUser] GET $uri');
      final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});
      print('[ApiService.getArticlesByUser] response: ${resp.statusCode}');
      print('[ApiService.getArticlesByUser] body: ${resp.body}');
      return resp;
    } catch (e) {
      print('[ApiService.getArticlesByUser] error: $e');
      rethrow;
    }
  }

  // Actualizar artículo por id (se incluye userId para validaciones en backend si se desea)
  static Future<http.Response> updateArticle({
    required int articleId,
    required String nombre,
    required String talla,
    required String color,
    required String categoria,
    String? url,
    required int valorUnitario,
    required double peso,
  }) async {
    final uri = Uri.parse('$baseUrl/articulo/put/$articleId');

    final body = {
      'nombre': nombre,
      'talla': talla,
      'color': color,
      'categoria': categoria.toLowerCase(),
      'valorUnitario': valorUnitario,
      'peso': peso,
      'url': (url != null && url.trim().isNotEmpty &&
          !url.trim().toLowerCase().startsWith('data:'))
          ? url
          : defaultLogoUrl,
    };

    try {
      print('[ApiService.updateArticle] PUT $uri');
      print('[ApiService.updateArticle] body: ${jsonEncode(body)}');
      final resp = await http.put(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );
      print('[ApiService.updateArticle] response: ${resp.statusCode}');
      print('[ApiService.updateArticle] body: ${resp.body}');
      return resp;
    } catch (e) {
      print('[ApiService.updateArticle] error: $e');
      rethrow;
    }
  }

  // Eliminar artículo por id
  static Future<http.Response> deleteArticle(int articleId) async {
    final uri = Uri.parse('$baseUrl/articulo/del/$articleId');
    try {
      print('[ApiService.deleteArticle] DELETE $uri');
      final resp = await http.delete(uri, headers: {'Content-Type': 'application/json'});
      print('[ApiService.deleteArticle] response: ${resp.statusCode}');
      print('[ApiService.deleteArticle] body: ${resp.body}');
      return resp;
    } catch (e) {
      print('[ApiService.deleteArticle] error: $e');
      rethrow;
    }
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

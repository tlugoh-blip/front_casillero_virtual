import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/articulo.dart';

class ApiService {

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

  // Nuevo: eliminar userId de shared preferences (logout local)
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
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
      try {
        final data = jsonDecode(response.body);
        // Soportar distintas formas: { "casilleroId": 5 }, { "id": 5 }, o simplemente 5
        if (data is Map) {
          if (data.containsKey('casilleroId')) return data['casilleroId'];
          if (data.containsKey('id')) return data['id'];
          // buscar primeras key numérica
          for (final v in data.values) {
            if (v is int) return v;
          }
        } else if (data is int) {
          return data;
        } else if (data is String) {
          final parsed = int.tryParse(data);
          if (parsed != null) return parsed;
        }
      } catch (e) {
        // si no es JSON, intentar parsear como entero plano
        final plain = int.tryParse(response.body.trim());
        if (plain != null) return plain;
      }
      return null;
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

  // Nuevo: actualizar un artículo existente
  // Asumo el endpoint PUT /articulo/update/{id}
  static Future<http.Response> updateArticulo(int articuloId, Articulo articulo) async {
    final url = Uri.parse('$baseUrl/articulo/update/$articuloId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
    return response;
  }

  // Nuevo: eliminar un artículo por id
  // Asumo el endpoint DELETE /articulo/delete/{id}
  static Future<http.Response> deleteArticulo(int articuloId) async {
    final url = Uri.parse('$baseUrl/articulo/delete/$articuloId');
    final response = await http.delete(url);
    return response;
  }

  // Nuevo: eliminar un artículo de un casillero específico usando el endpoint
  // /articulo/del/{casilleroId}/{articuloId}
  static Future<http.Response> deleteArticuloFromCasillero(int casilleroId, int articuloId) async {
    final url = Uri.parse('$baseUrl/articulo/del/$casilleroId/$articuloId');
    final response = await http.delete(url);
    try {
      print('[ApiService.deleteArticuloFromCasillero] ${response.statusCode} ${response.body}');
    } catch (_) {}
    return response;
  }

  // Nuevo: actualizar un artículo dentro de un casillero usando /articulo/put/{casilleroId}/{articuloId}
  static Future<http.Response> updateArticuloInCasillero(int casilleroId, int articuloId, Articulo articulo) async {
    final url = Uri.parse('$baseUrl/articulo/put/$casilleroId/$articuloId');
    print('[ApiService.updateArticuloInCasillero] PUT $url');
    print('[ApiService.updateArticuloInCasillero] body: ${jsonEncode(articulo.toJson())}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
    try {
      print('[ApiService.updateArticuloInCasillero] response: ${response.statusCode} ${response.body}');
    } catch (_) {}
    return response;
  }

  // Nuevo método: procesar pago (simulación o persistir según parámetro)
  static Future<Map<String, dynamic>> procesarPago({
    required String metodo,
    required double monto,
    String? numeroTarjeta,
    String? nombre,
    String? fecha,
    String? cvv,
    bool persistir = true,
  }) async {
    final uri = Uri.parse('$baseUrl/pagos/procesar').replace(queryParameters: persistir ? {'persistir': 'true'} : null);

    final body = <String, dynamic>{
      // claves que el backend espera (según PagoRequestDTO)
      'metodoPago': metodo,
      'elNombre': nombre,
      // claves legacy / adicionales por compatibilidad
      'metodo': metodo,
      'nombre': nombre,
      'monto': monto,
      'numeroTarjeta': numeroTarjeta,
      'fecha': fecha,
      'cvv': cvv,
    };

    // DEBUG: imprimir payload
    try {
      print('[ApiService.procesarPago] POST $uri');
      print('[ApiService.procesarPago] body: ${jsonEncode(body)}');
    } catch (_) {}

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // Intentar parsear respuesta JSON y devolver mapa
    try {
      final decoded = jsonDecode(response.body);
      print('[ApiService.procesarPago] response: ${response.statusCode} ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        return {'data': decoded};
      } else {
        throw Exception('Error al procesar pago: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Respuesta inválida del servidor: ${response.body}');
    }
  }

  // Nuevo: obtener historial de pagos
  static Future<List<Map<String, dynamic>>> getPagos() async {
    final url = Uri.parse('$baseUrl/pagos');
    try {
      final response = await http.get(url);
      print('[ApiService.getPagos] GET $url -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded.map((e) => e as Map<String, dynamic>));
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data'].map((e) => e as Map<String, dynamic>));
        } else {
          throw Exception('Formato inesperado de respuesta en getPagos');
        }
      } else {
        throw Exception('Error al obtener pagos: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[ApiService.getPagos] error: $e');
      rethrow;
    }
  }
}

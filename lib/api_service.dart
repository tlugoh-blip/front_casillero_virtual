import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/articulo.dart';

class ApiService {

  static const String baseUrl = 'http://localhost:8620';

  // =======================================================
  // LOGIN
  // =======================================================
  static Future<http.Response> login(String email, String contrasenia) async {
    final url = Uri.parse('$baseUrl/usuario/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'contrasenia': contrasenia}),
    );
  }

  // =======================================================
  // REGISTRO USUARIO
  // =======================================================
  static Future<http.Response> register({
    required String nombre,
    required String apellidos,
    required String cedula,
    required String email,
    required String telefono,
    required String contrasenia,
    required String fechaNacimiento,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/add');

    return await http.post(
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
  }

  // =======================================================
  // ACTUALIZA USUARIO
  // =======================================================
  static Future<http.Response> updateUsuario({
    required int id,
    required String nombre, // enviado como 'elNombre'
    String? apellidos,
    String? cedula,
    required String email,
    required String telefono,
    required String direccionEntrega,
    String? imagen,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/update/$id');

    // Construimos el cuerpo solo con claves no nulas para evitar enviar campos vacíos
    final Map<String, dynamic> body = {};

    // Incluir id y varios formatos de nombre para compatibilidad backend
    body['id'] = id;
    body['elNombre'] = nombre;
    body['nombre'] = nombre;
    if (apellidos != null && apellidos.isNotEmpty) body['apellidos'] = apellidos;
    if (cedula != null && cedula.isNotEmpty) {
      // Intentar enviar la cédula como número si es posible
      final cedulaNum = int.tryParse(cedula);
      body['cedula'] = cedulaNum ?? cedula;
    }
    body['email'] = email;
    body['telefono'] = telefono;
    body['direccionEntrega'] = direccionEntrega;
    if (imagen != null && imagen.isNotEmpty) body['imagen'] = imagen;

    final encoded = jsonEncode(body);
    print('DEBUG: PUT $url');
    print('DEBUG: Request body: $encoded');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: encoded,
    );

    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');

    return response;
  }

  // =======================================================
  // OBTENER ID POR EMAIL
  // =======================================================
  static Future<int?> getIdPorEmail(String email) async {
    final url = Uri.parse('$baseUrl/usuario/idPorEmail/$email');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded.containsKey("id")) return decoded["id"];
        if (decoded is int) return decoded;
        if (decoded is String) return int.tryParse(decoded);
      } catch (_) {}
    }

    return null;
  }

  // =======================================================
  // ENVIAR CONTRASEÑA POR CORREO
  // =======================================================
  static Future<String> enviarContrasenia(int idUsuario) async {
    final url = Uri.parse('$baseUrl/usuario/enviarContra/$idUsuario');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al enviar correo: ${response.body}');
    }
  }

  // =======================================================
  // SHARED PREFERENCES
  // =======================================================
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // =======================================================
  // OBTENER USUARIO POR ID
  // =======================================================
  static Future<Map<String, dynamic>?> getUsuario(int id) async {
    final url = Uri.parse('$baseUrl/usuario/get/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // =======================================================
  // CASILLEROS
  // =======================================================
  static Future<int?> getCasilleroId(int userId) async {
    final url = Uri.parse('$baseUrl/casillero/id/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is Map) {
          if (data.containsKey('casilleroId')) return data['casilleroId'];
          if (data.containsKey('id')) return data['id'];

          for (final v in data.values) {
            if (v is int) return v;
          }
        } else if (data is int) return data;
        else if (data is String) return int.tryParse(data);
      } catch (_) {
        return int.tryParse(response.body.trim());
      }
    }

    return null;
  }

  // =======================================================
  // ARTÍCULOS
  // =======================================================
  static Future<http.Response> addArticulo(int casilleroId, Articulo articulo) async {
    final url = Uri.parse('$baseUrl/articulo/add/$casilleroId');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
  }

  static Future<List<Articulo>> getArticulosPorCasillero(int casilleroId) async {
    final url = Uri.parse('$baseUrl/articulo/get/$casilleroId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((e) => Articulo.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los artículos');
    }
  }

  static Future<http.Response> updateArticulo(int articuloId, Articulo articulo) async {
    final url = Uri.parse('$baseUrl/articulo/update/$articuloId');

    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
  }

  static Future<http.Response> deleteArticulo(int articuloId) async {
    final url = Uri.parse('$baseUrl/articulo/delete/$articuloId');
    return await http.delete(url);
  }

  static Future<http.Response> deleteArticuloFromCasillero(int casilleroId, int articuloId) async {
    final url = Uri.parse('$baseUrl/articulo/del/$casilleroId/$articuloId');
    return await http.delete(url);
  }

  static Future<http.Response> updateArticuloInCasillero(int casilleroId, int articuloId, Articulo articulo) async {
    final url = Uri.parse('$baseUrl/articulo/put/$casilleroId/$articuloId');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
      body: jsonEncode(articulo.toJson()),
    );
  }

  // =======================================================
  // PAGOS
  // =======================================================
  static Future<Map<String, dynamic>> procesarPago({
    required String metodo,
    required double monto,
    String? numeroTarjeta,
    String? nombre,
    String? fecha,
    String? cvv,
    bool persistir = true,
  }) async {
    final uri = Uri.parse('$baseUrl/pagos/procesar')
        .replace(queryParameters: persistir ? {'persistir': 'true'} : null);

    final body = {
      'metodoPago': metodo,
      'nombre': nombre,
      'monto': monto,
      'numeroTarjeta': numeroTarjeta,
      'fecha': fecha,
      'cvv': cvv,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } else {
      throw Exception('Error al procesar pago: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getPagos() async {
    final url = Uri.parse('$baseUrl/pagos');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
            decoded.map((e) => e as Map<String, dynamic>)
        );
      }

      if (decoded is Map && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(
            decoded['data'].map((e) => e as Map<String, dynamic>)
        );
      }

      throw Exception('Formato inesperado de respuesta');
    } else {
      throw Exception('Error al obtener pagos');
    }
  }
}

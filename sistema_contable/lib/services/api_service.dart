import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // Cambiado a localhost

  // Helper para obtener el token de SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Registrar un nuevo usuario
  static Future<Map<String, dynamic>> register(String nombreUsuario,
      String correo, String contrasena, String nombre, String apellido) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_usuario': nombreUsuario,
          'correo': correo,
          'contrasena': contrasena,
          'nombre': nombre,
          'apellido': apellido,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Error al registrar: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Iniciar sesión
  static Future<Map<String, dynamic>> login(
      String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']); // Guardar el token
        return data;
      } else {
        throw Exception(
            'Error al iniciar sesión: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener transacciones
  static Future<List<Map<String, dynamic>>> getTransacciones() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró token');
      final response = await http.get(
        Uri.parse('$baseUrl/transacciones/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(
            'Error al obtener transacciones: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener categorías
  static Future<List<Map<String, dynamic>>> getCategorias() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró token');
      final response = await http.get(
        Uri.parse('$baseUrl/categorias/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(
            'Error al obtener categorías: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener cuentas
  static Future<List<Map<String, dynamic>>> getCuentas() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró token');
      final response = await http.get(
        Uri.parse('$baseUrl/cuentas/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(
            'Error al obtener cuentas: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear una transacción
  static Future<Map<String, dynamic>> createTransaccion(
      dynamic transaccion) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró token');
      final response = await http.post(
        Uri.parse('$baseUrl/transacciones/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(transaccion),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Error al crear transacción: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}

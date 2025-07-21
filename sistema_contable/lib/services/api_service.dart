import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaccion.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> login(
      String correo, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contraseña': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return data['user'];
    } else {
      throw Exception('Error en el login: ${response.body}');
    }
  }

  static Future<List<Transaccion>> getTransacciones() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/transacciones'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaccion.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener transacciones: ${response.body}');
    }
  }

  static Future<void> createTransaccion(Transaccion transaccion) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/transacciones'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        ...transaccion.toJson(),
        'repetir_cada': transaccion.toJson()['repetir_cada'],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al crear transacción: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getCategorias() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categorias'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener categorías: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getCuentas() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cuentas'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener cuentas: ${response.body}');
    }
  }
}

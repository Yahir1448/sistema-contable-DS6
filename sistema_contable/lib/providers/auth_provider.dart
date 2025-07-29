import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String correo, String password) async {
    try {
      final response = await ApiService.login(correo, password);
      _user = response['user']; // Ajusta según la respuesta del backend
      notifyListeners();
    } catch (e) {
      throw Exception('Error en el login: $e');
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}

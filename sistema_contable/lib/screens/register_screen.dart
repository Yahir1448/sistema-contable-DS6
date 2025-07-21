import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptTerms = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),
                Text('Acepto los Términos y Condiciones'),
              ],
            ),
            if (_error != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _acceptTerms
                  ? () async {
                      try {
                        // TODO: Implement API call for registration
                        await ApiService.login(
                            _correoController.text, _passwordController.text);
                        Navigator.pop(context);
                      } catch (e) {
                        setState(() {
                          _error = 'Error en el registro: $e';
                        });
                      }
                    }
                  : null,
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

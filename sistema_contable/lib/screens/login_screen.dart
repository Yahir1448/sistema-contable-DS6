import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'transacciones_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).login(_correoController.text, _passwordController.text);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => TransaccionesScreen()),
                  );
                } catch (e) {
                  setState(() {
                    _error = e.toString();
                  });
                }
              },
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

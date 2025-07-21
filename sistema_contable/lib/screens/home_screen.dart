import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'transacciones_screen.dart';
import 'budget_screen.dart';
import 'accounts_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema Contable'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¡Hola, ${user?['nombre'] ?? 'Usuario'}!',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildNavCard(context, 'Transacciones', Icons.list,
                      TransaccionesScreen()),
                  _buildNavCard(context, 'Presupuestos',
                      Icons.account_balance_wallet, BudgetScreen()),
                  _buildNavCard(context, 'Cuentas', Icons.account_balance,
                      AccountsScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
      BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

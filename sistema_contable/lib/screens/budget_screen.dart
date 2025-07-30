import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class BudgetScreen extends StatelessWidget {
  final int usuarioId;

  const BudgetScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuesto Mensual'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBudgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay presupuestos'));
          }
          final budgets = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.5,
            ),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Presupuesto Mensual',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Presupuesto: \$${budget['monto_asignado']}'),
                      Text('Gasto: \$${budget['monto_gastado']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchBudgets() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'presupuestos',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }
}

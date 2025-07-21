import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BudgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Presupuesto Mensual')),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchBudgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay presupuestos'));
          }
          final budgets = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Presupuesto Mensual',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Text('Presupuesto: \$${budget['monto_asignado'] ?? 0}'),
                      Text('Gasto: \$${budget['monto_gastado'] ?? 0}'),
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

  Future<List<dynamic>> _fetchBudgets() async {
    // TODO: Implement API call to fetch budgets from 'presupuestos' table
    return [
      {'monto_asignado': 0, 'monto_gastado': 0},
      {'monto_asignado': 0, 'monto_gastado': 0},
    ]; // Placeholder data
  }
}

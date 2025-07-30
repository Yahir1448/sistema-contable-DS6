import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AccountsScreen extends StatelessWidget {
  final int usuarioId;

  const AccountsScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay cuentas'));
          }
          final accounts = snapshot.data!;
          double totalCapital = accounts.fold(
              0.0,
              (sum, acc) =>
                  sum + (acc['saldo_actual'] > 0 ? acc['saldo_actual'] : 0));
          double totalDeuda = accounts.fold(
              0.0,
              (sum, acc) =>
                  sum + (acc['saldo_actual'] < 0 ? -acc['saldo_actual'] : 0));
          double balance = totalCapital - totalDeuda;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    const TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Capital',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('A deber',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Balance',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('\$${totalCapital.toStringAsFixed(2)}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('\$${totalDeuda.toStringAsFixed(2)}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('\$${balance.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return ListTile(
                      title: Text(account['nombre']),
                      subtitle: Text('Tipo: ${account['tipo']}'),
                      trailing: Text(
                          '\$${account['saldo_actual'].toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAccounts() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'cuentas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }
}

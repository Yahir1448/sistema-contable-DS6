import 'package:flutter/material.dart';

class AccountsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuentas')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay cuentas'));
          }
          final accounts = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
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
                            padding: EdgeInsets.all(8.0), child: Text('1.95')),
                        Padding(
                            padding: EdgeInsets.all(8.0), child: Text('41.95')),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('-40.00')),
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
                      trailing: Text('\$${account['saldo_actual']}'),
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
    // TODO: Implement API call to fetch accounts from 'cuentas' table
    return [
      {'nombre': 'Efectivo', 'tipo': 'efectivo', 'saldo_actual': 0.00},
      {'nombre': 'Banco', 'tipo': 'banco', 'saldo_actual': 0.00},
      {
        'nombre': 'Tarjeta de Crédito',
        'tipo': 'tarjeta_credito',
        'saldo_actual': 0.00
      },
    ];
  }
}

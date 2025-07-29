import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaccion.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import 'transaction_form_screen.dart';
import '../utils/extensions.dart';

class TransaccionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transacciones'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TransactionFormScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Transaccion>>(
        future: _fetchTransacciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay transacciones'));
          }
          final transacciones = snapshot.data!;
          final grouped = _groupByDate(transacciones);
          return ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final date = grouped.keys.elementAt(index);
              final transaccionesDelDia = grouped[date]!;
              return ExpansionTile(
                title: Text(DateFormat('dd MMM yyyy').format(date)),
                subtitle: Text('Transacciones: ${transaccionesDelDia.length}'),
                children: transaccionesDelDia.map((transaccion) {
                  return ListTile(
                    title: Text(transaccion.descripcion ?? 'Sin descripción'),
                    subtitle: Text(
                        '${transaccion.tipo.capitalize()}: \$${transaccion.importe}'),
                    trailing:
                        Text(DateFormat('HH:mm').format(transaccion.fecha)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TransactionFormScreen(transaccion: transaccion),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Transaccion>> _fetchTransacciones() async {
    try {
      final data = await ApiService.getTransacciones();
      return data.map((item) => Transaccion.fromJson(item)).toList();
    } catch (e) {
      return await DatabaseHelper.instance.getTransacciones();
    }
  }

  Map<DateTime, List<Transaccion>> _groupByDate(
      List<Transaccion> transacciones) {
    final Map<DateTime, List<Transaccion>> grouped = {};
    for (var transaccion in transacciones) {
      final date = DateTime(transaccion.fecha.year, transaccion.fecha.month,
          transaccion.fecha.day);
      grouped.putIfAbsent(date, () => []).add(transaccion);
    }
    return grouped;
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_contable/models/transaccion.dart';
import 'package:sistema_contable/database/database_helper.dart';
import 'package:sistema_contable/screens/registrar_transaccion.dart';
import 'package:sistema_contable/utils/extensions.dart';

class TransaccionesScreen extends StatelessWidget {
  final int usuarioId;

  const TransaccionesScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RegistrarTransaccionScreen(usuarioId: usuarioId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Transaccion>>(
        future: DatabaseHelper.instance.getTransacciones(usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay transacciones'));
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
                          builder: (_) => RegistrarTransaccionScreen(
                            usuarioId: usuarioId,
                            transaccion: transaccion,
                          ),
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

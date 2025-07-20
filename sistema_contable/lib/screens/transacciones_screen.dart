import 'package:flutter/material.dart';
import '../models/transaccion.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class TransaccionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transacciones')),
      body: FutureBuilder<List<Transaccion>>(
        future: ApiService.getTransacciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay transacciones'));
          }
          final transacciones = snapshot.data!;
          return ListView.builder(
            itemCount: transacciones.length,
            itemBuilder: (context, index) {
              final transaccion = transacciones[index];
              return ListTile(
                title: Text(transaccion.descripcion ?? 'Sin descripción'),
                subtitle: Text('${transaccion.tipo}: \$${transaccion.importe}'),
                trailing: Text(transaccion.fecha.toString()),
              );
            },
          );
        },
      ),
    );
  }
}

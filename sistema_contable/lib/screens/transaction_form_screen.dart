import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaccion.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../utils/extensions.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaccion? transaccion;

  TransactionFormScreen({this.transaccion});

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'ingreso';
  final _importeController = TextEditingController();
  DateTime _fecha = DateTime.now();
  String? _categoriaId;
  String? _cuentaId;
  final _notaController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _repetirCada;

  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _cuentas = [];

  @override
  void initState() {
    super.initState();
    if (widget.transaccion != null) {
      _tipo = widget.transaccion!.tipo;
      _importeController.text = widget.transaccion!.importe.toString();
      _fecha = widget.transaccion!.fecha;
      _categoriaId = widget.transaccion!.categoriaId?.toString();
      _cuentaId = widget.transaccion!.cuentaId?.toString();
      _notaController.text = widget.transaccion!.nota ?? '';
      _descripcionController.text = widget.transaccion!.descripcion ?? '';
      _repetirCada = widget.transaccion!.toJson()['repetir_cada'];
    }
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      _categorias = await ApiService.getCategorias();
      _cuentas = await ApiService.getCuentas();
    } catch (e) {
      _categorias = [
        {'id': '1', 'nombre': 'Salario'},
        {'id': '2', 'nombre': 'Comida/Cena'},
        {'id': '3', 'nombre': 'Transporte'},
      ];
      _cuentas = [
        {'id': '1', 'nombre': 'Efectivo'},
        {'id': '2', 'nombre': 'Banco'},
        {'id': '3', 'nombre': 'Tarjeta de Crédito'},
      ];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.transaccion == null
              ? 'Nueva Transacción'
              : 'Editar Transacción')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: InputDecoration(labelText: 'Tipo'),
                items: ['ingreso', 'gasto', 'transferencia']
                    .map((tipo) => DropdownMenuItem<String>(
                        value: tipo, child: Text(tipo.capitalize())))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un tipo' : null,
              ),
              TextFormField(
                controller: _importeController,
                decoration: InputDecoration(labelText: 'Importe (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese un importe';
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0)
                    return 'Ingrese un número válido y mayor a 0';
                  return null;
                },
              ),
              ListTile(
                title: Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy (EEE) HH:mm').format(_fecha)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_fecha),
                    );
                    if (time != null) {
                      setState(() {
                        _fecha = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
                      });
                    }
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _categoriaId,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: _categorias
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat['id'].toString(),
                          child: Text(cat['nombre'] as String),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaId = value;
                  });
                },
                validator: (value) => value == null && _tipo != 'transferencia'
                    ? 'Seleccione una categoría'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _cuentaId,
                decoration: InputDecoration(labelText: 'Cuenta'),
                items: _cuentas
                    .map((cuenta) => DropdownMenuItem<String>(
                          value: cuenta['id'].toString(),
                          child: Text(cuenta['nombre'] as String),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _cuentaId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una cuenta' : null,
              ),
              TextFormField(
                controller: _notaController,
                decoration: InputDecoration(labelText: 'Nota'),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              DropdownButtonFormField<String>(
                value: _repetirCada,
                decoration: InputDecoration(labelText: 'Repetir cada'),
                items: [null, 'diario', 'semanal', 'mensual']
                    .map((val) => DropdownMenuItem<String>(
                        value: val, child: Text(val ?? 'No repetir')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _repetirCada = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final transaccion = Transaccion(
                          id: widget.transaccion?.id ?? 0,
                          usuarioId: 1, // TODO: Obtener desde AuthProvider
                          tipo: _tipo,
                          importe: double.parse(_importeController.text),
                          fecha: _fecha,
                          categoriaId: _categoriaId != null
                              ? int.parse(_categoriaId!)
                              : null,
                          cuentaId:
                              _cuentaId != null ? int.parse(_cuentaId!) : null,
                          nota: _notaController.text.isEmpty
                              ? null
                              : _notaController.text,
                          descripcion: _descripcionController.text.isEmpty
                              ? null
                              : _descripcionController.text,
                        );
                        try {
                          await ApiService.createTransaccion(
                              transaccion.toJson());
                          await DatabaseHelper.instance
                              .insertTransaccion(transaccion);
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    },
                    child: Text('Guardar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _importeController.dispose();
    _notaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}

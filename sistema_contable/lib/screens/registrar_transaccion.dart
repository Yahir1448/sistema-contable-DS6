import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_contable/database/database_helper.dart';
import 'package:sistema_contable/models/transaccion.dart';
import 'package:sistema_contable/models/categoria.dart';

class RegistrarTransaccionScreen extends StatefulWidget {
  final int usuarioId;
  final Transaccion? transaccion;

  const RegistrarTransaccionScreen(
      {super.key, required this.usuarioId, this.transaccion});

  @override
  _RegistrarTransaccionScreenState createState() =>
      _RegistrarTransaccionScreenState();
}

class _RegistrarTransaccionScreenState
    extends State<RegistrarTransaccionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _importeController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _notaController = TextEditingController();
  String _tipo = 'ingreso';
  Categoria? _categoriaSeleccionada;
  bool _esRecurrente = false;
  String? _periodo;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    if (widget.transaccion != null) {
      _importeController.text = widget.transaccion!.importe.toString();
      _descripcionController.text = widget.transaccion!.descripcion ?? '';
      _notaController.text = widget.transaccion!.nota ?? '';
      _tipo = widget.transaccion!.tipo;
      _esRecurrente = widget.transaccion!.esRecurrente;
      _periodo = widget.transaccion!.periodo;
    }
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final categorias = await _dbHelper.getCategorias(tipo: _tipo);
    setState(() {
      _categorias = categorias;
      if (widget.transaccion != null &&
          widget.transaccion!.categoriaId != null) {
        _categoriaSeleccionada = categorias.isNotEmpty
            ? categorias.firstWhere(
                (cat) => cat.id == widget.transaccion!.categoriaId,
                orElse: () => categorias.first,
              )
            : null;
      } else {
        _categoriaSeleccionada =
            categorias.isNotEmpty ? categorias.first : null;
      }
    });
  }

  Future<void> _guardarTransaccion() async {
    if (_formKey.currentState!.validate()) {
      final transaccion = Transaccion(
        id: widget.transaccion?.id,
        usuarioId: widget.usuarioId,
        tipo: _tipo,
        importe: double.parse(_importeController.text),
        fecha: widget.transaccion?.fecha ?? DateTime.now(),
        categoriaId: _categoriaSeleccionada?.id,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        esRecurrente: _esRecurrente,
        periodo: _esRecurrente ? _periodo : null,
        nota: _notaController.text.isEmpty ? null : _notaController.text,
      );
      try {
        if (widget.transaccion == null) {
          await _dbHelper.insertTransaccion(transaccion);
        } else {
          await _dbHelper.updateTransaccion(transaccion);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transacción guardada')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _importeController.dispose();
    _descripcionController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaccion == null
            ? 'Nueva Transacción'
            : 'Editar Transacción'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de transacción',
                    border: OutlineInputBorder(),
                  ),
                  items: ['ingreso', 'gasto', 'transferencia']
                      .map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipo = value!;
                      _categoriaSeleccionada =
                          null; // Resetear categoría al cambiar tipo
                      _cargarCategorias();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Seleccione un tipo de transacción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _importeController,
                  decoration: const InputDecoration(
                    labelText: 'Importe',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un importe';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Ingrese un importe válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Categoria>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias
                      .map((categoria) => DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria.nombre),
                          ))
                      .toList(),
                  onChanged: _categorias.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _categoriaSeleccionada = value;
                          });
                        },
                  validator: (value) {
                    if (_categorias.isEmpty) {
                      return 'No hay categorías disponibles para este tipo';
                    }
                    if (value == null) {
                      return 'Seleccione una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Es recurrente'),
                  value: _esRecurrente,
                  onChanged: (value) {
                    setState(() {
                      _esRecurrente = value!;
                    });
                  },
                ),
                if (_esRecurrente)
                  DropdownButtonFormField<String>(
                    value: _periodo,
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                    ),
                    items: ['diario', 'semanal', 'mensual', 'anual']
                        .map((periodo) => DropdownMenuItem(
                              value: periodo,
                              child: Text(periodo),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _periodo = value;
                      });
                    },
                    validator: (value) {
                      if (_esRecurrente && value == null) {
                        return 'Seleccione un período';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notaController,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _guardarTransaccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: Text(widget.transaccion == null
                      ? 'Guardar Transacción'
                      : 'Actualizar Transacción'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
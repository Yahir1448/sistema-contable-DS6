class Transaccion {
  final int? id;
  final int usuarioId;
  final String tipo;
  final double importe;
  final DateTime fecha;
  final int? categoriaId;
  final int? cuentaId;
  final String? descripcion;
  final bool esRecurrente;
  final String? periodo;
  final String? nota;

  Transaccion({
    this.id,
    required this.usuarioId,
    required this.tipo,
    required this.importe,
    required this.fecha,
    this.categoriaId,
    this.cuentaId,
    this.descripcion,
    required this.esRecurrente,
    this.periodo,
    this.nota,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo,
      'importe': importe,
      'fecha': fecha.toIso8601String(),
      'categoria_id': categoriaId,
      'cuenta_id': cuentaId,
      'descripcion': descripcion,
      'es_recurrente': esRecurrente ? 1 : 0,
      'periodo': periodo,
      'nota': nota,
    };
  }

  factory Transaccion.fromMap(Map<String, dynamic> map) {
    return Transaccion(
      id: map['id'],
      usuarioId: map['usuario_id'],
      tipo: map['tipo'],
      importe: map['importe'],
      fecha: DateTime.parse(map['fecha']),
      categoriaId: map['categoria_id'],
      cuentaId: map['cuenta_id'],
      descripcion: map['descripcion'],
      esRecurrente: map['es_recurrente'] == 1,
      periodo: map['periodo'],
      nota: map['nota'],
    );
  }
}

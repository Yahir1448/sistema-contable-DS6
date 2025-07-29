class Transaccion {
  final int id;
  final int usuarioId;
  final String tipo;
  final double importe;
  final DateTime fecha;
  final int? categoriaId;
  final int? cuentaId;
  final String? nota;
  final String? descripcion;

  Transaccion({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.importe,
    required this.fecha,
    this.categoriaId,
    this.cuentaId,
    this.nota,
    this.descripcion,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
      usuarioId: json['usuario_id'],
      tipo: json['tipo'],
      importe: json['importe'].toDouble(),
      fecha: DateTime.parse(json['fecha']),
      categoriaId: json['categoria_id'],
      cuentaId: json['cuenta_id'],
      nota: json['nota'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo,
      'importe': importe,
      'fecha': fecha.toIso8601String(),
      'categoria_id': categoriaId,
      'cuenta_id': cuentaId,
      'nota': nota,
      'descripcion': descripcion,
      'repetir_cada': null, // Ajusta según necesidad
    };
  }
}

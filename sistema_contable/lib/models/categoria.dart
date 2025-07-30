class Categoria {
  final int? id;
  final String nombre;
  final String tipo;

  Categoria({
    this.id,
    required this.nombre,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
    );
  }
}

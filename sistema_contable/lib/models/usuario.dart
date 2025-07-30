class Usuario {
  final int? id;
  final String nombreUsuario;
  final String correo;
  final String contrasenaHash;
  final String? nombre;
  final String? apellido;
  final String moneda;
  final String idioma;
  final String fechaCreacion;
  final bool estaActivo;

  Usuario({
    this.id,
    required this.nombreUsuario,
    required this.correo,
    required this.contrasenaHash,
    this.nombre,
    this.apellido,
    required this.moneda,
    required this.idioma,
    required this.fechaCreacion,
    required this.estaActivo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre_usuario': nombreUsuario,
      'correo': correo,
      'contrasena_hash': contrasenaHash,
      'nombre': nombre,
      'apellido': apellido,
      'moneda': moneda,
      'idioma': idioma,
      'fecha_creacion': fechaCreacion,
      'esta_activo': estaActivo ? 1 : 0,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombreUsuario: map['nombre_usuario'],
      correo: map['correo'],
      contrasenaHash: map['contrasena_hash'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      moneda: map['moneda'],
      idioma: map['idioma'],
      fechaCreacion: map['fecha_creacion'],
      estaActivo: map['esta_activo'] == 1,
    );
  }
}

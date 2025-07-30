import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/usuario.dart';
import '../models/transaccion.dart';
import '../models/categoria.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sistema_contable.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print('Inicializando sqflite_common_ffi para escritorio');
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Ruta de la base de datos: $path');
    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = OFF;');

    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_usuario TEXT NOT NULL UNIQUE,
        correo TEXT NOT NULL UNIQUE,
        contrasena_hash TEXT NOT NULL,
        nombre TEXT,
        apellido TEXT,
        moneda TEXT NOT NULL DEFAULT 'USD',
        idioma TEXT NOT NULL DEFAULT 'es',
        fecha_creacion TEXT NOT NULL DEFAULT (datetime('now')),
        esta_activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('ingreso', 'gasto', 'transferencia')),
        usuario_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transacciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('ingreso', 'gasto', 'transferencia')),
        importe REAL NOT NULL,
        fecha TEXT NOT NULL DEFAULT (datetime('now')),
        categoria_id INTEGER,
        cuenta_id INTEGER,
        descripcion TEXT,
        es_recurrente INTEGER NOT NULL DEFAULT 0,
        periodo TEXT,
        nota TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        FOREIGN KEY (categoria_id) REFERENCES categorias(id),
        FOREIGN KEY (cuenta_id) REFERENCES cuentas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cuentas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('efectivo', 'banco', 'tarjeta_credito', 'tarjeta_debito')),
        saldo_actual REAL NOT NULL DEFAULT 0.00,
        saldo_objetivo REAL,
        fecha_creacion TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE presupuestos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        categoria_id INTEGER,
        mes INTEGER NOT NULL,
        anio INTEGER NOT NULL,
        monto_asignado REAL NOT NULL,
        monto_gastado REAL NOT NULL DEFAULT 0.00,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE metas_ahorro (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        monto REAL NOT NULL,
        categoria_id INTEGER,
        fecha_inicio TEXT NOT NULL DEFAULT (datetime('now')),
        fecha_fin TEXT NOT NULL,
        alcanzado INTEGER NOT NULL DEFAULT 0,
        descripcion TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE analisis_gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        categoria_id INTEGER NOT NULL,
        periodo TEXT NOT NULL CHECK(periodo IN ('semanal', 'mensual')),
        monto_gastado REAL NOT NULL,
        sugerencia_ahorro REAL,
        descripcion_sugerencia TEXT,
        fecha_analisis TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reportes_generados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        tipo_reporte TEXT NOT NULL,
        fecha_generacion TEXT DEFAULT (datetime('now')),
        url_archivo TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE configuraciones_usuario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        idioma TEXT DEFAULT 'es',
        notificaciones INTEGER DEFAULT 1,
        tema TEXT DEFAULT 'claro' CHECK(tema IN ('claro', 'oscuro')),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notificaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        mensaje TEXT NOT NULL,
        fecha_programada TEXT NOT NULL,
        enviada INTEGER DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE respaldo_datos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        fecha_respaldo TEXT DEFAULT (datetime('now')),
        tipo TEXT DEFAULT 'manual' CHECK(tipo IN ('manual', 'automático')),
        archivo_url TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    // Insertar categorías predeterminadas
    await db.insert('categorias', {
      'nombre': 'Mesada',
      'tipo': 'ingreso',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Trabajo Temporal',
      'tipo': 'ingreso',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Regalo',
      'tipo': 'ingreso',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Transporte Público',
      'tipo': 'gasto',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Comida Rápida',
      'tipo': 'gasto',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Materiales Escolares',
      'tipo': 'gasto',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Entretenimiento',
      'tipo': 'gasto',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Otros',
      'tipo': 'gasto',
      'usuario_id': null,
    });
    await db.insert('categorias', {
      'nombre': 'Transferencia Bancaria',
      'tipo': 'transferencia',
      'usuario_id': null,
    });

    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('PRAGMA foreign_keys = OFF;');
      await db.execute('ALTER TABLE usuarios RENAME TO usuarios_old;');
      await db.execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre_usuario TEXT NOT NULL UNIQUE,
          correo TEXT NOT NULL UNIQUE,
          contrasena_hash TEXT NOT NULL,
          nombre TEXT,
          apellido TEXT,
          moneda TEXT NOT NULL DEFAULT 'USD',
          idioma TEXT NOT NULL DEFAULT 'es',
          fecha_creacion TEXT NOT NULL DEFAULT (datetime('now')),
          esta_activo INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.execute('''
        INSERT INTO usuarios (id, nombre_usuario, correo, contrasena_hash, nombre, apellido, moneda, idioma, fecha_creacion, esta_activo)
        SELECT id, nombre_usuario, correo, contrasena_hash, nombre, apellido, moneda, idioma, fecha_creacion, esta_activo
        FROM usuarios_old;
      ''');
      await db.execute('DROP TABLE usuarios_old;');
      await db.execute('PRAGMA foreign_keys = ON;');
    }
  }

  // Método para hashear contraseñas
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // CRUD para Usuarios
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    final usuarioConHash = Usuario(
      id: usuario.id,
      nombreUsuario: usuario.nombreUsuario,
      correo: usuario.correo,
      contrasenaHash: _hashPassword(usuario.contrasenaHash),
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      moneda: usuario.moneda,
      idioma: usuario.idioma,
      fechaCreacion: usuario.fechaCreacion,
      estaActivo: usuario.estaActivo,
    );
    return await db.insert('usuarios', usuarioConHash.toMap());
  }

  Future<Usuario?> getUsuarioById(int id) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Usuario.fromMap(maps.first) : null;
  }

  Future<Usuario?> getUsuarioByCorreo(String correo) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [correo],
    );
    return maps.isNotEmpty ? Usuario.fromMap(maps.first) : null;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final db = await database;
    final usuarioConHash = Usuario(
      id: usuario.id,
      nombreUsuario: usuario.nombreUsuario,
      correo: usuario.correo,
      contrasenaHash: _hashPassword(usuario.contrasenaHash),
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      moneda: usuario.moneda,
      idioma: usuario.idioma,
      fechaCreacion: usuario.fechaCreacion,
      estaActivo: usuario.estaActivo,
    );
    return await db.update(
      'usuarios',
      usuarioConHash.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Transacciones
  Future<int> insertTransaccion(Transaccion transaccion) async {
    final db = await database;
    return await db.insert('transacciones', transaccion.toMap());
  }

  Future<List<Transaccion>> getTransacciones(int usuarioId) async {
    final db = await database;
    final maps = await db.query(
      'transacciones',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha DESC',
    );
    return maps.map((map) => Transaccion.fromMap(map)).toList();
  }

  Future<int> updateTransaccion(Transaccion transaccion) async {
    final db = await database;
    return await db.update(
      'transacciones',
      transaccion.toMap(),
      where: 'id = ?',
      whereArgs: [transaccion.id],
    );
  }

  Future<int> deleteTransaccion(int id) async {
    final db = await database;
    return await db.delete(
      'transacciones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Categorías
  Future<int> insertCategoria(Categoria categoria) async {
    final db = await database;
    return await db.insert('categorias', categoria.toMap());
  }

  Future<List<Categoria>> getCategorias({String? tipo}) async {
    final db = await database;
    final maps = await db.query(
      'categorias',
      where: tipo != null ? 'tipo = ?' : null,
      whereArgs: tipo != null ? [tipo] : null,
    );
    print('Categorías para tipo $tipo: $maps');
    return maps.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<int> updateCategoria(Categoria categoria) async {
    final db = await database;
    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> deleteCategoria(int id) async {
    final db = await database;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

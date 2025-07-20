import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaccion.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
         CREATE TABLE transacciones (
           id INTEGER PRIMARY KEY,
           usuario_id INTEGER,
           tipo TEXT,
           importe REAL,
           fecha TEXT,
           categoria_id INTEGER,
           cuenta_id INTEGER,
           nota TEXT,
           descripcion TEXT
         )
       ''');
  }

  Future<void> insertTransaccion(Transaccion transaccion) async {
    final db = await database;
    await db.insert(
      'transacciones',
      transaccion.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaccion>> getTransacciones() async {
    final db = await database;
    final maps = await db.query('transacciones');
    return maps.map((map) => Transaccion.fromJson(map)).toList();
  }
}

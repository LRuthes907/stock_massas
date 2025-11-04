import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_mananger_app');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await _ensureProductsTable(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseUid TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatarUrl TEXT,
        isGoogleUser INTEGER DEFAULT 0,
        role TEXT NOT NULL DEFAULT 'student',
        classId TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // Exemplo de migração simples (garante colunas novas):
      await db.execute(
        "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'student'",
      );
      await db.execute("ALTER TABLE users ADD COLUMN classId TEXT");
    }
  }

  Future<void> _ensurProductsTable(Database db )async {
    await db.execute('''
     CREATE TABLE IF NOT EXISTS pizza_estoque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT UNIQUE,
        nome TEXT NOT NULL,
        precoVenda REAL NOT NULL,
        quantidadeEstoque INTEGER NOT NULL,
        dataValidade INTEGER,
        dataCriacao INTEGER NOT NULL,
        dataAtualizacao INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0
      );
    ''');
    await db.execute('CREATE UNIQUE INDEX IF NOT EXIST idx_products_remoteId ON prducts(remoteId);');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

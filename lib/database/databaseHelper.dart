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
    final path = join(dbPath, 'stock_manager_app.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await _ensureTablesExist(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
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

  Future<void> _ensureTablesExist(Database db) async {
    // Tabela de produtos/estoque (nome consistente com repositório)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS produto_estoque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT UNIQUE,
        nome TEXT NOT NULL,
        preco REAL NOT NULL,
        quantidade INTEGER NOT NULL,
        dataValidade INTEGER,
        dataCriacao INTEGER NOT NULL,
        dataAtualizacao INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_produto_remoteId ON produto_estoque(remoteId);',
    );
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2 && newV >= 2) {
      // Garante que a tabela de produtos exista após upgrade para v2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS produto_estoque (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          remoteId TEXT UNIQUE,
          nome TEXT NOT NULL,
          preco REAL NOT NULL,
          quantidade INTEGER NOT NULL,
          dataValidade INTEGER,
          dataCriacao INTEGER NOT NULL,
          dataAtualizacao INTEGER NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0,
          deleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_produto_remoteId ON produto_estoque(remoteId);',
      );
    }
    // Adicione outras migrações conforme necessário
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}

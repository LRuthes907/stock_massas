import 'package:corretor_prova/database/database_helper.dart';
import 'package:corretor_prova/models/pizza_estoque_model.dart';
import 'package:sqflite/sqflite.dart';

class produtoRepository{
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<int> create(ProdutoEstoque produto) async {
    final db = await _db;
    return await db.insert(
      'produto_estoque',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(ProdutoEstoque produto) async {
    final db = await _db;
    return await db.update(
      'produto_estoque',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<List<ProdutoEstoque>> getAllProduto() async {
    final db = await _db;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'produto_estoque',
      where: 'deleted = 0',
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      return ProdutoEstoque.fromMap(maps[i]);
    });
  }

  Future<produtoEstoque?> getById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'produto_estoque',
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProdutoEstoque.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    final db = await _db;
    
    final updateData = {
      'deleted': 1,
      'dirty': 1,
      'dataAtualizacao': DateTime.now().millisecondsSinceEpoch,
    };

    return await db.update(
      'produto_estoque',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
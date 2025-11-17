import 'package:sqflite/sqflite.dart';
import 'package:stock_massas/database/databaseHelper.dart';
import '../models/produtoModel.dart';

class ProdutoRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> create(Produto produto) async {
    final db = await _db;
    return await db.insert(
      'produto_estoque',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Produto produto) async {
    final db = await _db;
    return await db.update(
      'produto_estoque',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<List<Produto>> getAllProduto() async {
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.query(
      'produto_estoque',
      where: 'deleted = 0',
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      return Produto.fromMap(maps[i]);
    });
  }

  Future<Produto?> getById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'produto_estoque',
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Produto.fromMap(maps.first);
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

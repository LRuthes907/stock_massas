import 'package:sqflite/sqflite.dart';
import 'package:stock_massas/database/databaseHelper.dart';
import '../models/produtoModel.dart';

// Opera sobre a tabela local de produtos (SQLite).
class ProdutoRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> create(Produto produto) async {
    // Insere um produto novo ou substitui pelo ID se já existir.
    final db = await _db;
    return await db.insert(
      'produto_estoque',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Produto produto) async {
    // Atualiza um produto existente usando o ID local.
    final db = await _db;
    return await db.update(
      'produto_estoque',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<List<Produto>> getAllProduto() async {
    // Recupera todos que não foram marcados como deletados.
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
    // Busca um produto específico pelo ID local.
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
    // Marca como deletado mas mantém registro para sincronização.
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

  Future<Produto?> getByRemoteId(String remoteId) async {
    // Localiza pelo ID remoto salvo durante a sincronização.
    final db = await _db;
    final rows = await db.query(
      'produto_estoque',
      where: 'remoteId = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return Produto.fromMap(rows.first);
  }

  Future<void> hardDelete(int id) async {
    // Remove o registro definitivamente do banco local.
    final db = await _db;
    await db.delete('produto_estoque', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertFromRemote(Produto produto) async {
    // Atualiza ou cria um registro com dados vindos do Firestore.
    if (produto.remoteId == null) return;

    final db = await _db;
    final existing = await getByRemoteId(produto.remoteId!);
    final sanitized = produto.copyWith(id: existing?.id, dirty: false);

    final data = sanitized.toMap();
    if (existing?.id == null) {
      data.remove('id');
    }

    await db.insert(
      'produto_estoque',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Produto>> getDirty() async {
    // Retorna os registros que precisam ser sincronizados.
    final db = await _db;
    final rows = await db.query(
      'produto_estoque',
      where: 'dirty = 1',
      orderBy: 'dataAtualizacao ASC',
    );

    return rows.map((row) => Produto.fromMap(row)).toList();
  }

  Future<void> markSynced(
    int id,
    String? remoteId,
    DateTime remoteUpdatedAt,
  ) async {
    // Atualiza flags locais após sincronizar com sucesso.
    final db = await _db;
    await db.update(
      'produto_estoque',
      {
        'remoteId': remoteId,
        'dirty': 0,
        'deleted': 0,
        'dataAtualizacao': remoteUpdatedAt.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

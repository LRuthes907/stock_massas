import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/produtoModel.dart';

// Encapsula as operações com o Firestore para produtos.
class ProdutoRemoteRepository {
  ProdutoRemoteRepository({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        'produtos',
      );
  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAll() {
    // Stream com todas as alterações ordenadas pela última atualização.
    return _collection
        .orderBy('dataAtualizacao', descending: false)
        .snapshots();
  }

  Future<List<Produto>> fetchAllOnce() async {
    // Leitura única usada na sincronização inicial.
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Produto.fromFirestore(doc.data(), id: doc.id))
        .toList();
  }

  Future<void> deleteRemote(String remoteId) async {
    // Remove o documento correspondente no Firestore.
    await _collection.doc(remoteId).delete();
  }

  Future<Produto> upsert(Produto produto) async {
    // Atualiza ou cria o documento e devolve o modelo com dados frescos.
    final now = DateTime.now();
    final payload = {
      ...produto.toFirestore(),
      'dataAtualizacao': now.toIso8601String(),
      'dataCriacao': produto.dataCriacao.toIso8601String(),
    };

    DocumentReference<Map<String, dynamic>> docRef;
    if (produto.remoteId != null) {
      docRef = _collection.doc(produto.remoteId);
      await docRef.set(payload, SetOptions(merge: true));
    } else {
      docRef = await _collection.add(payload);
    }

    return produto.copyWith(
      remoteId: docRef.id,
      dataAtualizacao: now,
      dirty: false,
    );
  }
}

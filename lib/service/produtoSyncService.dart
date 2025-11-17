import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/produtoModel.dart';
import '../repository/produtoRepository.dart';
import '../repository/produtoRemoteRepository.dart';

// Faz a ponte de sincronização entre o banco local (SQLite) e o Firestore.
class ProdutoSyncService {
  final ProdutoRepository local;
  final ProdutoRemoteRepository remote;
  final Connectivity _connectivity;
  StreamSubscription? _connSub;
  StreamSubscription? _remoteSub;

  ProdutoSyncService({
    required this.local,
    required this.remote,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  Future<void> init() async {
    // Primeira carga: garante que o estado local reflita o que existe no servidor.
    await pullFromRemote();

    // Acompanha alterações em tempo real do Firestore para manter o SQLite atualizado.
    _remoteSub = remote.watchAll().listen((snap) async {
      for (final change in snap.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;
        final p = Produto.fromFirestore(data, id: change.doc.id);
        final current = p.remoteId == null
            ? null
            : await local.getByRemoteId(p.remoteId!);

        if (current == null ||
            p.dataAtualizacao.isAfter(current.dataAtualizacao)) {
          if (p.deleted) {
            if (current?.id != null) {
              await local.hardDelete(current!.id!);
            }
          } else {
            await local.upsertFromRemote(p);
          }
        }
      }
    });

    // Sempre que a conexão voltar, enviamos os registros pendentes.
    _connSub = _connectivity.onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        await pushDirty();
      }
    });

    // Se já estivermos online, dispara uma sincronização imediata.
    final now = await _connectivity.checkConnectivity();
    if (now != ConnectivityResult.none) {
      await pushDirty();
    }
  }

  Future<void> dispose() async {
    // Cancela streams para evitar vazamento de memória.
    await _connSub?.cancel();
    await _remoteSub?.cancel();
  }

  Future<void> pullFromRemote() async {
    // Baixa todos os produtos remotos e aplica apenas os registros mais recentes.
    final all = await remote.fetchAllOnce();
    for (final p in all) {
      final current = p.remoteId == null
          ? null
          : await local.getByRemoteId(p.remoteId!);
      if (current == null ||
          p.dataAtualizacao.isAfter(current.dataAtualizacao)) {
        if (p.deleted) {
          // Remoção remota confirma remoção local definitiva.
          if (current?.id != null) await local.hardDelete(current!.id!);
        } else {
          // Atualiza ou insere o dado vindo do Firestore.
          await local.upsertFromRemote(p);
        }
      }
    }
  }

  Future<void> pushDirty() async {
    // Envia os registros marcados como "dirty" no SQLite para o Firestore.
    final dirty = await local.getDirty();
    for (final p in dirty) {
      if (p.deleted) {
        if (p.remoteId != null) {
          // Produto já tinha ID remoto: exclui lá e limpa localmente.
          await remote.deleteRemote(p.remoteId!);
          if (p.id != null) await local.hardDelete(p.id!);
        } else {
          // Item só existia localmente: basta retirar da base local.
          if (p.id != null) await local.hardDelete(p.id!);
        }
        continue;
      }

      final newRemoteData = await remote.upsert(p);
      if (p.id != null) {
        // Marca o registro como sincronizado, guardando o remoteId.
        await local.markSynced(
          p.id!,
          newRemoteData.remoteId,
          newRemoteData.dataAtualizacao,
        );
      }
    }
  }
}

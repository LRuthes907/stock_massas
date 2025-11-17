import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/produtoModel.dart';
import '../repository/produtoRepository.dart';
import '../repository/produtoRemoteRepository.dart';

class ProdutoSyncService {
  final ProdutoRepository local;
  final ProdutoRemoteRepository remote;
  StreamSubscription? _connSub;
  StreamSubscription? _remoteSub;

  ProdutoSyncService({required this.local, required this.remote});

  Future<void> init() async {
    await pullFromRemote();

    _remoteSub = remote.watchAll().listen((snap) async {
      for (final change in snap.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;
        final p = Produto.fromFirestore(
          data as Map<String, dynamic>,
          id: change.doc.id,
        );
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

    _connSub = Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        await pushDirty();
      }
    });

    final now = await Connectivity().checkConnectivity();
    if (now != ConnectivityResult.none) {
      await pushDirty();
    }
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    await _remoteSub?.cancel();
  }

  Future<void> pullFromRemote() async {
    final all = await remote.fetchAllOnce();
    for (final p in all) {
      final current = p.remoteId == null
          ? null
          : await local.getByRemoteId(p.remoteId!);
      if (current == null ||
          p.dataAtualizacao.isAfter(current.dataAtualizacao)) {
        if (p.deleted) {
          if (current?.id != null) await local.hardDelete(current!.id!);
        } else {
          await local.upsertFromRemote(p);
        }
      }
    }
  }

  Future<void> pushDirty() async {
    final dirty = await local.getDirty();
    for (final p in dirty) {
      if (p.deleted) {
        if (p.remoteId != null) {
          await remote.deleteRemote(p.remoteId!);
          if (p.id != null) await local.hardDelete(p.id!);
        } else {
          if (p.id != null) await local.hardDelete(p.id!);
        }
        continue;
      }

      final newRemoteData = await remote.upsert(p);
      if (p.id != null) {
        await local.markSynced(
          p.id!,
          newRemoteData.remoteId,
          newRemoteData.dataAtualizacao,
        );
      }
    }
  }
}

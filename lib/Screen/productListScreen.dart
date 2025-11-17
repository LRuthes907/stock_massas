import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tela que lista tudo o que foi cadastrado no Firestore.
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.green.shade700;
    // Tela raiz que prepara o layout e o tema da lista.
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Produtos cadastrados'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _ProductListCard(primaryColor: primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    // Cartão central com título, descrição e a lista em si.
    return Card(
      elevation: 10,
      shadowColor: Colors.green.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.green.shade200, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produtos cadastrados',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visualize tudo o que foi registrado pelo time.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Acompanha os produtos do Firestore em tempo real.
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('produtos')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Falha ao carregar produtos: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _EmptyState();
                }

                // Exibe cada produto em um card separado.
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final snapshot = docs[index];
                    final data = snapshot.data();
                    return _ProductTile(
                      name: data['nome']?.toString() ?? 'Sem nome',
                      price: _asDouble(data['preco']),
                      quantity: _asInt(data['quantidade']),
                      description: data['descricao']?.toString(),
                      createdAt: data['createdAt'],
                      onDelete: () => _confirmDelete(context, snapshot.id),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static double _asDouble(dynamic value) {
    // Garante que valores vindos do Firestore sejam tratados como double.
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _asInt(dynamic value) {
    // Converte quantidade para inteiro, mesmo que venha como string.
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Future<void> _confirmDelete(BuildContext context, String docId) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          // Pergunta ao usuário antes de excluir o produto.
          builder: (dialogContext) => AlertDialog(
            title: const Text('Excluir produto'),
            content: const Text(
              'Tem certeza de que deseja remover este produto? Esta ação não poderá ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      // Remove o documento no Firestore e avisa o usuário.
      await FirebaseFirestore.instance
          .collection('produtos')
          .doc(docId)
          .delete();
      messenger.showSnackBar(
        const SnackBar(content: Text('Produto excluído com sucesso.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao excluir produto: $e')),
      );
    }
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.name,
    required this.price,
    required this.quantity,
    this.description,
    this.createdAt,
    required this.onDelete,
  });

  final String name;
  final double price;
  final int quantity;
  final String? description;
  final dynamic createdAt;
  final VoidCallback onDelete;

  // Formata valores numéricos para o padrão monetário brasileiro.
  String _formatCurrency(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  String? _formatDate(dynamic value) {
    DateTime? date;
    if (value == null) return null;
    try {
      if (value is Timestamp) {
        date = value.toDate();
      } else if (value is int) {
        date = DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        date = DateTime.tryParse(value);
      }
    } catch (_) {}

    if (date == null) return null;
    // Monta uma string dd/MM/yyyy HH:mm para ficar amigável na interface.
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = <String>[];
    // Mostra preço e quantidade resumidos na primeira linha.
    subtitle.add('${_formatCurrency(price)} · ${quantity}x');
    final dateStr = _formatDate(createdAt);
    if (dateStr != null) subtitle.add('Criado em $dateStr');

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir produto',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  // Aciona a exclusão quando o usuário clicar na lixeira.
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle.join('\n'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.45,
              ),
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    // Mensagem exibida quando não há nenhum produto cadastrado.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 68, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto cadastrado ainda.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Use o botão "Cadastrar novo produto" para começar.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

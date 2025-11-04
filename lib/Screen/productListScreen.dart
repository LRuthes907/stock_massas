// lib/screens/productsListScreen.dart
import 'package:corretor_prova/controller/productController.dart';
import 'package:corretor_prova/models/productModel.dart';
import 'package:corretor_prova/screens/productFormScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsListScreen extends StatelessWidget {
  ProductsListScreen({super.key});
  final c = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    c.load();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => c.load(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou SKU...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                c.query.value = v;
                c.load(v);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.error.value != null) {
                return Center(child: Text(c.error.value!));
              }
              if (c.products.isEmpty) {
                return const Center(child: Text('Nenhum produto encontrado.'));
              }
              return ListView.separated(
                itemCount: c.products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final Product p = c.products[i];
                  return ListTile(
                    title: Text('${p.name}  (Estoque: ${p.stock})'),
                    subtitle: Text('SKU: ${p.sku ?? '-'}  •  R\$ ${p.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductFormScreen(product: p),
                              ),
                            );
                            if (updated == true) c.load();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Excluir',
                          onPressed: () => _confirmDelete(context, c, p),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (created == true) c.load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductController c, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Confirmar exclusão de "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true && p.id != null) {
      await c.remove(p.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto excluído.')));
    }
  }
}

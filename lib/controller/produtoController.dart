import 'package:get/get.dart';
import 'package:stock_massas/models/produtoModel.dart';
import 'package:stock_massas/repository/produtoRepository.dart';

// Controla o fluxo de produtos entre a camada de dados e a UI.
class ProdutoController extends GetxController {
  final _repo = ProdutoRepository();

  final produtos = <Produto>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Carrega a lista assim que o controller é criado.
    loadProduto();
  }

  Future<void> loadProduto() async {
    try {
      // Marca a tela como carregando e limpa erros antigos.
      isLoading.value = true;
      error.value = null;

      final list = await _repo.getAllProduto();
      produtos.assignAll(list);
    } catch (e) {
      error.value = 'Falha ao carregar produto: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String? validateForm({
    required String nome,
    required String precoStr,
    required String quantidadeStr,
  }) {
    // Validação simples usada pelo formulário para evitar dados inválidos.
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';

    final price = double.tryParse(precoStr.replaceAll(',', '.'));
    if (price == null || price < 0) return 'Preço de venda inválido.';

    final stock = int.tryParse(quantidadeStr);
    if (stock == null || stock < 0) return 'Estoque inválido.';

    return null;
  }

  Future<bool> createProduto({
    required String nome,
    required double preco,
    required int quantidade,
    DateTime? dataValidade,
  }) async {
    try {
      // Salva o novo produto no banco local.
      isLoading.value = true;
      final p = Produto(
        nome: nome,
        preco: preco,
        quantidade: quantidade,
        dataValidade: dataValidade,
      );

      await _repo.create(p);
      await loadProduto();
      return true;
    } catch (e) {
      error.value = 'Falha ao salvar Produto: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduto(Produto produtoAtualizada) async {
    try {
      // Atualiza um registro existente.
      isLoading.value = true;
      await _repo.update(produtoAtualizada);
      await loadProduto();
      return true;
    } catch (e) {
      error.value = 'Falha ao atualizar Produto: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeProduto(int id) async {
    try {
      // Marca o produto como removido.
      isLoading.value = true;
      await _repo.delete(id);
      await loadProduto();
    } catch (e) {
      error.value = 'Falha ao excluir Produto: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

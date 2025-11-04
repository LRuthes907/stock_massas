class productController extends getxController
final _repo = produtoRepository();

final pizzas = <produto>[].obs
final isLoading =false.obs
final error = RxnString();


@override
  void onInit() {
    super.onInit();
    loadProduto(); 
  }

.
  Future<void> loadProduto() async {
    try {
      isLoading.value = true;
      error.value = null; 
      
      final list = await _repo.getAllProduto();
      pizzas.assignAll(list); 

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
      isLoading.value = true;
      final p = produto(
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
      isLoading.value = true;
      await loadProduto(); /
    } catch (e) {
      error.value = 'Falha ao excluir Produto: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
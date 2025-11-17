import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _descriptionCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Campo obrigatório';
    return null;
  }

  String? _validatePrice(String? value) {
    final raw = value?.replaceAll(',', '.').trim() ?? '';
    if (raw.isEmpty) return 'Informe o preço';
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed < 0) return 'Preço inválido';
    return null;
  }

  String? _validateStock(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Informe o estoque';
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) return 'Quantidade inválida';
    return null;
  }

  double _parsePrice(String value) =>
      double.parse(value.replaceAll(',', '.').trim());

  int _parseStock(String value) => int.parse(value.trim());

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final nome = _nameCtrl.text.trim();
    final preco = _parsePrice(_priceCtrl.text);
    final quantidade = _parseStock(_stockCtrl.text);
    final descricao = _descriptionCtrl.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    final data = <String, dynamic>{
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (descricao.isNotEmpty) data['descricao'] = descricao;
    if (user != null) data['usuarioId'] = user.uid;

    try {
      await FirebaseFirestore.instance.collection('produtos').add(data);

      if (!mounted) return;
      form.reset();
      _stockCtrl.text = '0';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar no Firebase: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = Colors.green.shade700;

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Cadastro de produtos'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 10,
                shadowColor: Colors.green.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.green.shade200, width: 0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Informações do produto',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nome do produto',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Preço',
                            prefixIcon: Icon(Icons.attach_money_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _validatePrice,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _stockCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade em estoque',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: _validateStock,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submit,
                            icon: const Icon(Icons.save_outlined),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            label: Text(
                              _isSubmitting ? 'Salvando...' : 'Salvar produto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stock_massas/Screen/productFormScreen.dart';
import 'package:stock_massas/Screen/productListScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color get _primaryColor => Colors.green.shade700;
  Color? get _backgroundColor => Colors.green[100];

  void _goToProductForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProductFormScreen()));
  }

  void _goToProductList(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final homeCard = _HomeHighlightCard(
            onCreateProduct: () => _goToProductForm(context),
            onViewProducts: () => _goToProductList(context),
          );

          if (isWide) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: _NavigationCard(
                            primaryColor: _primaryColor,
                            onProductTap: () => _goToProductForm(context),
                            onListTap: () => _goToProductList(context),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(child: homeCard),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: homeCard,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.green[50],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Stock Massas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Menu principal',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _DrawerTile(
                icon: Icons.add_box_outlined,
                label: 'Cadastro de produtos',
                onTap: () {
                  Navigator.of(context).pop();
                  _goToProductForm(context);
                },
              ),
              _DrawerTile(
                icon: Icons.inventory_2_outlined,
                label: 'Produtos cadastrados',
                onTap: () {
                  Navigator.of(context).pop();
                  _goToProductList(context);
                },
              ),
              const Divider(height: 32),
              const _DrawerTile(
                icon: Icons.settings_outlined,
                label: 'Configurações (em breve)',
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Text(
                  'Versão 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHighlightCard extends StatelessWidget {
  const _HomeHighlightCard({
    required this.onCreateProduct,
    required this.onViewProducts,
  });

  final VoidCallback onCreateProduct;
  final VoidCallback onViewProducts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 10,
      shadowColor: Colors.green.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.green.shade200, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.storefront,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bem-vindo ao Stock Massas',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gerencie seu estoque com a mesma praticidade da tela de login.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateProduct,
                icon: const Icon(Icons.add_circle_outline),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                label: const Text('Cadastrar novo produto'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewProducts,
                icon: const Icon(Icons.list_alt_outlined),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: Colors.green.shade700, width: 1.5),
                  foregroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                label: const Text('Ver produtos cadastrados'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.primaryColor,
    required this.onProductTap,
    required this.onListTap,
  });

  final Color primaryColor;
  final VoidCallback onProductTap;
  final VoidCallback onListTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.green.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.green.shade200, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Icon(Icons.menu, color: primaryColor),
              ),
              title: Text(
                'Menu rápido',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text('Acesse as principais ações'),
            ),
            const Divider(),
            _NavigationTile(
              icon: Icons.add_box_outlined,
              label: 'Cadastro de produtos',
              onTap: onProductTap,
            ),
            _NavigationTile(
              icon: Icons.inventory_2_outlined,
              label: 'Produtos cadastrados',
              onTap: onListTap,
            ),
            const Divider(height: 32),
            const _NavigationTile(
              icon: Icons.settings_outlined,
              label: 'Configurações (em breve)',
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.green.shade700 : Colors.grey;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}

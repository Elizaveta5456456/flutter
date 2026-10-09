import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/sticky_search_bar.dart';
import 'product_detail_screen.dart';

class FullCatalogScreen extends StatefulWidget {
  const FullCatalogScreen({super.key});

  @override
  State<FullCatalogScreen> createState() => _FullCatalogScreenState();
}

class _FullCatalogScreenState extends State<FullCatalogScreen> {
  final ApiService _api = ApiService();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<_CategoryBlock>> _future;
  final Set<int> _cartIds = {};
  String _query = '';

  static const int _perCategory = 8;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<_CategoryBlock>> _load({bool forceRefresh = false}) async {
    final all = await _api.fetchProducts(forceRefresh: forceRefresh);
    final ids = await _cart.getIds();
    _cartIds
      ..clear()
      ..addAll(ids);

    final byType = <String, List<Product>>{};
    for (final p in all) {
      final type = p.productType?.trim();
      if (type == null || type.isEmpty) continue;
      byType.putIfAbsent(type, () => []).add(p);
    }

    final blocks = <_CategoryBlock>[];
    for (final type in ApiService.productTypes) {
      final list = byType[type];
      if (list == null || list.isEmpty) continue;
      blocks.add(
        _CategoryBlock(
          type: type,
          products: list.take(_perCategory).toList(),
        ),
      );
    }

    
    for (final entry in byType.entries) {
      if (ApiService.productTypes.contains(entry.key)) continue;
      blocks.add(
        _CategoryBlock(
          type: entry.key,
          products: entry.value.take(_perCategory).toList(),
        ),
      );
    }

    return blocks;
  }

  void _reload() => setState(() => _future = _load(forceRefresh: true));

  List<_CategoryBlock> _filter(List<_CategoryBlock> blocks) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return blocks;
    return blocks
        .map((b) {
          final products = b.products.where((p) {
            return p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q) ||
                b.type.toLowerCase().contains(q);
          }).toList();
          return _CategoryBlock(type: b.type, products: products);
        })
        .where((b) => b.products.isNotEmpty)
        .toList();
  }

  Future<void> _toggleCart(Product product) async {
    final added = await _cart.toggle(product);
    if (!mounted) return;
    setState(() {
      if (added) {
        _cartIds.add(product.id);
      } else {
        _cartIds.remove(product.id);
      }
    });
  }

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => ProductDetailScreen(product: product, tabIndex: 1),
      ),
    );
    if (!mounted) return;
    final ids = await _cart.getIds();
    setState(() {
      _cartIds
        ..clear()
        ..addAll(ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StickySearchPage(
      controller: _searchController,
      onChanged: (v) => setState(() => _query = v),
      body: FutureBuilder<List<_CategoryBlock>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'ошибка загрузки\n${snapshot.error}',
              onRetry: _reload,
            );
          }

          final blocks = _filter(snapshot.data ?? []);

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              clipBehavior: Clip.none,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                for (var i = 0; i < blocks.length; i++) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        blocks[i].title,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppColors.textPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          height: 48 / 40,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ProductCardsSliverGrid(
                    products: blocks[i].products,
                    cartActiveIds: _cartIds,
                    padding: EdgeInsets.zero,
                    onTap: _openProduct,
                    onCartTap: _toggleCart,
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: i == blocks.length - 1 ? 24 : 56),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryBlock {
  final String type;
  final List<Product> products;

  const _CategoryBlock({required this.type, required this.products});

  String get title => type.replaceAll('_', '');
}

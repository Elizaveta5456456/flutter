import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/page_title_bar.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/sticky_search_bar.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String productType;

  const CategoryScreen({super.key, required this.productType});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _api = ApiService();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Product>> _future;
  final Set<int> _cartIds = {};
  String _query = '';

  String get _title => widget.productType.replaceAll('_', '');

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

  Future<List<Product>> _load({bool forceRefresh = false}) async {
    final products = await _api.fetchProducts(
      productType: widget.productType,
      forceRefresh: forceRefresh,
    );
    final ids = await _cart.getIds();
    _cartIds
      ..clear()
      ..addAll(ids);
    return products;
  }

  void _reload() => setState(() => _future = _load(forceRefresh: true));

  List<Product> _filter(List<Product> products) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
    }).toList();
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
        builder: (_) => ProductDetailScreen(product: product, tabIndex: 0),
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
      body: FutureBuilder<List<Product>>(
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

          final products = _filter(snapshot.data ?? []);

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              clipBehavior: Clip.none,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: PageTitleBar(title: _title),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                if (products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(message: 'ничего не найдено'),
                  )
                else
                  ProductCardsSliverGrid(
                    products: products,
                    cartActiveIds: _cartIds,
                    padding: const EdgeInsets.only(bottom: 24),
                    onTap: _openProduct,
                    onCartTap: _toggleCart,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

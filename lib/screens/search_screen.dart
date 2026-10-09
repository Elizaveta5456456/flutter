import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/sticky_search_bar.dart';
import 'category_screen.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late Future<List<Product>> _productsFuture = _loadProducts();
  String _query = '';
  bool _searchActive = false;
  final Set<int> _cartIds = {};

  static const List<String> _categoryLabels = [
    'lipstick',
    'mascara',
    'foundation',
    'blush',
    'eyeshadow',
    'eyeliner',
    'nailpolish',
    'bronzer',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_onFocusChange);
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _searchActive = _searchFocus.hasFocus || _query.trim().isNotEmpty;
    });
  }

  Future<List<Product>> _loadProducts({bool forceRefresh = false}) async {
    final products = await _api.fetchProducts(forceRefresh: forceRefresh);
    final shuffled = List<Product>.from(products)..shuffle(Random());
    final ids = await _cart.getIds();
    _cartIds
      ..clear()
      ..addAll(ids);
    return shuffled;
  }

  void _reload() =>
      setState(() => _productsFuture = _loadProducts(forceRefresh: true));

  String _typeForLabel(String label) {
    if (label == 'nailpolish') return 'nail_polish';
    return label;
  }

  List<Product> _filter(List<Product> products) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return products;

    final qCompact = q.replaceAll(RegExp(r'[\s_]'), '');

    return products.where((p) {
      if (p.name.toLowerCase().contains(q)) return true;
      if (p.brand.toLowerCase().contains(q)) return true;
      final type = (p.productType ?? '').toLowerCase();
      if (type.contains(q) || type.replaceAll('_', '').contains(qCompact)) {
        return true;
      }
      return false;
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

  void _openCategory(String label) {
    final type = _typeForLabel(label);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => CategoryScreen(productType: type),
      ),
    );
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

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _searchActive = _searchFocus.hasFocus || value.trim().isNotEmpty;
    });
  }

  String _foundLabel(int count) => 'найдено $count товаров';

  @override
  Widget build(BuildContext context) {
    return StickySearchPage(
      controller: _searchController,
      focusNode: _searchFocus,
      onChanged: _onQueryChanged,
      onSubmitted: () => _searchFocus.requestFocus(),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
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

          final all = snapshot.data ?? [];

          if (_searchActive) {
            return _buildActiveResults(all);
          }
          return _buildIdle(all);
        },
      ),
    );
  }

  
  Widget _buildActiveResults(List<Product> all) {
    final q = _query.trim();
    final results = _filter(all);
    final showCount = q.isNotEmpty;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async => _reload(),
      child: CustomScrollView(
        clipBehavior: Clip.none,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: showCount ? 40 : 20),
          ),
          if (showCount)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Text(
                  _foundLabel(results.length),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 22 / 16,
                    letterSpacing: -0.18,
                  ),
                ),
              ),
            ),
          if (results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(message: 'ничего не найдено'),
            )
          else
            ProductCardsSliverGrid(
              products: results,
              cartActiveIds: _cartIds,
              padding: const EdgeInsets.only(bottom: 24),
              onTap: _openProduct,
              onCartTap: _toggleCart,
            ),
        ],
      ),
    );
  }

  Widget _buildIdle(List<Product> all) {
    final recommended = all.take(6).toList();

    return CustomScrollView(
      clipBehavior: Clip.none,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'категории',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 22 / 16,
                    letterSpacing: -0.18,
                  ),
                ),
                const SizedBox(height: 24),
                ..._categoryLabels.map(
                  (label) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => _openCategory(label),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 24 / 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'также рекомендуем',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 22 / 16,
                letterSpacing: -0.18,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (recommended.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'ничего не найдено',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ProductCardsSliverGrid(
            products: recommended,
            cartActiveIds: _cartIds,
            onCartTap: _toggleCart,
            onTap: _openProduct,
          ),
      ],
    );
  }
}

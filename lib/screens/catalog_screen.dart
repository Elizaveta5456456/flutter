import 'dart:math';

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
import 'full_catalog_screen.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  CatalogScreenState createState() => CatalogScreenState();
}

class CatalogScreenState extends State<CatalogScreen> {
  final ApiService _api = ApiService();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();

  late Future<_CatalogData> _dataFuture;
  final Set<int> _cartIds = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_CatalogData> _load({bool forceRefresh = false}) async {
    final all = await _api.fetchProducts(forceRefresh: forceRefresh);
    final shuffled = List<Product>.from(all)..shuffle(Random());
    final catalog = shuffled.take(8).toList();
    final discounts = List<Product>.from(shuffled.skip(8).take(12));
    if (discounts.isEmpty) {
      discounts.addAll(catalog);
    }
    final ids = await _cart.getIds();
    return _CatalogData(catalog: catalog, discounts: discounts, cartIds: ids);
  }

  void _reload() {
    setState(() => _dataFuture = _load(forceRefresh: true));
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

  void _onSeeAll() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => const FullCatalogScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StickySearchPage(
      controller: _searchController,
      body: FutureBuilder<_CatalogData>(
        future: _dataFuture,
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

          final data = snapshot.data!;
          final cartIds = {...data.cartIds, ..._cartIds};

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              clipBehavior: Clip.none,
              slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'каталог',
                          style: TextStyle(
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
                      products: data.catalog,
                      cartActiveIds: cartIds,
                      padding: EdgeInsets.zero,
                      onCartTap: _toggleCart,
                      onTap: _openProduct,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: GestureDetector(
                          onTap: _onSeeAll,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'посмотреть все →',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 22 / 16,
                              letterSpacing: -0.18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _DiscountsSection(
                        products: data.discounts,
                        cartIds: cartIds,
                        onCartTap: _toggleCart,
                        onTap: _openProduct,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiscountsSection extends StatelessWidget {
  final List<Product> products;
  final Set<int> cartIds;
  final void Function(Product) onCartTap;
  final void Function(Product) onTap;

  const _DiscountsSection({
    required this.products,
    required this.cartIds,
    required this.onCartTap,
    required this.onTap,
  });

  static const double _frame5Height = 398;
  static const double _frame6Top = 28;
  static const double _greyHeight = 240;
  static const double _cardsFromGrey = 112;
  static const double _cardWidth = 160;
  static const double _cardHeight = 258;
  static const double _cardGap = 12;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
      child: SizedBox(
        height: _frame5Height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            
            const Positioned(
              top: _frame6Top,
              left: 0,
              right: 0,
              height: _greyHeight,
              child: ColoredBox(color: AppColors.textSecondary),
            ),
            
            const Positioned(
              top: 0,
              left: 20,
              child: Text(
                'скидки',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 48 / 40,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            
            Positioned(
              top: _frame6Top + _cardsFromGrey,
              left: 0,
              right: 0,
              height: _cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                clipBehavior: Clip.none,
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: _cardGap),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: _cardWidth,
                    height: _cardHeight,
                    child: ProductGridCard(
                      product: product,
                      width: _cardWidth,
                      align: ProductGridAlign.right,
                      cartActive: cartIds.contains(product.id),
                      onCartTap: () => onCartTap(product),
                      onTap: () => onTap(product),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogData {
  final List<Product> catalog;
  final List<Product> discounts;
  final Set<int> cartIds;

  const _CatalogData({
    required this.catalog,
    required this.discounts,
    required this.cartIds,
  });
}

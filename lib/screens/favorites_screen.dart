import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../navigation/home_tab.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/empty_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/page_title_bar.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/sticky_search_bar.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final int tabIndex;

  const FavoritesScreen({super.key, this.tabIndex = 2});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favorites = FavoritesService();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _items = [];
  final Set<int> _cartIds = {};
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _favorites.getFavorites();
    final ids = await _cart.getIds();
    if (!mounted) return;
    setState(() {
      _items = items;
      _cartIds
        ..clear()
        ..addAll(ids);
      _loading = false;
    });
  }

  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((p) {
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

  Future<void> _removeFavorite(Product product) async {
    await _favorites.toggleFavorite(product);
    if (!mounted) return;
    setState(() => _items.removeWhere((p) => p.id == product.id));
  }

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          tabIndex: widget.tabIndex,
        ),
      ),
    );
    if (!mounted) return;
    await _load();
  }

  void _onTab(int index) => requestHomeTab(index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StickySearchPage(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(
              child: PageTitleBar(title: 'избранное'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingView(),
              )
            else if (_filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(message: 'пока пусто'),
              )
            else
              ProductCardsSliverGrid(
                products: _filtered,
                cartActiveIds: _cartIds,
                showFavoriteBadge: true,
                onTap: _openProduct,
                onCartTap: _toggleCart,
                onFavoriteTap: _removeFavorite,
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.tabIndex,
        onTap: _onTab,
      ),
    );
  }
}

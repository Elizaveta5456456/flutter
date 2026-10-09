import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../navigation/home_tab.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';
import '../widgets/action_bar_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/cart_list_item.dart';
import '../widgets/empty_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/page_title_bar.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  final int tabIndex;

  const CartScreen({super.key, this.tabIndex = 2});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();

  List<Product> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _cart.getItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _remove(Product product) async {
    await _cart.toggle(product);
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
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: top + 16),
          ),
          const SliverToBoxAdapter(
            child: PageTitleBar(title: 'корзина'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingView(),
            )
          else if (_items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(message: 'корзина пуста'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: SliverList.separated(
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final product = _items[index];
                  return CartListItem(
                    product: product,
                    onTap: () => _openProduct(product),
                    onRemove: () => _remove(product),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.tabIndex,
        onTap: _onTab,
        aboveBar: ActionBarButton(
          label: 'к оплате',
          onPressed: () {},
        ),
      ),
    );
  }
}

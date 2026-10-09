import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../models/product.dart';
import '../navigation/home_tab.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/action_bar_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int tabIndex;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.tabIndex = 1,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FavoritesService _favorites = FavoritesService();
  final CartService _cart = CartService();

  bool _isFavorite = false;
  bool _inCart = false;
  bool _ready = false;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fav = await _favorites.isFavorite(product.id);
    final cart = await _cart.contains(product.id);
    if (!mounted) return;
    setState(() {
      _isFavorite = fav;
      _inCart = cart;
      _ready = true;
    });
  }

  Future<void> _toggleFavorite() async {
    if (!_ready) return;
    await _favorites.toggleFavorite(product);
    if (!mounted) return;
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _toggleCart() async {
    if (!_ready) return;
    final added = await _cart.toggle(product);
    if (!mounted) return;
    setState(() => _inCart = added);
  }

  String get _categoryTitle {
    final type = product.productType?.trim() ?? '';
    if (type.isEmpty) return 'товар';
    return type.replaceAll('_', '');
  }

  String get _description {
    final d = product.description?.trim();
    if (d == null || d.isEmpty) return 'описание';
    return d;
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, top + 16, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: SvgPicture.asset(
                              AppIcons.chevronBack,
                              width: 10,
                              height: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            _categoryTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: w - 20,
                            width: w,
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: w,
                              child: SizedBox(
                                width: w,
                                height: w,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ProductImage(
                                        imageUrl: product.imageLink,
                                        fit: BoxFit.cover,
                                        showBackground: false,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: _toggleFavorite,
                                        behavior: HitTestBehavior.opaque,
                                        child: SvgPicture.asset(
                                          _isFavorite
                                              ? AppIcons.heartActive
                                              : AppIcons.heartInactive,
                                          width: 66,
                                          height: 64,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.textPrimary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    height: 38 / 32,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  product.displayPrice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 30 / 24,
                                    letterSpacing: -0.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'описание',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 22 / 16,
                            letterSpacing: -0.18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _description,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 20 / 14,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.tabIndex,
        onTap: _onTab,
        aboveBar: ActionBarButton(
          label: _inCart ? 'добавлено' : 'в корзину',
          active: _inCart,
          onPressed: _toggleCart,
        ),
      ),
    );
  }
}

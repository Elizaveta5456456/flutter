import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'cart_button.dart';
import 'product_image.dart';

enum ProductGridAlign { left, right }

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onFavoriteTap;
  final bool cartActive;
  final bool showFavoriteBadge;
  final ProductGridAlign align;
  final double? width;

  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
    this.onCartTap,
    this.onFavoriteTap,
    this.cartActive = false,
    this.showFavoriteBadge = false,
    this.align = ProductGridAlign.left,
    this.width,
  });

  bool get _isRight => align == ProductGridAlign.right;

  @override
  Widget build(BuildContext context) {
    final textPadding = _isRight
        ? const EdgeInsets.only(right: 20)
        : const EdgeInsets.only(left: 20);

    
    final cartRight = _isRight ? 20.0 : 8.0;

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: AspectRatio(
                aspectRatio: 1,
                child: ColoredBox(
                  color: const Color(0xFFE4E4E7),
                  child: ProductImage(
                    imageUrl: product.imageLink,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (showFavoriteBadge)
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    AppIcons.heartBadge,
                    width: 29,
                    height: 28,
                  ),
                ),
              ),
            Positioned(
              right: cartRight,
              bottom: -16,
              child: CartButton(
                active: cartActive,
                onTap: onCartTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: textPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayBrand.toLowerCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 12 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 22 / 16,
                    letterSpacing: -0.18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.displayPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 24 / 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (width != null) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }
}

class ProductCardsGrid extends StatelessWidget {
  final List<Product> products;
  final Set<int> cartActiveIds;
  final void Function(Product product) onTap;
  final void Function(Product product) onCartTap;
  final void Function(Product product)? onFavoriteTap;
  final bool showFavoriteBadge;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductCardsGrid({
    super.key,
    required this.products,
    required this.cartActiveIds,
    required this.onTap,
    required this.onCartTap,
    this.onFavoriteTap,
    this.showFavoriteBadge = false,
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 24),
    this.shrinkWrap = false,
    this.physics,
  });

  static const double gap = 20;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      clipBehavior: Clip.none,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: 185 / 280,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductGridCard(
          product: product,
          align: index.isEven ? ProductGridAlign.left : ProductGridAlign.right,
          cartActive: cartActiveIds.contains(product.id),
          showFavoriteBadge: showFavoriteBadge,
          onCartTap: () => onCartTap(product),
          onFavoriteTap:
              onFavoriteTap == null ? null : () => onFavoriteTap!(product),
          onTap: () => onTap(product),
        );
      },
    );
  }
}

class ProductCardsSliverGrid extends StatelessWidget {
  final List<Product> products;
  final Set<int> cartActiveIds;
  final void Function(Product product) onTap;
  final void Function(Product product) onCartTap;
  final void Function(Product product)? onFavoriteTap;
  final bool showFavoriteBadge;
  final EdgeInsetsGeometry padding;

  const ProductCardsSliverGrid({
    super.key,
    required this.products,
    required this.cartActiveIds,
    required this.onTap,
    required this.onCartTap,
    this.onFavoriteTap,
    this.showFavoriteBadge = false,
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 24),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: ProductCardsGrid.gap,
          crossAxisSpacing: ProductCardsGrid.gap,
          childAspectRatio: 185 / 280,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return ProductGridCard(
              product: product,
              align:
                  index.isEven ? ProductGridAlign.left : ProductGridAlign.right,
              cartActive: cartActiveIds.contains(product.id),
              showFavoriteBadge: showFavoriteBadge,
              onCartTap: () => onCartTap(product),
              onFavoriteTap:
                  onFavoriteTap == null ? null : () => onFavoriteTap!(product),
              onTap: () => onTap(product),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}

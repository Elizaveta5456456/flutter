import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

class ProductRowCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showLove;

  const ProductRowCard({
    super.key,
    required this.product,
    this.onTap,
    this.onRemove,
    this.showLove = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 96,
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProductImage(imageUrl: product.imageLink),
                  ),
                  if (showLove)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: SvgPicture.asset(
                        AppIcons.love,
                        width: 29,
                        height: 28,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      maxLines: 1,
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
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    AppIcons.close,
                    width: 13,
                    height: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

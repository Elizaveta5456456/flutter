import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

class CartListItem extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const CartListItem({
    super.key,
    required this.product,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: ColoredBox(
                color: ProductImage.background,
                child: ProductImage(
                  imageUrl: product.imageLink,
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
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
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
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

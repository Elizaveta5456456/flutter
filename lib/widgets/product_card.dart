import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_row_card.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ProductRowCard(
      product: product,
      onTap: onTap,
      onRemove: onRemove,
    );
  }
}

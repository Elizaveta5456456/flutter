import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showBackground;

  static const Color background = Color(0xFFE4E4E7);

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final image = (imageUrl == null || imageUrl!.isEmpty)
        ? SizedBox(width: width, height: height)
        : Image.network(
            imageUrl!,
            width: width,
            height: height,
            fit: fit,
            alignment: Alignment.center,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF9D8970),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                SizedBox(width: width, height: height),
          );

    Widget child = showBackground
        ? ColoredBox(color: background, child: image)
        : image;

    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

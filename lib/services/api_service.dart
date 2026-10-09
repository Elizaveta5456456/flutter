import '../models/product.dart';
import 'product_cache.dart';

class ApiService {
  static const List<String> productTypes = [
    'lipstick',
    'mascara',
    'foundation',
    'blush',
    'eyeshadow',
    'eyeliner',
    'nail_polish',
    'bronzer',
  ];

  static String labelForType(String type) {
    return type.replaceAll('_', ' ');
  }

  
  Future<List<Product>> fetchProducts({
    String? productType,
    bool forceRefresh = false,
  }) {
    return ProductCache.instance.byType(
      productType,
      forceRefresh: forceRefresh,
    );
  }
}

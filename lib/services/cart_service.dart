import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class CartService {
  static const String _cartKey = 'cart_items';

  Future<List<Product>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_cartKey) ?? [];
    return raw
        .map((item) => Product.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> contains(int productId) async {
    final items = await getItems();
    return items.any((p) => p.id == productId);
  }

  Future<Set<int>> getIds() async {
    final items = await getItems();
    return items.map((p) => p.id).toSet();
  }

  Future<bool> toggle(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getItems();
    final exists = items.any((p) => p.id == product.id);

    if (exists) {
      items.removeWhere((p) => p.id == product.id);
    } else {
      items.add(product);
    }

    await prefs.setStringList(
      _cartKey,
      items.map((p) => jsonEncode(p.toJson())).toList(),
    );
    return !exists;
  }

  Future<int> getCount() async {
    final items = await getItems();
    return items.length;
  }
}

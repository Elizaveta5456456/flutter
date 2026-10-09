import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  static const String _profileNameKey = 'profile_name';

  Future<List<Product>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((item) => Product.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(int productId) async {
    final favorites = await getFavorites();
    return favorites.any((p) => p.id == productId);
  }

  Future<void> toggleFavorite(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final exists = favorites.any((p) => p.id == product.id);

    if (exists) {
      favorites.removeWhere((p) => p.id == product.id);
    } else {
      favorites.add(product);
    }

    await prefs.setStringList(
      _favoritesKey,
      favorites.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  Future<int> getFavoriteCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  Future<String> getProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileNameKey) ?? 'Гость';
  }

  Future<void> setProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileNameKey, name.trim().isEmpty ? 'Гость' : name.trim());
  }
}

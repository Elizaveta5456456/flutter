import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class ProductCache {
  ProductCache._();
  static final ProductCache instance = ProductCache._();

  static const String _prefsKey = 'products_cache_v1';
  static const String _baseUrl =
      'http://makeup-api.herokuapp.com/api/v1/products.json';

  List<Product>? _memory;
  Future<List<Product>>? _inflight;

  bool get isReady => _memory != null;

  List<Product> get products =>
      _memory == null ? const [] : List.unmodifiable(_memory!);

  
  Future<List<Product>> preload({bool forceRefresh = false}) {
    if (!forceRefresh && _memory != null) {
      return Future.value(_memory!);
    }
    if (!forceRefresh && _inflight != null) {
      return _inflight!;
    }
    _inflight = _load(forceRefresh: forceRefresh);
    return _inflight!.whenComplete(() => _inflight = null);
  }

  Future<List<Product>> getAll({bool forceRefresh = false}) =>
      preload(forceRefresh: forceRefresh);

  Future<List<Product>> byType(String? productType, {bool forceRefresh = false}) async {
    final all = await getAll(forceRefresh: forceRefresh);
    if (productType == null || productType.isEmpty) return all;
    return all.where((p) => p.productType == productType).toList();
  }

  Future<List<Product>> _load({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final fromDisk = await _readDisk();
      if (fromDisk != null && fromDisk.isNotEmpty) {
        _memory = fromDisk;
        
        _refreshFromNetwork();
        return fromDisk;
      }
    }

    final fromNet = await _fetchNetwork();
    _memory = fromNet;
    await _writeDisk(fromNet);
    return fromNet;
  }

  Future<void> _refreshFromNetwork() async {
    try {
      final fresh = await _fetchNetwork();
      _memory = fresh;
      await _writeDisk(fresh);
    } catch (_) {
      
    }
  }

  Future<List<Product>> _fetchNetwork() async {
    final response = await http
        .get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить товары (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>?> _readDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return null;
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDisk(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      
    }
  }
}

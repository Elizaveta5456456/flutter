class Product {
  final int id;
  final String name;
  final String brand;
  final String? price;
  final String? imageLink;
  final String? description;
  final String? productType;
  final double? rating;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    this.price,
    this.imageLink,
    this.description,
    this.productType,
    this.rating,
  });

  String get displayPrice {
    if (price == null || price!.isEmpty) return 'Цена не указана';
    return '\$$price';
  }

  String get displayBrand => brand.isEmpty ? 'Без бренда' : brand;

  String get displayType {
    if (productType == null || productType!.isEmpty) return 'Другое';
    return productType!.replaceAll('_', ' ');
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Без названия',
      brand: (json['brand'] as String?)?.trim() ?? '',
      price: json['price'] as String?,
      imageLink: _pickImage(json),
      description: json['description'] as String?,
      productType: json['product_type'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  static String? _pickImage(Map<String, dynamic> json) {
    final featured = json['api_featured_image'] as String?;
    final link = json['image_link'] as String?;
    final raw = (featured != null && featured.isNotEmpty) ? featured : link;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('//')) return 'https:$raw';
    return raw;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'image_link': imageLink,
      'api_featured_image': imageLink,
      'description': description,
      'product_type': productType,
      'rating': rating,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

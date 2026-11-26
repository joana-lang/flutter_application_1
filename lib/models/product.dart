class Product {
  final int productId;
  final String name;
  final double price;
  final int stock;
  final bool active;
  final String categoryName;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    required this.active,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final categoryMap = json['category'] as Map<String, dynamic>?;
    return Product(
      productId: (json['productId'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      price: ((json['price'] ?? 0) as num).toDouble(),
      stock: (json['stock'] ?? 0) as int,
      active: (json['active'] ?? true) as bool,
      categoryName: (categoryMap?['category'] ?? 'Sin categoría') as String,
    );
  }
}

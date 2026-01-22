class Product {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String imageUrl;
  final bool trending;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.trending,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      price: data['price'],
      stock: data['stock'],
      imageUrl: data['imageUrl'],
      trending: data['trending'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'trending': trending,
    };
  }
}

class Product {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String imageUrl;
  final bool trending;
  final List<String> details;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.trending,
    this.details = const [],
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? 'Unnamed Product',
      price: (data['price'] ?? 0) as int,
      stock: (data['stock'] ?? 0) as int,
      imageUrl:
          data['imageUrl'] ??
          data['image'] ??
          'https://via.placeholder.com/300x200?text=No+Image',
      trending: data['trending'] ?? false,
      details: data['details'] != null
          ? List<String>.from(data['details'])
          : <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'trending': trending,
      'details': details,
    };
  }
}

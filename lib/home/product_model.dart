import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final int price;
  final String image;
  final List<String> details;
  final bool trending;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.details,
    required this.trending,
    required this.stock,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unnamed',
      price: (data['price'] ?? 0).toInt(),
      image: data['image'] ??
          'https://via.placeholder.com/300x200?text=No+Image',
      details: List<String>.from(data['details'] ?? []),
      trending: data['trending'] ?? false,
      stock: (data['stock'] ?? 0).toInt(),
    );
  }
}

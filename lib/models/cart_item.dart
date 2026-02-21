import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final int price;
  final IconData icon;
  final String image;
  int quantity;

  int get totalPrice => price * quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'iconCodePoint': icon.codePoint,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      image: json['image'],
      quantity: json['quantity'] ?? 1,
    );
  }
}

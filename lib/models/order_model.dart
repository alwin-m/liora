import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String productId;
  final String productName;
  final String? imageUrl;
  final int price;
  final int quantity;
  final int total;
  final String fullName;
  final String address;
  final String phone;
  final DateTime createdAt;
  final String status;
  final DateTime? cancelledAt;

  OrderModel({
    required this.orderId,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.total,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.createdAt,
    required this.status,
    this.cancelledAt,
  });

  /// ✅ Parse from Firestore snapshot
  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      orderId: id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? 'Product',
      imageUrl: data['imageUrl'],
      price: (data['price'] ?? 0) as int,
      quantity: (data['quantity'] ?? 1) as int,
      total: (data['total'] ?? 0) as int,
      fullName: data['fullName'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'placed',
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// ✅ Serialize to Firestore (without orderId - it's the doc ID)
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'total': total,
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }
}

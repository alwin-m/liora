class OrderModel {
  final String orderId;
  final String productId;
  final String productName;
  final int price;
  final DateTime createdAt;
  final String status;

  OrderModel({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId, // ✅ FIX
      'productId': productId,
      'productName': productName,
      'price': price,
      'createdAt': createdAt,
      'status': status,
    };
  }
}

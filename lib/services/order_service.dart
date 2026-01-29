import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// ✅ Place order (ATOMIC)
  Future<void> placeOrder({
    required String productId,
    required String productName,
    required String imageUrl,
    required int price,
    required int quantity,
    required String fullName,
    required String address,
    required String phone,
  }) async {
    final uid = _auth.currentUser!.uid;

    final productRef = _db.collection('products').doc(productId);
    final orderRef =
        _db.collection('users').doc(uid).collection('orders').doc();

    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);
      final stock = productSnap['stock'];

      if (stock < quantity) {
        throw Exception('Insufficient stock');
      }

      // 🔥 Reduce stock by quantity
      transaction.update(productRef, {
        'stock': stock - quantity,
      });

      // 🔥 Create order
      final order = OrderModel(
        orderId: orderRef.id,
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity,
        total: price * quantity,
        fullName: fullName,
        address: address,
        phone: phone,
        createdAt: DateTime.now(),
        status: 'placed',
      );

      transaction.set(orderRef, order.toMap());
    });
  }

  /// ❌ Cancel order (ATOMIC)
  Future<void> cancelOrder({
    required String orderId,
    required String productId,
    required int quantity,
  }) async {
    final uid = _auth.currentUser!.uid;

    final productRef = _db.collection('products').doc(productId);
    final orderRef =
        _db.collection('users').doc(uid).collection('orders').doc(orderId);

    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);

      // 🔁 Restore stock by quantity (not hardcoded 1)
      transaction.update(productRef, {
        'stock': productSnap['stock'] + quantity,
      });

      // Mark order as cancelled instead of deleting
      transaction.update(orderRef, {
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
      });
    });
  }
}

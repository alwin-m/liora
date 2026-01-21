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
    required int price,
  }) async {
    final uid = _auth.currentUser!.uid;

    final productRef = _db.collection('products').doc(productId);
    final orderRef =
        _db.collection('users').doc(uid).collection('orders').doc();

    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);
      final stock = productSnap['stock'];

      if (stock <= 0) {
        throw Exception('Out of stock');
      }

      // 🔥 Reduce stock
      transaction.update(productRef, {
        'stock': stock - 1,
      });

      // 🔥 Create order
      final order = OrderModel(
        orderId: orderRef.id,
        productId: productId,
        productName: productName,
        price: price,
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
  }) async {
    final uid = _auth.currentUser!.uid;

    final productRef = _db.collection('products').doc(productId);
    final orderRef =
        _db.collection('users').doc(uid).collection('orders').doc(orderId);

    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);

      transaction.update(productRef, {
        'stock': productSnap['stock'] + 1,
      });

      transaction.delete(orderRef);
    });
  }
}

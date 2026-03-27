import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Place single product order (ATOMIC)
  Future<void> placeOrder({
    required String productId,
    required String productName,
    required String? imageUrl,
    required int price,
    required int quantity,
    required String fullName,
    required String address,
    required String phone,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final productRef = _db.collection('products').doc(productId);
    final orderRef = _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc();

    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);
      if (!productSnap.exists) throw Exception('Product not found');

      final data = productSnap.data()!;
      final stock = (data['stock'] as num? ?? 0).toInt();

      if (stock < quantity) {
        throw Exception('Insufficient stock');
      }

      // Reduce stock by quantity
      transaction.update(productRef, {
        'stock': FieldValue.increment(-quantity),
      });

      // Create order
      transaction.set(orderRef, {
        'orderId': orderRef.id,
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'total': price * quantity,
        'fullName': fullName,
        'address': address,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'placed',
      });
    });
  }

  /// Place multi-item cart order (ATOMIC)
  Future<void> placeCartOrder({
    required List<CartItem> cartItems,
    required String fullName,
    required String address,
    required String phone,
    required int totalAmount,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final userOrdersRef = _db.collection('users').doc(uid).collection('orders');
    final orderRef = userOrdersRef.doc();

    await _db.runTransaction((transaction) async {
      // 1. Verify stock for all items
      for (final item in cartItems) {
        final productRef = _db.collection('products').doc(item.id);
        final snap = await transaction.get(productRef);

        if (!snap.exists) throw Exception('${item.name} not found');

        final data = snap.data()!;
        final stock = (data['stock'] as num? ?? 0).toInt();

        if (stock < item.quantity) {
          throw Exception('${item.name} is out of stock');
        }
      }

      // 2. Reduce stock for all items
      for (final item in cartItems) {
        final productRef = _db.collection('products').doc(item.id);
        transaction.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
        });
      }

      // 3. Create the order document
      transaction.set(orderRef, {
        'orderId': orderRef.id,
        'items': cartItems
            .map(
              (item) => {
                'productId': item.id,
                'name': item.name,
                'image': item.image,
                'price': item.price,
                'quantity': item.quantity,
                'total': item.price * item.quantity,
              },
            )
            .toList(),
        'fullName': fullName,
        'address': address,
        'phone': phone,
        'totalAmount': totalAmount,
        'status': 'placed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Cancel order (ATOMIC)
  Future<void> cancelOrder({
    required String orderId,
    required String productId,
    required int quantity,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final productRef = _db.collection('products').doc(productId);
    final orderRef = _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderId);

    await _db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);

      final currentStock = (productSnap['stock'] as num? ?? 0).toInt();
      transaction.update(productRef, {'stock': currentStock + quantity});

      // Mark order as cancelled instead of deleting
      transaction.update(orderRef, {
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
      });
    });
  }
}

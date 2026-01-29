import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList();
      },
    );
  }

  /// 🔥 Reduce stock when user buys
  Future<void> reduceStock(String productId) async {
    final ref = _db.collection('products').doc(productId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      final currentStock = snapshot['stock'];
      if (currentStock <= 0) {
        throw Exception('Out of stock');
      }

      transaction.update(ref, {
        'stock': currentStock - 1,
      });
    });
  }

  /// 🔁 Restore stock if order cancelled
  Future<void> restoreStock(String productId, int quantity) async {
    final ref = _db.collection('products').doc(productId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      // 🔁 Restore by quantity (not hardcoded 1)
      transaction.update(ref, {
        'stock': snapshot['stock'] + quantity,
      });
    });
  }
}

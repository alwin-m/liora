import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalAmount =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  CartProvider() {
    fetchCart();
  }

  // ================= FETCH CART =================
  Future<void> fetchCart() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      _items.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        _items.add(
          CartItem(
            id: data['id'],
            name: data['name'],
            price: data['price'],
            stock: data['stock'] ?? 0, // ✅ Map stock from Firestore
            icon: Icons.shopping_bag,
            image: data['image'],
            quantity: data['quantity'] ?? 1,
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch cart error: $e");
    }
  }

  // ================= SAVE TO FIRESTORE =================
  Future<void> _saveCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User null — cart not saved");
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    try {
      // clear old cart
      final existing = await cartRef.get();
      for (var doc in existing.docs) {
        await doc.reference.delete();
      }

      // save new cart
      for (var item in _items) {
        await cartRef.doc(item.id).set(item.toJson());
      }

      debugPrint("🔥 CART SAVED TO FIRESTORE");
    } catch (e) {
      debugPrint("Cart save error: $e");
    }
  }

  // ================= ADD ITEM =================
  void addItem({
    required String id,
    required String name,
    required int price,
    required int stock, // ✅ Added stock parameter
    required IconData icon,
    required String image,
  }) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          price: price,
          stock: stock, // ✅ Store stock in CartItem
          icon: icon,
          image: image,
        ),
      );
    }

    _saveCart();
    notifyListeners();
  }

  // ================= REMOVE ITEM =================
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  // ================= REMOVE ONE =================
  void removeOneItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
    }

    _saveCart();
    notifyListeners();
  }

  // ================= CLEAR =================
  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}

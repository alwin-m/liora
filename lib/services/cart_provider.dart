import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = true;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  int get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart_items');
      if (cartString != null) {
        final List<dynamic> decodedList = json.decode(cartString);
        _items = decodedList.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = json.encode(
        _items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('cart_items', cartString);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void addItem({
    required String id,
    required String name,
    required int price,
    required IconData icon,
    required String image,
  }) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(id: id, name: name, price: price, icon: icon, image: image),
      );
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  void removeOneItem(String id) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity -= 1;
      } else {
        _items.removeAt(existingIndex);
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items = [];
    _saveCart();
    notifyListeners();
  }
}

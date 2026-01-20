// Simple cart service for managing items across the app
class CartItem {
  final String id;
  final String name;
  final int price;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });
}

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(CartItem item) {
    _items.add(item);
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
  }

  void clearCart() {
    _items.clear();
  }

  int getTotalPrice() {
    return _items.fold(0, (total, item) => total + item.price);
  }

  int getItemCount() => _items.length;
}

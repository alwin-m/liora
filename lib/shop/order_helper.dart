import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../services/cart_provider.dart';
import '../models/product_model.dart';

class OrderHelper {
  static final _orderService = OrderService();

  static Future<Map<String, String>> loadSavedUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return <String, String>{};

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? <String, dynamic>{};

    return {
      'fullName': (data['name'] ?? '').toString(),
      'phone': (data['phone'] ?? '').toString(),
      'address': (data['address'] ?? '').toString(),
      'city': (data['nearby'] ?? '').toString(),
      'postalCode': (data['pincode'] ?? '').toString(),
      'email': (user.email ?? '').toString(),
    };
  }

  static String toUserMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();

      if (message.startsWith('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }

  static void showError(BuildContext context, Object error) {
    debugPrint('Order error: $error');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(toUserMessage(error))));
  }

static void showSuccessSheet(BuildContext context, String address) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 48,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Order Confirmed!',
            style: Theme.of(sheetContext)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Text(
            'Your wellness essentials are on the way to:',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 8),

          Text(
            address,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext); // closes the bottom sheet
              },
              child: const Text('Back to Shopping'),
            ),
          ),

          SizedBox(height: MediaQuery.of(sheetContext).padding.bottom),
        ],
      ),
    ),
  );
}

  static Future<String?> buyProduct({
    required BuildContext context,
    required Product product,
    required String fullName,
    required String address,
    required String phone,
    required String city,
    required String postalCode,
    required Function(bool) onLoadingChanged,
  }) async {
    if (fullName.isEmpty || address.isEmpty || phone.isEmpty || city.isEmpty || postalCode.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Missing Details'),
          content: const Text('Please fill all details'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      onLoadingChanged(false);
      return null;
    }

    onLoadingChanged(true);
    try {
      await _orderService.placeOrder(
        productId: product.id,
        productName: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
        quantity: 1,
        fullName: fullName,
        address: address,
        phone: phone,
      );
      return address;
    } catch (e) {
      showError(context, e);
      return null;
    } finally {
      onLoadingChanged(false);
    }
  }

  static Future<String?> checkoutCart({
    required BuildContext context,
    required String fullName,
    required String address,
    required String phone,
    required String city,
    required String postalCode,
    required Function(bool) onLoadingChanged,
  }) async {
    if (fullName.isEmpty ||
        address.isEmpty ||
        phone.isEmpty ||
        city.isEmpty ||
        postalCode.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Missing Details'),
          content: const Text('Please fill all details'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      onLoadingChanged(false);
      return null;
    }

    final cartProvider = context.read<CartProvider>();
    final cartItems = List.of(cartProvider.items);

    // ✅ Stock Validation
    for (var item in cartItems) {
      if (item.quantity > item.stock) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Out of Stock'),
            content: Text(
              '${item.name} only has ${item.stock} item(s) left in stock.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        onLoadingChanged(false); // Ensure loading is stopped
        return null;
      }
    }

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return null;
    }

    onLoadingChanged(true);
    try {
      final totalAmount = cartItems.fold<int>(
        0,
        (runningTotal, item) => runningTotal + (item.price * item.quantity),
      );
      final deliveryAddress = '$address, $city - $postalCode';

      await _orderService.placeCartOrder(
        cartItems: cartItems,
        fullName: fullName,
        address: deliveryAddress,
        phone: phone,
        totalAmount: totalAmount,
      );

      cartProvider.clearCart();
      return deliveryAddress;
    } catch (e) {
      showError(context, e);
      return null;
    } finally {
      onLoadingChanged(false);
    }
  }

  static Future<void> showDeliverySheet(
    BuildContext parentContext,
    Product product,
  ) async {
    if (product.stock <= 0) {
      showDialog(
        context: parentContext,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Out of Stock'),
          content: Text('${product.name} is currently unavailable.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final saved = await loadSavedUserDetails();
    if (!parentContext.mounted) return;

    final nameCtrl = TextEditingController(text: saved['fullName'] ?? '');
    final addressCtrl = TextEditingController(text: saved['address'] ?? '');
    final cityCtrl = TextEditingController(text: saved['city'] ?? '');
    final zipCtrl = TextEditingController(text: saved['postalCode'] ?? '');
    final phoneCtrl = TextEditingController(text: saved['phone'] ?? '');
    bool isLoading = false;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.white, size: 32),
                      SizedBox(height: 12),
                      Text(
                        'Delivery Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF6F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.pink.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '?${product.price}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cityCtrl,
                              decoration: const InputDecoration(
                                labelText: 'City / Nearby',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: zipCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Postal Code',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            color: Color(0xFFD8BFD8),
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFFC1CC)),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD8BFD8)),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setDialogState(() => isLoading = true);
                                  final deliveryAddress = await buyProduct(
                                    context: dialogContext,
                                    product: product,
                                    fullName: nameCtrl.text.trim(),
                                    address: addressCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    city: cityCtrl.text.trim(),
                                    postalCode: zipCtrl.text.trim(),
                                    onLoadingChanged: (val) {
                                      if (dialogContext.mounted) {
                                        setDialogState(() => isLoading = val);
                                      }
                                    },
                                  );

                                  if (deliveryAddress != null) {
                                    Navigator.of(dialogContext).pop();
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      showSuccessSheet(parentContext, deliveryAddress);
                                    });
                                  }
                                },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFC1CC),
                                  Color(0xFFD8BFD8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Confirm & Pay on Delivery',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showCartSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CartSheet(mainContext: parentContext),
    );
  }
}

class CartSheet extends StatefulWidget {
  final BuildContext mainContext;

  const CartSheet({super.key, required this.mainContext});

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  bool showDelivery = false;
  bool _isSubmitting = false;
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillSavedDetails();
  }

  Future<void> _prefillSavedDetails() async {
    final saved = await OrderHelper.loadSavedUserDetails();
    if (!mounted) return;
    _nameCtrl.text = saved['fullName'] ?? '';
    _addrCtrl.text = saved['address'] ?? '';
    _phoneCtrl.text = saved['phone'] ?? '';
    _cityCtrl.text = saved['city'] ?? '';
    _zipCtrl.text = saved['postalCode'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: MediaQuery.of(context).size.height * (showDelivery ? 0.9 : 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showDelivery ? 'Delivery Details' : 'Your Cart',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!showDelivery)
                  cart.items.isNotEmpty
                      ? TextButton(
                          onPressed: () => cart.clearCart(),
                          child: const Text('Clear'),
                        )
                      : const SizedBox.shrink(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: showDelivery ? _buildDeliveryForm() : _buildItemList(cart),
            ),
          ),
          if (cart.items.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${cart.totalAmount}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (showDelivery) {
                                final deliveryAddress =
                                    await OrderHelper.checkoutCart(
                                      context: context,
                                      fullName: _nameCtrl.text.trim(),
                                      address: _addrCtrl.text.trim(),
                                      phone: _phoneCtrl.text.trim(),
                                      city: _cityCtrl.text.trim(),
                                      postalCode: _zipCtrl.text.trim(),
                                      onLoadingChanged: (val) {
                                        if (mounted)
                                          setState(() => _isSubmitting = val);
                                      },
                                    );
                                if (deliveryAddress != null) {
                                  Navigator.pop(context);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    OrderHelper.showSuccessSheet(
                                      widget.mainContext,
                                      deliveryAddress,
                                    );
                                  });
                                }
                              } else {
                                setState(() => showDelivery = true);
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(showDelivery ? 'Place Order' : 'Checkout'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemList(CartProvider cart) {
    if (cart.items.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Your cart is empty'),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go shopping'),
          ),
        ],
      );
    }

    return Column(
      children: cart.items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('₹${item.price}'),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => cart.removeOneItem(item.id),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => cart.addItem(
                      id: item.id,
                      name: item.name,
                      price: item.price,
                      stock: item.stock, // ✅ Pass stock
                      icon: Icons.shopping_bag,
                      image: item.image,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryForm() {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _addrCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Delivery Address',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _zipCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  prefixIcon: Icon(Icons.mark_as_unread_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        const _PaymentBadge(),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => showDelivery = false),
          child: const Text('Back to Cart'),
        ),
      ],
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: Colors.pink,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Pay on Delivery available',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartBadge extends StatelessWidget {
  final VoidCallback onTap;
  const CartBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) => GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
              ),
            ),
            if (cart.itemCount > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


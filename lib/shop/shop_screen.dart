import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lioraa/services/cart_provider.dart';
import 'package:lioraa/models/product_model.dart';
import 'package:lioraa/core/app_theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool isProcessing = false;

  void _showAddedNotification(String productName) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$productName added to cart',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: cs.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraTheme.radiusSmall),
        ),
        margin: const EdgeInsets.all(LioraTheme.space16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void addToCart(Product product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Out of stock')));
      return;
    }

    context.read<CartProvider>().addItem(
      id: product.id,
      name: product.name,
      price: product.price,
      icon: Icons.shopping_bag_rounded,
      image: product.imageUrl,
    );

    _showAddedNotification(product.name);
  }

  Future<void> checkoutCart(
    String fullName,
    String address,
    String phone,
    String city,
    String postalCode,
  ) async {
    if (fullName.isEmpty ||
        address.isEmpty ||
        phone.isEmpty ||
        city.isEmpty ||
        postalCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all details')));
      return;
    }

    if (isProcessing) return;
    setState(() => isProcessing = true);

    final cartProvider = context.read<CartProvider>();
    final cartItems = cartProvider.items;

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;

      await db.runTransaction((txn) async {
        for (final item in cartItems) {
          final productRef = db.collection('products').doc(item.id);
          final snap = await txn.get(productRef);

          if (!snap.exists) throw Exception('Product ${item.name} not found');

          final stock = (snap.data()?['stock'] ?? 0) as int;

          if (stock < item.quantity) {
            throw Exception('${item.name} is out of stock');
          }

          txn.update(productRef, {'stock': stock - item.quantity});

          final orderRef = db
              .collection('users')
              .doc(uid)
              .collection('orders')
              .doc();

          txn.set(orderRef, {
            'orderId': orderRef.id,
            'productId': item.id,
            'productName': item.name,
            'imageUrl': item.image,
            'price': item.price,
            'quantity': item.quantity,
            'total': item.price * item.quantity,
            'fullName': fullName,
            'address': '$address, $city - $postalCode',
            'phone': phone,
            'status': 'placed',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });

      cartProvider.clearCart();
      _showSuccessSheet(address);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _showSuccessSheet(String address) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(LioraTheme.space24),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(LioraTheme.radiusSheet),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: LioraTheme.space8),
            Container(
              padding: const EdgeInsets.all(LioraTheme.space16),
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
            const SizedBox(height: LioraTheme.space24),
            Text(
              'Order Confirmed!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LioraTheme.space12),
            Text(
              'Your wellness essentials are on the way to:',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withAlpha(160)),
            ),
            const SizedBox(height: LioraTheme.space8),
            Text(
              address,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LioraTheme.space32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Shop'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        onCheckout: (name, addr, phone, city, zip) =>
            checkoutCart(name, addr, phone, city, zip),
      ),
    );
  }

  Future<void> _buyNowPurchase(
    Product product,
    String fullName,
    String address,
    String phone,
    String city,
    String postalCode,
  ) async {
    if (fullName.isEmpty ||
        address.isEmpty ||
        phone.isEmpty ||
        city.isEmpty ||
        postalCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all details')));
      return;
    }

    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;

      await db.runTransaction((txn) async {
        final productRef = db.collection('products').doc(product.id);
        final snap = await txn.get(productRef);

        if (!snap.exists) throw Exception('Product not found');
        final stock = (snap.data()?['stock'] ?? 0) as int;
        if (stock < 1) throw Exception('Out of stock');

        txn.update(productRef, {'stock': stock - 1});

        final orderRef = db
            .collection('users')
            .doc(uid)
            .collection('orders')
            .doc();

        txn.set(orderRef, {
          'orderId': orderRef.id,
          'productId': product.id,
          'productName': product.name,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'quantity': 1,
          'total': product.price,
          'fullName': fullName,
          'address': '$address, $city - $postalCode',
          'phone': phone,
          'status': 'placed',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      _showSuccessSheet('$address, $city - $postalCode');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _showDirectCheckout(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DirectCheckoutSheet(
        product: product,
        onCheckout: (name, addr, phone, city, zip) =>
            _buyNowPurchase(product, name, addr, phone, city, zip),
      ),
    );
  }

  void _showProductDetails(
    BuildContext context,
    Product product,
    VoidCallback onAddToCart,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailsSheet(
        product: product,
        onAddToCart: onAddToCart,
        onBuyNow: () {
          Navigator.pop(context);
          _showDirectCheckout(product);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [_buildAppBar(cs), _buildHeader(cs), _buildProductGrid(cs)],
      ),
    );
  }

  Widget _buildAppBar(ColorScheme cs) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      centerTitle: false,
      title: Text(
        'Wellness Shop',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        _CartBadge(onTap: _showCartSheet),
        const SizedBox(width: LioraTheme.space16),
      ],
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LioraTheme.space24,
          LioraTheme.space8,
          LioraTheme.space24,
          LioraTheme.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Curated for your rhythm',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withAlpha(140),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ColorScheme cs) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: LioraTheme.space24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: LioraTheme.space16,
                mainAxisSpacing: LioraTheme.space16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ShimmerCard(),
                childCount: 6,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No products available right now.')),
          );
        }

        final docs = snapshot.data!.docs;
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: LioraTheme.space24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: LioraTheme.space16,
              mainAxisSpacing: LioraTheme.space16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = Product.fromMap(
                docs[index].id,
                docs[index].data() as Map<String, dynamic>,
              );
              return _ProductCard(
                product: product,
                onTap: () => _showProductDetails(
                  context,
                  product,
                  () => addToCart(product),
                ),
              );
            }, childCount: docs.length),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LioraTheme.pureWhite,
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(LioraTheme.radiusCard),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => _ShimmerImage(),
                    ),
                  ),
                  if (product.trending)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: LioraTheme.blushRose,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'TRENDING',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w800,
                            color: LioraTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: LioraTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          color: LioraTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: LioraTheme.lavenderMuted.withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: LioraTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _ProductDetailsSheet({
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LioraTheme.radiusSheet),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LioraTheme.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '₹${product.price}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.stock > 0 ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      color: product.stock > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About this product',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...product.details.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(child: Text(d)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              LioraTheme.space24,
              LioraTheme.space8,
              LioraTheme.space24,
              MediaQuery.of(context).padding.bottom + LioraTheme.space16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: product.stock > 0
                          ? () {
                              onAddToCart();
                              Navigator.pop(context);
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFF7C8D0),
                          width: 1.5,
                        ),
                        foregroundColor: LioraTheme.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: product.stock > 0 ? onBuyNow : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7C8D0),
                        foregroundColor: LioraTheme.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _CartBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<CartProvider>(
      builder: (context, cart, _) => GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withAlpha(120),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined, color: cs.onSurface),
            ),
            if (cart.itemCount > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '${cart.itemCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartSheet extends StatefulWidget {
  final Function(String, String, String, String, String) onCheckout;
  const _CartSheet({required this.onCheckout});

  @override
  State<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<_CartSheet> {
  bool showDelivery = false;
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cart = context.watch<CartProvider>();

    return AnimatedContainer(
      duration: LioraTheme.durationMedium,
      curve: LioraTheme.curveStandard,
      height: MediaQuery.of(context).size.height * (showDelivery ? 0.9 : 0.7),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LioraTheme.radiusSheet),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LioraTheme.space24),
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
              padding: const EdgeInsets.all(LioraTheme.space24),
              child: showDelivery
                  ? _buildDeliveryForm(cs)
                  : _buildItemList(cart, cs),
            ),
          ),
          if (cart.items.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                LioraTheme.space24,
                LioraTheme.space8,
                LioraTheme.space24,
                MediaQuery.of(context).padding.bottom + LioraTheme.space16,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: cs.onSurface.withAlpha(140),
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
                      onPressed: () {
                        if (showDelivery) {
                          widget.onCheckout(
                            nameCtrl.text,
                            addressCtrl.text,
                            phoneCtrl.text,
                            cityCtrl.text,
                            zipCtrl.text,
                          );
                          Navigator.pop(context);
                        } else {
                          setState(() => showDelivery = true);
                        }
                      },
                      child: Text(showDelivery ? 'Place Order' : 'Checkout'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemList(CartProvider cart, ColorScheme cs) {
    if (cart.items.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.shopping_bag_outlined, size: 64, color: cs.outlineVariant),
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
      children: cart.items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.image,
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
                          icon: Icons.shopping_bag,
                          image: item.image,
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDeliveryForm(ColorScheme cs) {
    return Column(
      children: [
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: addressCtrl,
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
                controller: cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: zipCtrl,
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
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        _PaymentBadge(cs: cs),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => showDelivery = false),
          child: const Text('Back to Cart'),
        ),
      ],
    );
  }
}

class _DirectCheckoutSheet extends StatefulWidget {
  final Product product;
  final Function(String, String, String, String, String) onCheckout;

  const _DirectCheckoutSheet({required this.product, required this.onCheckout});

  @override
  State<_DirectCheckoutSheet> createState() => _DirectCheckoutSheetState();
}

class _DirectCheckoutSheetState extends State<_DirectCheckoutSheet> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        LioraTheme.space24,
        12,
        LioraTheme.space24,
        MediaQuery.of(context).padding.bottom + LioraTheme.space16,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LioraTheme.radiusSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct Purchase',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withAlpha(140),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${widget.product.price}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressCtrl,
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
                  controller: cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: zipCtrl,
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
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 24),
          _PaymentBadge(cs: cs),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onCheckout(
                  nameCtrl.text,
                  addressCtrl.text,
                  phoneCtrl.text,
                  cityCtrl.text,
                  zipCtrl.text,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7C8D0),
                foregroundColor: LioraTheme.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Confirm Purchase'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final ColorScheme cs;
  const _PaymentBadge({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primaryContainer.withAlpha(100)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pay on Delivery available',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
        ),
      ),
    );
  }
}

class _ShimmerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }
}

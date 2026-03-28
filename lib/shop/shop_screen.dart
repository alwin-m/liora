// ===================== IMPORTS =====================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:lioraa/services/cart_provider.dart';
import '../models/product_model.dart';
import '../services/connectivity_service.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_bottom_sheet.dart';

import 'show_product.dart';
import 'order_helper.dart';

// ===================== SHOP SCREEN =====================
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
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
      stock: product.stock, // ✅ Pass stock
      icon: Icons.shopping_bag_rounded,
      image: product.imageUrl,
    );

    // Show simple notification
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCartSheet() => OrderHelper.showCartSheet(context);

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [_buildAppBar(), _buildHeader(), _buildProductGrid()],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      title: Text(
        'Wellness Shop',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        CartBadge(onTap: _showCartSheet),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Text(
          'Curated for your rhythm',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
        ),
      ),
    );
  }

  // ===================== PRODUCT GRID =====================
  Widget _buildProductGrid() {
    return FutureBuilder<bool>(
      future: ConnectivityService().isConnected(),
      builder: (context, connectivitySnapshot) {
        final isOnline = connectivitySnapshot.data ?? false;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            // Loading state - show skeletons
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GestureDetector(
                      onTap: !isOnline
                          ? () {
                              StatusBottomSheet.showOfflineError(
                                context,
                                title: "You're Offline",
                                description:
                                    "Shopping is unavailable without internet, but your cycle data is always safe.",
                                canUse: "Cycle tracking & local history",
                                cantUse: "Shopping features (loading paused)",
                              );
                            }
                          : null,
                      child: const ProductSkeletonCard(),
                    ),
                    childCount: 6,
                  ),
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Unable to load products",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Trigger rebuild
                          setState(() {});
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No products available",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = Product.fromMap(
                    docs[index].id,
                    docs[index].data() as Map<String, dynamic>,
                  );

                  return _ProductCard(
                    product: product,
                    onTap: () => _showProductPopup(product),
                    isOnline: isOnline,
                  );
                }, childCount: docs.length),
              ),
            );
          },
        );
      },
    );
  }

  /// =====================
  /// PRODUCT DIALOG + DELIVERY SHEET
  /// =====================
  void _showProductPopup(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          onAddToCart: addToCart,
          onBuyNow: (p) => OrderHelper.showDeliverySheet(context, p),
        ),
      ),
    );
  }
}

// ===================== PRODUCT CARD =====================
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isOnline;

  const _ProductCard({
    required this.product,
    required this.onTap,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    if (product.stock <= 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

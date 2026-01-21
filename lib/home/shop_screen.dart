import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../core/components.dart';

// Product Model
class Product {
  final String id;
  final String name;
  final int price;
  final String image;
  final List<String> details;
  final bool trending;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.details,
    required this.trending,
    required this.stock,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Product',
      price: (data['price'] ?? 0),
      image: data['image'] ?? 'https://via.placeholder.com/300x200?text=No+Image',
      details: List<String>.from(data['details'] ?? []),
      trending: data['trending'] ?? false,
      stock: (data['stock'] ?? 0),
    );
  }
}

// Shop Screen
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Product> cart = [];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop',
                    style: AppTheme.displayMedium,
                  ),
                  const SizedBox(height: AppTheme.lg),

                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: AppTheme.roundedMd,
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.lg,
                          vertical: AppTheme.md,
                        ),
                      ),
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Products
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: AppTheme.lg),
                          Text(
                            'No products available',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final products = snapshot.data!.docs
                      .map((doc) => Product.fromFirestore(doc))
                      .toList();

                  final filteredProducts = _searchQuery.isEmpty
                      ? products
                      : products
                          .where((p) => p.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppTheme.lg,
                      mainAxisSpacing: AppTheme.lg,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(
                        product: product,
                        onTap: () => _showProductDetails(product),
                        onAddToCart: () => _addToCart(product),
                      );
                    },
                  );
                },
              ),
            ),

            // Cart summary
            if (cart.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.surfaceContainerHigh,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cart.length} items in cart',
                        style: AppTheme.labelLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.lg,
                          vertical: AppTheme.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: AppTheme.roundedMd,
                        ),
                        child: Text(
                          'View Cart',
                          style: AppTheme.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    if (product.stock <= 0) {
      showCalmSnackBar(
        context,
        message: 'Out of stock',
        icon: Icons.info_outline,
      );
      return;
    }

    setState(() => cart.add(product));
    showCalmSnackBar(
      context,
      message: '${product.name} added to cart',
      icon: Icons.check_circle_outline,
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: AppTheme.radiusLg,
        ),
      ),
      builder: (context) => _ProductDetailsSheet(
        product: product,
        onAddToCart: () {
          _addToCart(product);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Product Card
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftContainer(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: AppTheme.radiusMd,
              ),
              child: Image.network(
                product.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: AppTheme.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  );
                },
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.labelLarge,
                    ),

                    const Spacer(),

                    // Price and stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product.price}',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                        if (product.stock > 0)
                          Text(
                            '${product.stock} left',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.success,
                            ),
                          )
                        else
                          Text(
                            'Out of stock',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.error,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.md),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: AppTheme.roundedMd,
                        child: InkWell(
                          onTap:
                              product.stock > 0 ? onAddToCart : null,
                          borderRadius: AppTheme.roundedMd,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.sm,
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: product.stock > 0
                                  ? AppTheme.primary
                                  : AppTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Details Sheet
class _ProductDetailsSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductDetailsSheet({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: AppTheme.roundedLg,
              child: Image.network(
                product.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppTheme.lg),

            // Product name and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: AppTheme.displayMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.md,
                    vertical: AppTheme.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: AppTheme.roundedMd,
                  ),
                  child: Text(
                    '₹${product.price}',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // Description
            if (product.details.isNotEmpty) ...[
              Text(
                'Details',
                style: AppTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.md),
              ...product.details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: AppTheme.md),
                      Expanded(
                        child: Text(
                          detail,
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.lg),
            ],

            // Stock info
            Container(
              padding: const EdgeInsets.all(AppTheme.md),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: AppTheme.roundedMd,
              ),
              child: Row(
                children: [
                  Icon(
                    product.stock > 0
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: product.stock > 0
                        ? AppTheme.success
                        : AppTheme.error,
                  ),
                  const SizedBox(width: AppTheme.md),
                  Expanded(
                    child: Text(
                      product.stock > 0
                          ? '${product.stock} units available'
                          : 'Out of stock',
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Add to cart button
            SizedBox(
              width: double.infinity,
              child: MinimalButton(
                label: 'Add to Cart',
                onPressed: onAddToCart,
                icon: Icons.shopping_bag_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

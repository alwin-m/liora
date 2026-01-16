// Liora – Shop Screen (Full Runnable Flutter Code)
// Japanese‑minimal, elegant e‑commerce UI
// Screen renamed properly to ShopScreen

import 'package:flutter/material.dart';

void main() {
  runApp(const LioraApp());
}

class LioraApp extends StatelessWidget {
  const LioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liora',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        fontFamily: 'Inter',
      ),
      home: const ShopScreen(),
    );
  }
}

// ==========================
// SHOP SCREEN
// ==========================

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Organic Wellness Kit',
      'price': 999,
      'icon': Icons.spa,
    },
    {
      'id': 2,
      'name': 'Herbal Comfort Pads',
      'price': 299,
      'icon': Icons.local_florist,
    },
    {
      'id': 3,
      'name': 'Calming Tea Blend',
      'price': 199,
      'icon': Icons.emoji_nature,
    },
    {
      'id': 4,
      'name': 'Heating Relief Pad',
      'price': 1299,
      'icon': Icons.whatshot,
    },
  ];

  final List<Map<String, dynamic>> cart = [];

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Liora Shop',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                if (cart.isNotEmpty)
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.black,
                    child: Text(
                      cart.length.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Icon(
                    product['icon'],
                    size: 48,
                    color: Colors.grey.shade700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      Text(
                        product['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${product['price']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          );
        },
      ),
    );
  }
}
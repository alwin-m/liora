import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  Future<void> _cancelOrder({
    required String orderId,
    required String productId,
    required int quantity,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;

    final orderRef =
        db.collection('users').doc(uid).collection('orders').doc(orderId);
    final productRef = db.collection('products').doc(productId);

    await db.runTransaction((transaction) async {
      final productSnap = await transaction.get(productRef);
      if (!productSnap.exists) return;

      final currentStock = productSnap['stock'] ?? 0;

      // 🔁 Restore stock by quantity (not hardcoded 1)
      transaction.update(productRef, {
        'stock': currentStock + quantity,
      });

      // ❌ Mark order as cancelled
      transaction.update(orderRef, {
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
=======

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFADADD), Color(0xFFE6E6FA)],
>>>>>>> 246b851c70c554cdc3c6028cf00b4384761d76af
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
<<<<<<< HEAD
        title: Text(
          'My Orders',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFDF6F9),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final productName = data['productName'] ?? 'Product';
              final price = data['price'] ?? 0;
              final quantity = (data['quantity'] ?? 1) as int;
              final status = data['status'] ?? 'placed';
              final productId = data['productId'];
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final imageUrl = data['imageUrl'] ?? '';
              final fullName = data['fullName'] ?? '';
              final address = data['address'] ?? '';

              final isPlaced = status == 'placed';
              final statusColor = isPlaced ? Colors.green : Colors.red;
              final statusIcon = isPlaced ? Icons.check_circle : Icons.cancel;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼 Product Image (if available)
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🛍 Order ID (subtle)
                          Text(
                            'Order #${doc.id.substring(0, 8).toUpperCase()}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 🛍 Product Name
                          Text(
                            productName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 📅 Order Date
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 💰 Price & Quantity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${price.toString()}',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Qty: $quantity',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // 📍 Delivery Address
                          if (address.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery to: $fullName',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[600],
=======
        title: const Text(
          '📦 MY ORDERS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFFE67598),
          ),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: user == null
          ? const Center(
              child: Text('Please sign in to view orders'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F6152),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start shopping to place your first order',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data!.docs[index];
                    final data = order.data() as Map<String, dynamic>;
                    final timestamp = data['createdAt'] as Timestamp?;
                    final date = timestamp?.toDate() ?? DateTime.now();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8DFCE),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade100.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFE67598),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${date.day} ${_month(date.month)} ${date.year}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (data['status'] ?? 'pending')
                                                    .toString()
                                                    .toLowerCase() ==
                                                'order placed'
                                            ? Colors.green.shade100
                                            : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    data['status'] ?? 'Pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: (data['status'] ?? 'pending')
                                                  .toString()
                                                  .toLowerCase() ==
                                              'order placed'
                                          ? Colors.green.shade700
                                          : Colors.blue.shade700,
                                    ),
>>>>>>> 246b851c70c554cdc3c6028cf00b4384761d76af
                                  ),
                                ),
                              ],
                            ),
<<<<<<< HEAD

                          const SizedBox(height: 16),

                          // 🟢 Status + Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status Chip with Icon
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 16,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      status.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                        letterSpacing: 0.5,
=======
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['productName'] ?? 'Product',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6F6152),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: 1',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
>>>>>>> 246b851c70c554cdc3c6028cf00b4384761d76af
                                      ),
                                    ),
                                  ],
                                ),
<<<<<<< HEAD
                              ),

                              // ❌ Cancel Button (only if placed)
                              if (isPlaced)
                                TextButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Cancel Order'),
                                        content: Text(
                                          'Cancel "$productName"?\nStock will be restored.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Keep It'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Yes, Cancel'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        await _cancelOrder(
                                          orderId: doc.id,
                                          productId: productId,
                                          quantity: quantity,
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Order cancelled, stock restored',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to cancel: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Cancel'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
=======
                                Text(
                                  '₹${data['price'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE67598),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['address'] ?? 'Not provided',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6F6152),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _month(int m) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m];
  }
>>>>>>> 246b851c70c554cdc3c6028cf00b4384761d76af
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  static const Color _brandBlue = Color(0xFF2874F0);
  static const Color _screenBg = Color(0xFFF1F3F6);

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  List<Map<String, dynamic>> _extractOrderItems(Map<String, dynamic> data) {
    if (data['items'] is List) {
      final rawItems = data['items'] as List;
      return rawItems.map<Map<String, dynamic>>((item) {
        final map = (item as Map).cast<String, dynamic>();
        final qty = _asInt(map['quantity'], fallback: 1);
        final unitPrice = _asInt(map['price']);
        return {
          'name': map['name'] ?? 'Product',
          'quantity': qty,
          'price': unitPrice,
          'lineTotal': unitPrice * qty,
          'image': map['image'] ?? '',
        };
      }).toList();
    }

    final qty = _asInt(data['quantity'], fallback: 1);
    final unitPrice = _asInt(data['price']);
    return [
      {
        'name': data['productName'] ?? 'Product',
        'quantity': qty,
        'price': unitPrice,
        'lineTotal': unitPrice * qty,
        'image': data['imageUrl'] ?? '',
      },
    ];
  }

  Future<void> _showOrderDetailsDialog({
    required BuildContext context,
    required String orderId,
    required DateTime createdAt,
    required String status,
    required String fullName,
    required String address,
    required List<Map<String, dynamic>> items,
    required int grandTotal,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order ID: ${orderId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Placed on ${_formatDate(createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'placed'
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: status == 'placed'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 12, color: Color(0xFFE8ECF1)),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name']?.toString() ?? 'Product',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qty: ${item['quantity']}  |  Unit: Rs ${item['price']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rs ${item['lineTotal']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(
                  'Deliver to: ${fullName.isEmpty ? '-' : fullName}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  address.isEmpty ? '-' : address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs $grandTotal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelOrder({required String orderId}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;

    final orderRef = db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderId);

    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) return;

    final data = orderSnap.data() as Map<String, dynamic>;
    final batch = db.batch();

    void queueRestore(String? rawId, int qty) {
      final productId = rawId?.trim();
      if (productId == null || productId.isEmpty) return;
      if (productId.contains('/')) return;
      if (qty <= 0) return;

      final productRef = db.collection('products').doc(productId);
      batch.set(productRef, {
        'stock': FieldValue.increment(qty),
      }, SetOptions(merge: true));
    }

    if (data['items'] is List) {
      final items = data['items'] as List;
      for (final item in items) {
        if (item is! Map) continue;
        final productIdRaw = item['productId'] ?? item['id'];
        final qty = _asInt(item['quantity'], fallback: 1);
        queueRestore(productIdRaw?.toString(), qty);
      }
    } else {
      final productIdRaw = data['productId'] ?? data['id'];
      final qty = _asInt(data['quantity'], fallback: 1);
      queueRestore(productIdRaw?.toString(), qty);
    }

    batch.update(orderRef, {
      'status': 'cancelled',
      'cancelledAt': Timestamp.now(),
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _brandBlue,
        elevation: 0.6,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
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
                    size: 78,
                    color: Colors.grey[350],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'placed';
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final fullName = data['fullName'] ?? '';
              final address = data['address'] ?? '';
              final orderItems = _extractOrderItems(data);

              String productName = '';
              String imageUrl = '';
              int price = 0;
              int quantity = 0;

              if (data['items'] != null) {
                final List items = data['items'];
                productName = items.map((e) => e['name']).join(', ');
                price = _asInt(data['totalAmount']);
                quantity = items.fold(
                  0,
                  (qtyTotal, e) => qtyTotal + ((e['quantity'] ?? 0) as int),
                );
                imageUrl = items.isNotEmpty ? items.first['image'] ?? '' : '';
              } else {
                productName = data['productName'] ?? 'Product';
                price = _asInt(data['price']);
                quantity = (data['quantity'] ?? 1) as int;
                imageUrl = data['imageUrl'] ?? '';
              }

              final isPlaced = status == 'placed';
              final statusColor = isPlaced
                  ? const Color(0xFF388E3C)
                  : const Color(0xFFD32F2F);
              final statusIcon = isPlaced
                  ? Icons.radio_button_checked
                  : Icons.cancel;

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showOrderDetailsDialog(
                  context: context,
                  orderId: doc.id,
                  createdAt: createdAt,
                  status: status.toString(),
                  fullName: fullName.toString(),
                  address: address.toString(),
                  items: orderItems,
                  grandTotal: price,
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE3E7ED)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 84,
                              width: 84,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE6EAF0),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color: Colors.grey,
                                            ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Qty: $quantity',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rs $price',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Order ID: ${doc.id.substring(0, 8).toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFE8ECF1)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              isPlaced
                                  ? 'Delivery expected soon'
                                  : 'Order cancelled',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Deliver to $fullName, $address',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF616161),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            if (isPlaced)
                              OutlinedButton(
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
                                  if (!context.mounted) return;

                                  if (confirm == true) {
                                    try {
                                      await _cancelOrder(orderId: doc.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Order cancelled, stock restored',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } on FirebaseException catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to cancel (${e.code}): ${e.message ?? 'Unknown Firestore error'}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } catch (e, st) {
                                      if (!context.mounted) return;
                                      debugPrint('Cancel error: $e\n$st');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to cancel: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _brandBlue,
                                  side: const BorderSide(
                                    color: Color(0xFFCDD6E3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap to view full order details',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

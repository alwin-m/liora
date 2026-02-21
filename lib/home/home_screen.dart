import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lioraa/home/calendar_screen.dart';
import 'package:lioraa/home/profile_screen.dart';
import 'package:lioraa/shop/shop_screen.dart';

import '../services/cycle_provider.dart';
import '../models/cycle_data.dart';
import '../core/app_theme.dart';
import 'cycle_algorithm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _homeUI(),
      const TrackerScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: LioraTheme.durationMedium,
        switchInCurve: LioraTheme.curveStandard,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: LioraTheme.pureWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_filled, Icons.home_outlined, "Home"),
                _navItem(
                  1,
                  Icons.calendar_month_rounded,
                  Icons.calendar_month_outlined,
                  "Track",
                ),
                _navItem(
                  2,
                  Icons.shopping_bag_rounded,
                  Icons.shopping_bag_outlined,
                  "Shop",
                ),
                _navItem(
                  3,
                  Icons.person_rounded,
                  Icons.person_outline,
                  "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int i,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final active = index == i;
    return GestureDetector(
      onTap: () => setState(() => index = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: LioraTheme.durationStandard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? LioraTheme.blushRose.withAlpha(60)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : inactiveIcon,
              color: active ? LioraTheme.textPrimary : LioraTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active
                    ? LioraTheme.textPrimary
                    : LioraTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HOME UI =================

  Widget _homeUI() {
    final cs = Theme.of(context).colorScheme;

    return Consumer<CycleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        }

        final data = provider.cycleData!;
        final algo = CycleAlgorithm(
          lastPeriod: data.lastPeriodStartDate,
          cycleLength: data.averageCycleLength,
          periodLength: data.averagePeriodDuration,
        );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(LioraTheme.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(cs),
                const SizedBox(height: LioraTheme.space20),
                _calendarCard(algo, cs),
                const SizedBox(height: LioraTheme.space24),
                _nextPeriodCard(data, cs),
                const SizedBox(height: LioraTheme.space24),
                _recommendedTitle(cs),
                const SizedBox(height: LioraTheme.space12),
                _recommendedProducts(cs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _title(ColorScheme cs) {
    return Text(
      "LIORA",
      style: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: LioraTheme.textPrimary,
        letterSpacing: 2,
      ),
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard(CycleAlgorithm algo, ColorScheme cs) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LioraTheme.space12),
        child: TableCalendar(
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          selectedDayPredicate: (d) => isSameDay(d, selectedDay),
          onDaySelected: (s, f) {
            setState(() {
              selectedDay = s;
              focusedDay = f;
            });
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (_, d, __) => _dayBox(d, algo.getType(d), cs),
            todayBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), cs, today: true),
            selectedBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), cs, selected: true),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayBox(
    DateTime day,
    DayType type,
    ColorScheme cs, {
    bool selected = false,
    bool today = false,
  }) {
    Color color = Colors.transparent;
    Color textColor = LioraTheme.textPrimary;

    if (type == DayType.period) {
      color = LioraTheme.roseRedMuted.withAlpha(50);
      textColor = LioraTheme.roseRedMuted;
    }
    if (type == DayType.fertile || type == DayType.ovulation) {
      color = LioraTheme.sageGreen.withAlpha(50);
      textColor = LioraTheme.sageGreen;
    }

    return AnimatedContainer(
      duration: LioraTheme.durationStandard,
      curve: LioraTheme.curveStandard,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selected ? LioraTheme.blushRose : color,
        borderRadius: BorderRadius.circular(10),
        border: today
            ? Border.all(color: LioraTheme.coralSoft, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        "${day.day}",
        style: TextStyle(
          fontSize: 13,
          fontWeight: (selected || today) ? FontWeight.bold : FontWeight.w500,
          color: (selected) ? LioraTheme.textPrimary : textColor,
        ),
      ),
    );
  }

  // ================= NEXT PERIOD =================

  Widget _nextPeriodCard(CycleDataModel data, ColorScheme cs) {
    final nextPeriod = data.computedNextPeriodStart;
    final endPeriod = data.computedNextPeriodEnd;
    final daysLeft = data.daysRemaining;

    return GestureDetector(
      onTap: () => _showNextPeriodSheet(data),
      child: AnimatedContainer(
        duration: LioraTheme.durationSlow,
        curve: LioraTheme.curveStandard,
        padding: const EdgeInsets.all(LioraTheme.space24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LioraTheme.blushRose, LioraTheme.coralSoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(LioraTheme.radiusSheet),
          boxShadow: [
            BoxShadow(
              color: LioraTheme.blushRose.withAlpha(40),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Predicted Cycle",
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: LioraTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: LioraTheme.space8),
                  Text(
                    "${nextPeriod.day} ${_month(nextPeriod.month)} – ${endPeriod.day} ${_month(endPeriod.month)}",
                    style: const TextStyle(
                      color: LioraTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: LioraTheme.space12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: LioraTheme.pureWhite.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daysLeft == 0
                          ? "Starting today"
                          : daysLeft < 0
                          ? "In progress"
                          : "In $daysLeft day${daysLeft == 1 ? '' : 's'}",
                      style: const TextStyle(
                        color: LioraTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: LioraTheme.textPrimary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _showNextPeriodSheet(CycleDataModel data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => _EnhancedNextPeriodSheet(initialData: data),
    );
  }

  // ================= RECOMMENDED =================

  Widget _recommendedTitle(ColorScheme cs) {
    return Text(
      "Recommended for Your Upcoming Period",
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: cs.onSurface.withAlpha(180),
      ),
    );
  }

  Widget _recommendedProducts(ColorScheme cs) {
    return SizedBox(
      height: 170,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('trending', isEqualTo: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products available',
                style: TextStyle(color: cs.onSurface.withAlpha(120)),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (_, i) {
              final productData = products[i].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => _showProductPopup(
                  productId: products[i].id,
                  productData: productData,
                ),
                child: _productCard(productData, cs),
              );
            },
          );
        },
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product, ColorScheme cs) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: LioraTheme.space12),
      padding: const EdgeInsets.all(LioraTheme.space12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(LioraTheme.radiusSmall),
            child: CachedNetworkImage(
              imageUrl:
                  product['image'] ??
                  'https://via.placeholder.com/100x100?text=Product',
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 50,
                width: 50,
                color: cs.surfaceContainerHighest,
                child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 50,
                width: 50,
                color: cs.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: LioraTheme.space8),
          Text(
            product['name'] ?? 'Product',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: LioraTheme.space4),
          Text(
            "₹${product['price'] ?? 0}",
            style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
          ),
        ],
      ),
    );
  }

  /// =====================
  /// PRODUCT POPUP
  /// =====================
  void _showProductPopup({
    required String productId,
    required Map<String, dynamic> productData,
  }) {
    final cs = Theme.of(context).colorScheme;
    final List<String> details = List<String>.from(
      productData['details'] ?? [],
    );
    final String name = productData['name'] ?? 'Product';
    final int price = (productData['price'] ?? 0).toInt();
    final String image =
        productData['image'] ??
        'https://via.placeholder.com/300x200?text=Product';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraTheme.radiusDialog),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: cs.surfaceContainerHighest,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: cs.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: LioraTheme.space20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: LioraTheme.space8),
                    Text(
                      '₹$price',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LioraTheme.space16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About this product',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: LioraTheme.space12),
                    ...details.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(fontSize: 16, color: cs.primary),
                            ),
                            Expanded(
                              child: Text(
                                detail,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurface.withAlpha(160),
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
              const SizedBox(height: LioraTheme.space24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: cs.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              LioraTheme.radiusSmall,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name added to cart')),
                          );
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ),
                    const SizedBox(width: LioraTheme.space12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeliveryPopup(
                            productId: productId,
                            productName: name,
                            price: price,
                          );
                        },
                        child: const Text('Buy Now'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LioraTheme.space24),
            ],
          ),
        ),
      ),
    );
  }

  /// =====================
  /// DELIVERY POPUP
  /// =====================
  void _showDeliveryPopup({
    required String productId,
    required String productName,
    required int price,
  }) {
    final cs = Theme.of(context).colorScheme;
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraTheme.radiusDialog),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: LioraTheme.space24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                child: Column(
                  children: [
                    Text(
                      'Delivery Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: LioraTheme.space8),
                    Text(
                      'Where should we deliver your order?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LioraTheme.space24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: LioraTheme.space16),
                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Delivery Address',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: LioraTheme.space16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LioraTheme.space20),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                padding: const EdgeInsets.all(LioraTheme.space16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(LioraTheme.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: LioraTheme.space8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 20,
                          color: cs.onSurface,
                        ),
                        const SizedBox(width: LioraTheme.space8),
                        Expanded(
                          child: Text(
                            'Pay on Delivery - No advance payment needed',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LioraTheme.space24),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                padding: const EdgeInsets.all(LioraTheme.space16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(LioraTheme.radiusSmall),
                  border: Border.all(color: cs.outlineVariant.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: LioraTheme.space12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(productName),
                        Text(
                          '₹$price',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹$price',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LioraTheme.space24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraTheme.space24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }
                      _confirmOrder(
                        productId: productId,
                        productName: productName,
                        price: price,
                        address: addressController.text,
                      );
                    },
                    child: const Text('Confirm & Pay on Delivery'),
                  ),
                ),
              ),
              const SizedBox(height: LioraTheme.space24),
            ],
          ),
        ),
      ),
    );
  }

  /// =====================
  /// CONFIRM ORDER
  /// =====================
  Future<void> _confirmOrder({
    required String productId,
    required String productName,
    required int price,
    required String address,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      final productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(productId);

      await FirebaseFirestore.instance.runTransaction((txn) async {
        final snap = await txn.get(productRef);
        final stock = (snap['stock'] ?? 0).toInt();

        if (stock <= 0) {
          throw Exception('Out of stock');
        }

        txn.update(productRef, {'stock': stock - 1});

        final orderRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc();

        txn.set(orderRef, {
          'orderId': orderRef.id,
          'productId': productId,
          'productName': productName,
          'price': price,
          'status': 'Order Placed',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      Navigator.pop(context);
      _showOrderSuccess(productName, address);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /// =====================
  /// ORDER SUCCESS
  /// =====================
  void _showOrderSuccess(String productName, String address) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraTheme.radiusDialog),
        ),
        child: Padding(
          padding: const EdgeInsets.all(LioraTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(LioraTheme.space12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(height: LioraTheme.space16),
              Text(
                'Order Confirmed!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: LioraTheme.space12),
              Text(
                '$productName will be delivered to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withAlpha(140),
                ),
              ),
              const SizedBox(height: LioraTheme.space8),
              Container(
                padding: const EdgeInsets.all(LioraTheme.space12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(LioraTheme.radiusSmall),
                ),
                child: Text(
                  address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: LioraTheme.space24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
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
      "Dec",
    ];
    return months[m];
  }
}

// ═══════════════════════════════════════════════════════════════════
// ENHANCED NEXT PERIOD BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _EnhancedNextPeriodSheet extends StatefulWidget {
  final CycleDataModel initialData;
  const _EnhancedNextPeriodSheet({required this.initialData});

  @override
  State<_EnhancedNextPeriodSheet> createState() =>
      _EnhancedNextPeriodSheetState();
}

class _EnhancedNextPeriodSheetState extends State<_EnhancedNextPeriodSheet> {
  bool _isEditing = false;
  bool _isSaving = false;

  late DateTime _editLastPeriodDate;
  late int _editCycleLength;
  late int _editPeriodDuration;

  final _cycleLengthCtrl = TextEditingController();
  final _periodDurationCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _resetEditData();
  }

  void _resetEditData() {
    _editLastPeriodDate = widget.initialData.lastPeriodStartDate;
    _editCycleLength = widget.initialData.averageCycleLength;
    _editPeriodDuration = widget.initialData.averagePeriodDuration;
    _cycleLengthCtrl.text = _editCycleLength.toString();
    _periodDurationCtrl.text = _editPeriodDuration.toString();
  }

  @override
  void dispose() {
    _cycleLengthCtrl.dispose();
    _periodDurationCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
      "Dec",
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<CycleProvider>(context, listen: false);
      await provider.updateCycleData(
        lastPeriodStartDate: _editLastPeriodDate,
        averageCycleLength: int.parse(_cycleLengthCtrl.text),
        averagePeriodDuration: int.parse(_periodDurationCtrl.text),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cycle data updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final panelHeight =
        MediaQuery.of(context).size.height * (_isEditing ? 0.85 : 0.65);
    final data = widget.initialData;

    return AnimatedContainer(
      duration: LioraTheme.durationMedium,
      curve: LioraTheme.curveStandard,
      height: panelHeight,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LioraTheme.radiusSheet),
        ),
      ),
      child: Column(
        children: [
          // Drag Indicator
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LioraTheme.space24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? "Edit Cycle Data" : "Cycle Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: LioraTheme.space24,
                vertical: LioraTheme.space16,
              ),
              child: _isEditing
                  ? _buildEditForm(cs)
                  : _buildDetailsView(data, cs),
            ),
          ),

          // Bottom Action
          Padding(
            padding: EdgeInsets.fromLTRB(
              LioraTheme.space24,
              LioraTheme.space8,
              LioraTheme.space24,
              MediaQuery.of(context).padding.bottom + LioraTheme.space16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isEditing
                    ? _handleSave
                    : () => setState(() => _isEditing = true),
                child: _isSaving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.onPrimary,
                        ),
                      )
                    : Text(_isEditing ? "Save & Recalculate" : "Edit Details"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(CycleDataModel data, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Prediction Summary", cs),
        const SizedBox(height: LioraTheme.space16),
        _buildSummaryGrid(data, cs),
        const SizedBox(height: LioraTheme.space32),

        _buildSectionHeader("Visual Timeline", cs),
        const SizedBox(height: LioraTheme.space16),
        CycleTimeline(data: data),
        const SizedBox(height: LioraTheme.space32),

        _buildSectionHeader("Cycle Insights", cs),
        const SizedBox(height: LioraTheme.space16),
        _buildInsightsList(data, cs),
        const SizedBox(height: LioraTheme.space16),
      ],
    );
  }

  Widget _buildEditForm(ColorScheme cs) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Update your cycle information to keep predictions accurate.",
            style: TextStyle(color: cs.onSurface.withAlpha(140), fontSize: 14),
          ),
          const SizedBox(height: LioraTheme.space24),

          _buildFieldLabel("Last Period Start Date", cs),
          const SizedBox(height: LioraTheme.space8),
          InkWell(
            borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
            onTap: _showDatePickerDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LioraTheme.space16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                  const SizedBox(width: LioraTheme.space12),
                  Text(
                    _formatDate(_editLastPeriodDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: LioraTheme.space20),

          _buildFieldLabel("Average Cycle Length (Days)", cs),
          const SizedBox(height: LioraTheme.space8),
          TextFormField(
            controller: _cycleLengthCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "e.g. 28"),
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              final n = int.tryParse(val);
              if (n == null || n < 21 || n > 40) return "Range: 21-40 days";
              return null;
            },
          ),
          const SizedBox(height: LioraTheme.space20),

          _buildFieldLabel("Average Period Duration (Days)", cs),
          const SizedBox(height: LioraTheme.space8),
          TextFormField(
            controller: _periodDurationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "e.g. 5"),
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              final n = int.tryParse(val);
              if (n == null || n < 2 || n > 10) return "Range: 2-10 days";
              return null;
            },
          ),

          const SizedBox(height: LioraTheme.space32),
          TextButton(
            onPressed: () => setState(() {
              _isEditing = false;
              _resetEditData();
            }),
            child: Center(
              child: Text("Cancel Changes", style: TextStyle(color: cs.error)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePickerDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editLastPeriodDate,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _editLastPeriodDate = picked);
    }
  }

  Widget _buildFieldLabel(String label, ColorScheme cs) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: cs.onSurface,
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: cs.onSurface.withAlpha(120),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSummaryGrid(CycleDataModel data, ColorScheme cs) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildSummaryCard(
          "Next Start",
          _formatDate(data.computedNextPeriodStart),
          Icons.calendar_month_rounded,
          cs.primary,
          cs,
        ),
        _buildSummaryCard(
          "Expected End",
          _formatDate(data.computedNextPeriodEnd),
          Icons.event_rounded,
          cs.secondary,
          cs,
        ),
        _buildSummaryCard(
          "Total Duration",
          "${data.averagePeriodDuration} Days",
          Icons.timer_rounded,
          cs.tertiary,
          cs,
        ),
        _buildSummaryCard(
          "Days Away",
          data.daysRemaining <= 0
              ? (data.daysRemaining == 0 ? "Today" : "In Progress")
              : "${data.daysRemaining} Days",
          Icons.hourglass_empty_rounded,
          Colors.teal,
          cs,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.all(LioraTheme.space16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList(CycleDataModel data, ColorScheme cs) {
    return Column(
      children: [
        _buildInsightRow(
          "Average Cycle",
          "${data.averageCycleLength} days",
          Icons.loop_rounded,
          cs,
        ),
        _buildInsightRow(
          "Average Period",
          "${data.averagePeriodDuration} days",
          Icons.water_drop_rounded,
          cs,
        ),
        _buildInsightRow(
          "Last Recorded",
          _formatDate(data.lastPeriodStartDate),
          Icons.history_rounded,
          cs,
        ),
        _buildInsightRow(
          "Regularity",
          data.regularity,
          Icons.verified_rounded,
          cs,
        ),
      ],
    );
  }

  Widget _buildInsightRow(
    String label,
    String value,
    IconData icon,
    ColorScheme cs,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LioraTheme.space12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(LioraTheme.space8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(120),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: LioraTheme.space16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cs.onSurface.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// VISUAL TIMELINE WIDGET
// ═══════════════════════════════════════════════════════════════════

class CycleTimeline extends StatelessWidget {
  final CycleDataModel data;
  const CycleTimeline({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final start = data.lastPeriodStartDate;
    final end = data.computedNextPeriodStart;
    final today = DateTime.now();

    final totalDays = end.difference(start).inDays;
    final passedDays = today.difference(start).inDays;

    final progress = (passedDays / (totalDays == 0 ? 1 : totalDays)).clamp(
      0.0,
      1.0,
    );

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background Track
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Progress Fill
                AnimatedContainer(
                  duration: LioraTheme.durationSlow,
                  curve: LioraTheme.curveStandard,
                  height: 10,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Markers
                _buildMarker(0, "Last Period", cs.primary, cs),
                _buildMarker(
                  progress * constraints.maxWidth,
                  "Today",
                  Colors.white,
                  cs,
                  isToday: true,
                ),
                _buildMarker(
                  constraints.maxWidth,
                  "Next Period",
                  cs.secondary,
                  cs,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: LioraTheme.space32),
      ],
    );
  }

  Widget _buildMarker(
    double offset,
    String label,
    Color color,
    ColorScheme cs, {
    bool isToday = false,
  }) {
    return Positioned(
      left: offset - (isToday ? 10 : 8),
      top: 0,
      child: Column(
        children: [
          Container(
            width: isToday ? 20 : 16,
            height: isToday ? 20 : 16,
            decoration: BoxDecoration(
              color: isToday ? cs.primary : color,
              shape: BoxShape.circle,
              border: Border.all(color: cs.surface, width: 3),
              boxShadow: [
                BoxShadow(color: cs.shadow.withAlpha(25), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

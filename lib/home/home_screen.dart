/*
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'cycle_algorithm.dart';
import 'calendar_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import '../core/cycle_session.dart'; // ✅ shared engine

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // no params anymore

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  late final CycleAlgorithm algo;

  @override
  void initState() {
    super.initState();

    // ✅ SINGLE SOURCE OF TRUTH (with safety)
    algo = CycleSession.algorithm;
    if (algo.cycleLength == 0) {
      algo = CycleAlgorithm(
        lastPeriod: DateTime.now(),
        cycleLength: 28,
        periodLength: 5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeUI(),
      const TrackerScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Track"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _homeUI() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LIORA",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                    defaultBuilder: (c, d, _) =>
                        _dayBox(d, algo.getType(d)),
                    todayBuilder: (c, d, _) =>
                        _dayBox(d, algo.getType(d), today: true),
                    selectedBuilder: (c, d, _) =>
                        _dayBox(d, algo.getType(d), selected: true),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade300,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _nextPeriodCard(),

            const SizedBox(height: 24),

            Text(
              "Recommended for Your Upcoming Period",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            _products(),
          ],
        ),
      ),
    );
  }

  Widget _dayBox(
    DateTime day,
    DayType type, {
    bool selected = false,
    bool today = false,
  }) {
    Color color = Colors.transparent;

    if (type == DayType.period) color = const Color(0xFFFFE0E6);
    if (type == DayType.fertile) color = const Color(0xFFDFF6DD);
    if (type == DayType.ovulation) color = const Color(0xFFE8E0F8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: Colors.pinkAccent, width: 2)
            : today
                ? Border.all(color: Colors.deepOrangeAccent, width: 2)
                : null,
        boxShadow: selected
            ? [BoxShadow(color: Colors.pink.shade100, blurRadius: 6)]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        "${day.day}",
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _nextPeriodCard() {
    final nextPeriod = algo.getNextPeriodDate();
    final endPeriod =
        nextPeriod.add(Duration(days: algo.periodLength - 1));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade200, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.pink.shade100, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Next Period",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${nextPeriod.day} ${_month(nextPeriod.month)} - ${endPeriod.day} ${_month(endPeriod.month)}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }

  Widget _products() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _Item("Sanitary Pads", "₹199", Icons.favorite),
          _Item("Heat Pack", "₹299", Icons.local_fire_department),
          _Item("Pain Relief", "₹99", Icons.healing),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String name, price;
  final IconData icon;

  const _Item(this.name, this.price, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 36),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lioraa/home/calendar_screen.dart';
import 'package:lioraa/home/profile_screen.dart';
import 'package:lioraa/shop/shop_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/cycle_session.dart';
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
    final pages = [
      _homeUI(),
      const TrackerScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
            if (i == 0) {
              focusedDay = DateTime.now();
              selectedDay = DateTime.now();
            }
          });
        },
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Track",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Shop",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ================= HOME UI =================

  Widget _homeUI() {
    return ValueListenableBuilder<CycleAlgorithm>(
      valueListenable: CycleSession.algorithmNotifier,
      builder: (context, algo, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(),
                const SizedBox(height: 20),
                _calendarCard(algo),
                const SizedBox(height: 24),
                _nextPeriodCard(algo),
                const SizedBox(height: 24),
                _recommendedTitle(),
                const SizedBox(height: 12),
                _recommendedProducts(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _title() {
    return Text(
      "LIORA",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.pink.shade400,
        letterSpacing: 1.2,
      ),
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard(CycleAlgorithm algo) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            defaultBuilder: (_, d, __) => _dayBox(d, algo.getType(d)),
            todayBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), today: true),
            selectedBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), selected: true),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayBox(
    DateTime day,
    DayType type, {
    bool selected = false,
    bool today = false,
  }) {
    Color color = Colors.transparent;

    if (type == DayType.period) color = const Color(0xFFFFE0E6);
    if (type == DayType.fertile) color = const Color(0xFFDFF6DD);
    if (type == DayType.ovulation) color = const Color(0xFFE8E0F8);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: Colors.pinkAccent, width: 2)
            : today
            ? Border.all(color: Colors.deepOrangeAccent, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        "${day.day}",
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ================= NEXT PERIOD =================

  Widget _nextPeriodCard(CycleAlgorithm algo) {
    final nextPeriod = algo.getNextPeriodDate();
    final endPeriod = nextPeriod.add(Duration(days: algo.periodLength - 1));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade200, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Next Period",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${nextPeriod.day} ${_month(nextPeriod.month)} - "
            "${endPeriod.day} ${_month(endPeriod.month)}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ================= RECOMMENDED =================

  Widget _recommendedTitle() {
    return Text(
      "Recommended for Your Upcoming Period",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _recommendedProducts() {
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
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products available',
                style: TextStyle(color: Colors.grey),
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
                child: _productCard(productData),
              );
            },
          );
        },
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['image'] ??
                  'https://via.placeholder.com/100x100?text=Product',
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 50,
                width: 50,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product['name'] ?? 'Product',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "₹${product['price'] ?? 0}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// =====================
  /// PRODUCT POPUP (FROM SHOP)
  /// =====================
  void _showProductPopup({
    required String productId,
    required Map<String, dynamic> productData,
  }) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...details.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                detail,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name added to cart'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
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
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// =====================
  /// DELIVERY POPUP (FROM SHOP)
  /// =====================
  void _showDeliveryPopup({
    required String productId,
    required String productName,
    required int price,
  }) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Where should we deliver your order?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: addressController,
                      label: 'Delivery Address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 20,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pay on Delivery - No advance payment needed',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                            backgroundColor: Colors.redAccent,
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
                    child: const Text(
                      'Confirm & Pay on Delivery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Confirmed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                '$productName will be delivered to:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
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

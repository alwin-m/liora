import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../models/product_model.dart';
import '../services/cart_provider.dart';
import 'calendar_screen.dart';
import '../shop/shop_screen.dart';
import '../shop/show_product.dart';
import '../shop/order_helper.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  int index = 0;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  CycleAlgorithm get algo => CycleSession.algorithm;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeUI(),
      const CalendarScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (index != 0) {
          setState(() {
            index = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF6F9),
        body: pages[index],
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _bottomNav() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_rounded, 0),
          _navItem(Icons.calendar_month_rounded, 1),
          _navItem(Icons.shopping_bag_rounded, 2),
          _navItem(Icons.person_rounded, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int i) {
    final selected = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? const Color(0xFFE67598) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 26,
          color: selected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  // ================= HOME UI =================

  Widget _homeUI() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "LIORA",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFFE67598)),
                ),
                _circularIcon(Icons.notifications_none_rounded),
              ],
            ),
            const SizedBox(height: 48),
            _calendarCard(),
            const SizedBox(height: 40),
            _minimalNextPeriodCard(),
            const SizedBox(height: 48),
            const Text(
              "CURATED FOR YOU", 
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2)
            ),
            const SizedBox(height: 24),
            _recommendedProducts(),
          ],
        ),
      ),
    );
  }

  Widget _circularIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: Icon(icon, color: Colors.grey[400], size: 20),
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 40, offset: const Offset(0, 15))
        ],
      ),
      padding: const EdgeInsets.all(24),
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
          _showDayPopup(s);
        },
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D1B4D)),
          leftChevronIcon: Icon(Icons.chevron_left_rounded, size: 22, color: Colors.grey),
          rightChevronIcon: Icon(Icons.chevron_right_rounded, size: 22, color: Colors.grey),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (_, d, __) => _dayBox(d, algo.getType(d)),
          todayBuilder: (_, d, __) => _dayBox(d, algo.getType(d), today: true),
          selectedBuilder: (_, d, __) => _dayBox(d, algo.getType(d), selected: true),
        ),
      ),
    );
  }

  Widget _dayBox(DateTime day, DayType type,
      {bool selected = false, bool today = false}) {

    Color? dotColor;
    if (type == DayType.period) dotColor = const Color(0xFFE57373);
    else if (type == DayType.fertile) dotColor = const Color(0xFF81C784);
    else if (type == DayType.ovulation) dotColor = const Color(0xFFB388FF);

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? (dotColor?.withOpacity(0.1) ?? Colors.grey[100]) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (dotColor != null)
             Container(
               width: 30,
               height: 30,
               decoration: BoxDecoration(
                 color: dotColor.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
             ),
          
          Text(
            "${day.day}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: (selected || today) ? FontWeight.w900 : FontWeight.w500,
              color: selected ? (dotColor ?? const Color(0xFF2D1B4D)) : (dotColor ?? Colors.grey[600]),
            ),
          ),

          if (today && !selected)
            Positioned(
              bottom: 4,
              child: Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFFE67598), shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  // ================= MINIMAL NEXT PERIOD CARD =================

  Widget _minimalNextPeriodCard() {
    final nextStart = algo.getNextPeriodDate();
    final daysIn = nextStart.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4D),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2D1B4D).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI FORECAST",
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            "Period starts in $daysIn days",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
             "${nextStart.day} ${_getMonth(nextStart.month)}",
             style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getMonth(int m) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[m - 1];
  }

  // ================= PRODUCTS =================

  Widget _recommendedProducts() {
    return SizedBox(
      height: 180,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('trending', isEqualTo: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final productDoc = products[i];
              final product = Product.fromMap(
                productDoc.id,
                productDoc.data() as Map<String, dynamic>,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: product,
                        onAddToCart: _addToCartFromHome,
                        onBuyNow: (p) => OrderHelper.showDeliverySheet(
                          context,
                          p,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rs ${product.price}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE67598),
                        ),
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

  // ================= POPUP =================

  void _showDayPopup(DateTime date) {
    final type = algo.getType(date);

    String title;
    String desc;
    Color accent;
    IconData icon;

    switch (type) {
      case DayType.period:
        title = "Flow Phase";
        desc = "Your body is resetting. Gentle movement and warmth are your friends today.";
        accent = const Color(0xFFE57373);
        icon = Icons.water_drop_rounded;
        break;
      case DayType.fertile:
        title = "Rising Energy";
        desc = "Your hormones are climbing. A great time for creativity and social connection.";
        accent = const Color(0xFF81C784);
        icon = Icons.wb_sunny_rounded;
        break;
      case DayType.ovulation:
        title = "Peak Vitality";
        desc = "You're at your peak! Strength and confidence are naturally high today.";
        accent = const Color(0xFFB388FF);
        icon = Icons.auto_awesome;
        break;
      default:
        title = "Steady Slate";
        desc = "Balanced hormones. A perfect day for consistent habits and focus.";
        accent = Colors.grey;
        icon = Icons.self_improvement_rounded;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: accent, size: 32),
                ),
                const SizedBox(height: 24),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: accent)),
                const SizedBox(height: 12),
                Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 14)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFF2D1B4D), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Got it", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToCartFromHome(Product product) {
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
      stock: product.stock,
      icon: Icons.shopping_bag_rounded,
      image: product.imageUrl,
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF2D1B4D),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

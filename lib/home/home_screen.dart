import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../core/app_theme.dart';
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
          setState(() => index = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: pages[index],
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _bottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isDark ? LioraColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: LioraColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
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
          color: selected ? LioraColors.primary : Colors.transparent,
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: LioraColors.primary,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "LIORA: KITTEN",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: LioraColors.primaryDark,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _calendarCard(),
            const SizedBox(height: 20),
            _nextPeriodCard(),
            const SizedBox(height: 20),
            _recommendedProducts(),
          ],
        ),
      ),
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
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
            _showDayPopup(s);
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d)),
            todayBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), today: true),
            selectedBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), selected: true),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
        ),
      ),
    );
  }

  Widget _dayBox(DateTime day, DayType type,
      {bool selected = false, bool today = false}) {

    if (selected) {
      return Container(
        margin: const EdgeInsets.all(4),
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: LioraColors.primary,
        ),
        alignment: Alignment.center,
        child: Text("${day.day}",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      );
    }

    if (today) {
      return Container(
        margin: const EdgeInsets.all(4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: LioraColors.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text("${day.day}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    if (type == DayType.period) {
      return _glowCircle(day, LioraColors.periodRed, LioraColors.periodRedBg);
    }

    if (type == DayType.fertile) {
      return _glowCircle(day, LioraColors.fertileGreen, LioraColors.fertileGreenBg);
    }

    if (type == DayType.ovulation) {
      return _glowCircle(day, LioraColors.ovulationPurple, LioraColors.ovulationPurpleBg);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Text("${day.day}"),
    );
  }

  Widget _glowCircle(DateTime day, Color glowColor, Color bgColor) {
    final glow = 6 + (_glowController.value * 14);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: glow,
              spreadRadius: 1)
        ],
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
        alignment: Alignment.center,
        child: Text("${day.day}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ================= POPUP =================

  void _showDayPopup(DateTime date) {
    final type = algo.getType(date);

    String title;
    String desc;
    Color accent;

    switch (type) {
      case DayType.period:
        title = "Period Day";
        desc = "Your menstrual phase. Take rest & hydrate well.";
        accent = LioraColors.periodRed;
        break;
      case DayType.fertile:
        title = "Fertile Window";
        desc = "Higher chance of pregnancy during this phase.";
        accent = LioraColors.fertileGreen;
        break;
      case DayType.ovulation:
        title = "Ovulation Day";
        desc = "Peak fertility day. Highest pregnancy chance.";
        accent = LioraColors.ovulationPurple;
        break;
      default:
        title = "Normal Day";
        desc = "Regular cycle phase.";
        accent = Colors.grey;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: accent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: accent),
                  const SizedBox(height: 10),
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: accent)),
                  const SizedBox(height: 8),
                  Text(desc, textAlign: TextAlign.center),
                  const SizedBox(height: 15),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close",
                          style: TextStyle(color: accent)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= NEXT PERIOD CARD =================

  Widget _nextPeriodCard() {
    final nextStart = algo.getNextPeriodDate();
    final nextEnd = nextStart.add(const Duration(days: 4));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            LioraColors.primary.withOpacity(0.15),
            LioraColors.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: LioraColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: 16, color: LioraColors.primary),
              const SizedBox(width: 6),
              Text(
                "YOUR NEXT PERIOD",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LioraColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${nextStart.day}/${nextStart.month} — ${nextEnd.day}/${nextEnd.month}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCTS =================

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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
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
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardTheme.color,
                    boxShadow: [
                      BoxShadow(
                        color: LioraColors.primary.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rs ${product.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: LioraColors.primary,
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

  void _addToCartFromHome(Product product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Out of stock')));
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
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

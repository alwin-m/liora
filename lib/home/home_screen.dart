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
import '../Screens/cycle_ai_insights_panel.dart';
import '../models/ml_cycle_data.dart';

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
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
          child: pages[index],
        ),
        extendBody: true,
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _bottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.home_rounded, "Home", 0),
              _navItem(Icons.calendar_month_rounded, "Cycle", 1),
              _navItem(Icons.shopping_bag_rounded, "Shop", 2),
              _navItem(Icons.person_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i) {
    final selected = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: selected ? const Color(0xFFE67598).withOpacity(0.12) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? const Color(0xFFE67598) : Colors.grey.shade400,
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE67598),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ================= UTILS =================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    // We can't rely on algo.getPhase directly if it's not defined, but let's check
    String timeStr = "Good morning";
    if (hour >= 12 && hour < 17) timeStr = "Good afternoon";
    if (hour >= 17) timeStr = "Good evening";

    return timeStr;
  }

  Widget _ikigaiReasonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE67598).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE67598).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE67598), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "The Purpose of Liora",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE67598)),
                ),
                Text(
                  "We track your cycle to personalize your nutrition, helping you live in sync with your rhythm.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HOME UI =================

  Widget _homeUI() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      "LIORA",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFFE67598)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Color(0xFFE67598)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ikigaiReasonCard(),
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
          color: Color(0xFFE67598),
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
          border: Border.all(
              color: const Color(0xFFE67598), width: 2),
        ),
        alignment: Alignment.center,
        child: Text("${day.day}",
            style: const TextStyle(
                fontWeight: FontWeight.bold)),
      );
    }

    if (type == DayType.period) {
      return _glowCircle(
        day,
        const Color(0xFFE57373),
        const Color(0xFFFFE0E6),
      );
    }

    if (type == DayType.fertile) {
      return _glowCircle(
        day,
        const Color(0xFF81C784),
        const Color(0xFFDFF6DD),
      );
    }

    if (type == DayType.ovulation) {
      return _glowCircle(
        day,
        const Color(0xFFB388FF),
        const Color(0xFFE8E0F8),
      );
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Text("${day.day}"),
    );
  }

  Widget _glowCircle(
      DateTime day, Color glowColor, Color bgColor) {

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
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: bgColor),
        alignment: Alignment.center,
        child: Text("${day.day}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ================= POPUP =================

  void _showDayPopup(DateTime date) {
    // Generate AI Prediction and Phase Info for the selected date
    final type = algo.getType(date);
    CyclePhase phase;
    switch (type) {
      case DayType.period:
        phase = CyclePhase.menstrual;
        break;
      case DayType.fertile:
        phase = CyclePhase.follicular;
        break;
      case DayType.ovulation:
        phase = CyclePhase.ovulation;
        break;
      default:
        phase = CyclePhase.luteal;
    }

    // Get day in phase (simplified logic for demonstration)
    int dayInPhase = 1; 
    // If it's a period day, try to find the actual flow day
    if (type == DayType.period) {
      final records = CycleSession.history;
      if (records.isNotEmpty) {
        final last = records.first; // sorted by date descending
        dayInPhase = date.difference(last.startDate).inDays + 1;
        if (dayInPhase < 1) dayInPhase = 1;
        if (dayInPhase > 7) dayInPhase = 7;
      }
    }

    final phaseInfo = CyclePhaseInfo(
      phase: phase,
      dayInPhase: dayInPhase,
      confidenceScore: 0.94,
      estimatedStartDate: date.subtract(Duration(days: dayInPhase - 1)),
      estimatedEndDate: date.add(const Duration(days: 4)),
      hormonalExplanation: _getHormonalExplanation(phase),
      bodyChangesExplanation: _getBodyChangesExplanation(phase),
      expectedSymptoms: _getExpectedSymptoms(phase),
      recommendedFoods: [], // Legacy field
      foodsToAvoid: [], // Legacy field
    );

    final prediction = MLCyclePrediction(
      nextPeriodDate: algo.getNextPeriodDate(),
      confidenceScore: 0.94,
      phaseInfo: phaseInfo,
      insightSummary: _getInsightSummary(phase),
      personalizedRecommendations: _getRecommendations(phase),
      influencingFactors: ["Historical Cycle Records", "User Bio-data", "Phase Intensity"],
      predictionTimestamp: DateTime.now(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CycleAIInsightsPanel(
        selectedDate: date,
        prediction: prediction,
        phaseInfo: phaseInfo,
        isToday: isSameDay(date, DateTime.now()),
      ),
    );
  }

  // Helper methods for quick data generation
  String _getHormonalExplanation(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Estrogen and progesterone are at their lowest, causing the uterine lining to shed.";
      case CyclePhase.follicular: return "Estrogen begins to rise, stimulating follicle development in the ovaries.";
      case CyclePhase.ovulation: return "Luteinizing hormone (LH) peaks, triggering the release of an egg.";
      case CyclePhase.luteal: return "Progesterone peaks to prepare for potential pregnancy, affecting mood and appetite.";
    }
  }

  String _getBodyChangesExplanation(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Bloating and pelvic discomfort are common. Core body temperature is lower.";
      case CyclePhase.follicular: return "Energy levels increase. Skin often looks clearer and more radiant.";
      case CyclePhase.ovulation: return "Cervical mucus becomes clear and slippery. You may feel a slight pain on one side.";
      case CyclePhase.luteal: return "Breast tenderness and water retention may occur. Basal temperature remains high.";
    }
  }

  List<String> _getExpectedSymptoms(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return ["Cramps", "Fatigue", "Lower Back Pain"];
      case CyclePhase.follicular: return ["Higher Energy", "Clear Skin"];
      case CyclePhase.ovulation: return ["Mild Cramping", "Increased Libido"];
      case CyclePhase.luteal: return ["Mood Swings", "Bloating", "Cravings"];
    }
  }

  String _getInsightSummary(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Your body is in renewal mode. Prioritize rest and nutritional recovery today.";
      case CyclePhase.follicular: return "You are entering your most energetic phase. Great time for social activities.";
      case CyclePhase.ovulation: return "Hormonal peak reached. You are likely feeling more confident and alert.";
      case CyclePhase.luteal: return "Calm down and stabilize. Focus on maintaining steady blood sugar levels.";
    }
  }

  List<String> _getRecommendations(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return ["Avoid heavy exercise", "Hydrate with warm ginger tea"];
      case CyclePhase.follicular: return ["Start new fitness goals", "Plan collaborative work"];
      case CyclePhase.ovulation: return ["High-intensity workouts", "Important meetings"];
      case CyclePhase.luteal: return ["Yoga and stretching", "Magnesium-rich foods"];
    }
  }

  // ================= NEXT PERIOD CARD =================

  Widget _nextPeriodCard() {
    final nextStart = algo.getNextPeriodDate();
    final nextEnd =
        nextStart.add(const Duration(days: 4));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xFFFFE3EC),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text("YOUR NEXT PERIOD"),
          const SizedBox(height: 6),
          Text(
              "${nextStart.day}/${nextStart.month} - ${nextEnd.day}/${nextEnd.month}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
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
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }
}


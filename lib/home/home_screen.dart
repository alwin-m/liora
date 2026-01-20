import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cycle_algorithm.dart';
import 'calendar_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import 'first_time_setup.dart';
import '../services/cycle_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  bool setupCompleted = false;
  bool isCheckingSetup = true;
  String userName = 'User';
  
  late CycleDataService cycleService;

  @override
  void initState() {
    super.initState();
    cycleService = CycleDataService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load cycle data
      await cycleService.loadUserCycleData();
      
      // Load user name
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            setupCompleted = cycleService.isDataLoaded;
            userName = docSnapshot.data()?['name'] ?? 'User';
            isCheckingSetup = false;
          });

          // Show setup pop-up if first time
          if (!setupCompleted && mounted) {
            _showFirstTimeSetup();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isCheckingSetup = false);
      }
    }
  }

  void _showFirstTimeSetup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FirstTimeSetup(
        onComplete: () {
          // Reload data after setup
          cycleService.loadUserCycleData();
          setState(() => setupCompleted = true);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditSetup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FirstTimeSetup(
        onComplete: () {
          // Reload data after edit
          cycleService.loadUserCycleData();
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingSetup) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

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
    final today = DateTime.now();
    final formattedDate =
        '${today.day} ${_monthName(today.month)}, ${today.year}';
    final nextPeriodRange = cycleService.getNextPeriodDateRange();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("LIORA",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade400,
                            letterSpacing: 1.2)),
                    if (setupCompleted)
                      TextButton.icon(
                        onPressed: _showEditSetup,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.pink.shade400,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Hey, $userName! 👋",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(formattedDate,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 24),

            // Calendar
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TableCalendar(
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030),
                  selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                  onDaySelected: (s, f) =>
                      setState(() {selectedDay = s; focusedDay = f;}),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (c, d, _) =>
                        _dayBox(d, cycleService.getDayType(d)),
                    todayBuilder: (c, d, _) =>
                        _dayBox(d, cycleService.getDayType(d), today: true),
                    selectedBuilder: (c, d, _) =>
                        _dayBox(d, cycleService.getDayType(d), selected: true),
                  ),
                  headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade300)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _nextPeriodCard(nextPeriodRange),

            const SizedBox(height: 24),

            Text("Recommended for Your Upcoming Period",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade700)),

            const SizedBox(height: 12),

            _products(),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _dayBox(DateTime day, DayType type,
      {bool selected = false, bool today = false}) {
    Color color = Colors.transparent;
    if (type == DayType.period) color = const Color(0xFFFFE0E6); // soft pink
    if (type == DayType.fertile) color = const Color(0xFFDFF6DD); // mint green
    if (type == DayType.ovulation) color = const Color(0xFFE8E0F8); // lavender

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
      child: Text("${day.day}",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _nextPeriodCard(DateRange? nextPeriodRange) {
    final periodText = nextPeriodRange?.formattedString ?? 'Loading...';
    
    return GestureDetector(
      onTap: setupCompleted ? () => setState(() => index = 1) : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade100]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Next Period",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(periodText,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _products() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Item("Sanitary Pads", "₹199", Icons.favorite, () {
            setState(() => index = 2);
          }),
          _Item("Heat Pack", "₹299", Icons.local_fire_department, () {
            setState(() => index = 2);
          }),
          _Item("Pain Relief", "₹99", Icons.healing, () {
            setState(() => index = 2);
          }),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String name, price;
  final IconData icon;
  final VoidCallback? onTap;
  
  const _Item(this.name, this.price, this.icon, [this.onTap]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: Colors.pinkAccent, size: 36),
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(price,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                  color: Colors.pink.shade400)),
          ],
        ),
      ),
    );
  }
}
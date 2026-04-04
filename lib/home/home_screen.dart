import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../widgets/blood_flow_widget.dart';
import 'calendar_screen.dart';
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
          _navItem(Icons.person_rounded, 2),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LIORA",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE67598)),
            ),
            const SizedBox(height: 20),
            _calendarCard(),
            const SizedBox(height: 20),
            _nextPeriodCard(),
            const SizedBox(height: 20),
            _bloodFlowCard(),
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
    final type = algo.getType(date);

    String title;
    String desc;
    Color accent;

    switch (type) {
      case DayType.period:
        title = "Period Day";
        desc = "Your menstrual phase. Take rest & hydrate well.";
        accent = const Color(0xFFE57373);
        break;
      case DayType.fertile:
        title = "Fertile Window";
        desc = "Higher chance of pregnancy during this phase.";
        accent = const Color(0xFF81C784);
        break;
      case DayType.ovulation:
        title = "Ovulation Day";
        desc = "Peak fertility day. Highest pregnancy chance.";
        accent = const Color(0xFFB388FF);
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
                          fontWeight: FontWeight.bold,
                          color: accent)),
                  const SizedBox(height: 8),
                  Text(desc, textAlign: TextAlign.center),
                  const SizedBox(height: 15),
                  TextButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child:
                          Text("Close", style: TextStyle(color: accent)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= BLOOD FLOW CARD =================

  Widget _bloodFlowCard() {
    final algorithm = CycleSession.algorithm;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Only show "in-period" state when actually in the period phase.
    // Fertile and ovulation days get the same treatment as normal days
    // (per design spec: no special ovulation/fertile styling — just show
    // the upcoming period flow forecast on those days too).
    final todayType = algorithm.getType(today);
    final bool isCurrentPeriod = (todayType == DayType.period);

    int todayPeriodDay = 0;
    DateTime periodStart;

    if (isCurrentPeriod) {
      final cycleDay = algorithm.getCycleDay(today);
      todayPeriodDay = cycleDay; // cycle day 1..N == period day 1..N
      periodStart = today.subtract(Duration(days: cycleDay - 1));
    } else {
      // Normal / fertile / ovulation → show upcoming period forecast
      periodStart = algorithm.getNextPeriodDate();
      todayPeriodDay = 0;
    }

    return BloodFlowWidget(
      periodLength: algorithm.adjustedPeriodLength,
      flowIntensity: algorithm.profile.flowIntensity,
      periodStartDate: periodStart,
      todayPeriodDay: todayPeriodDay,
      isCurrentPeriod: isCurrentPeriod,
    );
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
}


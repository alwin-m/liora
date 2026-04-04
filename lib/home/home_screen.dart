import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../widgets/blood_flow_widget.dart';
import '../widgets/day_log_sheet.dart';
import '../widgets/period_confirm_sheet.dart';
import '../widgets/vial_painter.dart';
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
        floatingActionButton: index == 0 ? _fab() : null,
      ),
    );
  }

  // ================= FAB =================

  Widget _fab() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickLogSheet(context),
      backgroundColor: const Color(0xFFE67598),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        "LOG DAY",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _showQuickLogSheet(BuildContext ctx) {
    final today = DateTime.now();
    final type = CycleSession.isAnnieTrained 
        ? (CycleSession.annie.getNextPeriodDate().day == today.day && CycleSession.annie.getNextPeriodDate().month == today.month ? DayType.period : algo.getType(today))
        : algo.getType(today);

    // If today is a predicted period start but not confirmed, show confirm sheet
    final nextPredicted = CycleSession.isAnnieTrained 
        ? CycleSession.annie.getNextPeriodDate() 
        : algo.getNextPeriodDate();
    
    final bool isNearPredicted = today.difference(nextPredicted).inDays.abs() <= 2;

    if (type == DayType.period || (isNearPredicted && CycleSession.activeCycleLog == null)) {
      if (CycleSession.activeCycleLog == null) {
        showModalBottomSheet(
          context: ctx,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PeriodConfirmSheet(
            predictedDate: nextPredicted,
            onConfirm: (actual) async {
              await CycleSession.confirmPeriodStart(actual);
              setState(() {});
            },
          ),
        );
      } else {
        final active = CycleSession.activeCycleLog!;
        final dayNum = today.difference(active.actualStart!).inDays + 1;
        final existing = CycleSession.getDayLog(dayNum);

        showModalBottomSheet(
          context: ctx,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DayLogSheet(
            dayNumber: dayNum,
            totalDays: algo.adjustedPeriodLength,
            date: today,
            initialFlow: existing?.flowPercent ?? 50,
            initialPain: existing?.painLevel ?? 0,
            onSave: (flow, pain) async {
              await CycleSession.logDay(
                dayNumber: dayNum,
                date: today,
                flowPercent: flow,
                painLevel: pain,
              );
              setState(() {});
            },
          ),
        );
      }
    } else {
      // Normal day but user wants to log period start manually
      showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PeriodConfirmSheet(
          predictedDate: nextPredicted,
          onConfirm: (actual) async {
            await CycleSession.confirmPeriodStart(actual);
            setState(() {});
          },
        ),
      );
    }
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
    final bool isPeriod = type == DayType.period;

    String title;
    String desc;
    Color accent;
    String phaseLabel = "HEALTH INSIGHT";

    switch (type) {
      case DayType.period:
        title = "Menstrual Phase";
        desc = "Your body is in renewal. Focus on iron-rich foods, gentle movement, and rest.";
        accent = const Color(0xFFE57373);
        phaseLabel = "PERIOD · ACTIVE";
        break;
      case DayType.fertile:
        title = "Fertile Window";
        desc = "Estrogen levels are rising. You may feel more energetic and social today.";
        accent = const Color(0xFF81C784);
        phaseLabel = "FERTILE · HIGH";
        break;
      case DayType.ovulation:
        title = "Ovulation Day";
        desc = "Peak fertility. Your body is at its most fertile state of the cycle.";
        accent = const Color(0xFFB388FF);
        phaseLabel = "OVULATION · PEAK";
        break;
      default:
        title = "Follicular Phase";
        desc = "Regular cycle activity. A great time for new projects and gym sessions.";
        accent = Colors.grey.shade400;
        phaseLabel = "REGULAR PHASE";
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phase Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      phaseLabel,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: accent, letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900,
                        color: accent, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),

                  // Visual Element (Vial for Period Days, Icon for others)
                  if (isPeriod)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: 60,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, _) {
                            final cycleDay = algo.getCycleDay(date);
                            final profile = [0.45, 0.70, 0.60, 0.40, 0.22]; // Mock for dialog
                            final fraction = cycleDay > 0 && cycleDay <= profile.length ? profile[cycleDay-1] : 0.3;
                            
                            return CustomPaint(
                              painter: VialPainter(
                                fillFraction: fraction,
                                wavePhase: _glowController.value,
                                color: accent,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: accent.withOpacity(0.6), width: 2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Icon(Icons.auto_awesome_rounded, size: 48, color: accent),
                    ),

                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showLogSheetForDate(date);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Log Entry", style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // REUSE the painter logic locally for simplicity or import it
  // I'll add the painter definition to the bottom of home_screen.dart to avoid import issues


  void _showLogSheetForDate(DateTime date) {
    // Similar to _showQuickLogSheet but for a specific date
    final nextPredicted = CycleSession.isAnnieTrained 
        ? CycleSession.annie.getNextPeriodDate() 
        : algo.getNextPeriodDate();

    final active = CycleSession.activeCycleLog;
    
    if (active != null && date.isAfter(active.actualStart!.subtract(const Duration(days: 1))) && 
        date.isBefore(active.actualStart!.add(const Duration(days: 10)))) {
      
      final dayNum = date.difference(active.actualStart!).inDays + 1;
      final existing = CycleSession.getDayLog(dayNum);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DayLogSheet(
          dayNumber: dayNum,
          totalDays: algo.adjustedPeriodLength,
          date: date,
          initialFlow: existing?.flowPercent ?? 50,
          initialPain: existing?.painLevel ?? 0,
          onSave: (flow, pain) async {
            await CycleSession.logDay(
              dayNumber: dayNum,
              date: date,
              flowPercent: flow,
              painLevel: pain,
            );
            setState(() {});
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PeriodConfirmSheet(
          predictedDate: nextPredicted,
          onConfirm: (actual) async {
            await CycleSession.confirmPeriodStart(actual);
            setState(() {});
          },
        ),
      );
    }
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
    final nextStart = CycleSession.isAnnieTrained 
        ? CycleSession.annie.getNextPeriodDate()
        : algo.getNextPeriodDate();
    
    final nextEnd = nextStart.add(Duration(
      days: CycleSession.isAnnieTrained 
          ? CycleSession.annie.predictedPeriodLength - 1
          : algo.adjustedPeriodLength - 1
    ));

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


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../widgets/cycle_history_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  CycleAlgorithm get algo => CycleSession.algorithm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cycle Calendar",
          style: TextStyle(
            color: Color(0xFFE67598),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history,
                color: Color(0xFFE67598)),
            onPressed: _showHistorySheet,
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined,
                color: Color(0xFFE67598)),
            onPressed: _editPeriodDate,
          ),
        ],
      ),
      body: Column(
        children: [
          _calendarCard(),
          const SizedBox(height: 20),
          _selectedDayInsight(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          selectedDayPredicate: (d) => isSameDay(d, selectedDay),
          onDaySelected: (s, f) {
            setState(() {
              selectedDay = s;
              focusedDay = f;
            });
          },
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d)),
            todayBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), today: true),
            selectedBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), selected: true),
          ),
        ),
      ),
    );
  }

  Widget _dayBox(DateTime day, DayType type,
      {bool selected = false, bool today = false}) {
    Color color = Colors.transparent;

    if (type == DayType.period) {
      color = const Color(0xFFFFE0E6);
    } else if (type == DayType.fertile) {
      color = const Color(0xFFDFF6DD);
    } else if (type == DayType.ovulation) {
      color = const Color(0xFFE8E0F8);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(
                color: Colors.pinkAccent, width: 2)
            : today
                ? Border.all(
                    color: Colors.deepOrangeAccent,
                    width: 2)
                : null,
      ),
      alignment: Alignment.center,
      child: Text(
        "${day.day}",
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= BIG INSIGHT CARD =================

  Widget _selectedDayInsight() {
    final type = algo.getType(selectedDay);

    String title;
    String desc;
    Color g1;
    Color g2;

    switch (type) {
      case DayType.period:
        title = "Period Phase";
        desc =
            "Your menstrual phase. Take rest and stay hydrated.";
        g1 = const Color(0xFFFF9AA2);
        g2 = const Color(0xFFFFD1DC);
        break;

      case DayType.fertile:
        title = "Fertile Window";
        desc =
            "These are your higher fertility days.";
        g1 = const Color(0xFF81C784);
        g2 = const Color(0xFFC8E6C9);
        break;

      case DayType.ovulation:
        title = "Ovulation Day";
        desc =
            "Peak fertility day of your cycle.";
        g1 = const Color(0xFFB39DDB);
        g2 = const Color(0xFFE1BEE7);
        break;

      default:
        title = "Normal Phase";
        desc =
            "Hormonal balance phase.";
        g1 = const Color(0xFFF8BBD0);
        g2 = const Color(0xFFE1BEE7);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [g1, g2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: g1.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Selected Date: ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HISTORY SHEET =================

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30)),
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color:
                    Colors.white.withOpacity(0.9),
                child: const CycleHistorySheet(),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= EDIT PERIOD =================

  Future<void> _editPeriodDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      await CycleSession.addCycleRecord(picked);

      setState(() {
        selectedDay = picked;
        focusedDay = picked;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Cycle updated successfully"),
        ),
      );
    }
  }
}
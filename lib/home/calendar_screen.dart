import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../models/smart_prediction_model.dart';
import '../widgets/bottom_popup_editor.dart';
import '../widgets/liquid_cube_visualization.dart';
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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _calendarCard(),
            const SizedBox(height: 24),
            _selectedDayDetails(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Liora Calendar",
        style: TextStyle(
          color: Color(0xFF2D1B4D),
          fontWeight: FontWeight.w900,
          fontSize: 24,
          letterSpacing: -1,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: Colors.deepPurple),
          onPressed: _showHistorySheet,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D1B4D)),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (_, d, __) => _dayCell(d, false),
            todayBuilder: (_, d, __) => _dayCell(d, true),
            selectedBuilder: (_, d, __) => _dayCell(d, false, selected: true),
          ),
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day, bool isToday, {bool selected = false}) {
    final type = algo.getType(day);
    final log = CycleSession.getLogForDay(day);
    final expectedFlow = algo.getExpectedFlowLevel(day);
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
           // Miniature Cube for ANY window (Fertile, Ovulation, Period)
           if (type != DayType.normal)
             Opacity(
               opacity: 0.15,
               child: LiquidCubeVisualization(
                 flowLevel: type == DayType.period ? (log?.flowLevel ?? expectedFlow) : FlowLevel.none,
                 size: 32,
                 isExpected: log == null,
                 dayType: type,
               ),
             ),

           Text(
            "${day.day}",
            style: TextStyle(
              fontWeight: (selected || isToday) ? FontWeight.w900 : FontWeight.normal,
              color: selected ? Colors.deepPurple : (type == DayType.period ? Colors.red[400] : (type == DayType.ovulation ? Colors.purple[400] : Colors.grey[800])),
            ),
          ),

          if (isToday)
            Positioned(
              bottom: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  // ================= SELECTED DAY DETAILS (FROM IMAGE) =================

  Widget _selectedDayDetails() {
    final log = CycleSession.getLogForDay(selectedDay);
    final type = algo.getType(selectedDay);
    final expectedFlow = algo.getExpectedFlowLevel(selectedDay);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selected Date", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    "${selectedDay.day} ${_getMonthName(selectedDay.month)}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF2D1B4D)),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _openSmartEditor(selectedDay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: const Text("Log Flow", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          _buildFlowDisplay(log, expectedFlow, type),
        ],
      ),
    );
  }

  Widget _buildFlowDisplay(DailyLogEntry? log, FlowLevel expected, DayType type) {
    final isPeriod = type == DayType.period;
    
    return Row(
      children: [
        LiquidCubeVisualization(
          flowLevel: log?.flowLevel ?? (isPeriod ? expected : FlowLevel.none),
          size: 90,
          isExpected: log == null,
          dayType: type,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPeriod ? (log != null ? "Confirmed Flow: ${log.flowLevel.name.toUpperCase()}" : "Expected Flow: ${expected.name.toUpperCase()}") : "Current Phase: ${type.name.toUpperCase()}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isPeriod ? Colors.red : (type == DayType.ovulation ? Colors.purple : (type == DayType.fertile ? Colors.green : Colors.grey[400])),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                log != null ? "Pain Intensity: ${log.painLevel}/10" : (isPeriod ? "Forecasted intensity: ${expected.name}" : "Enjoy your day!"),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                "Status: ${log != null ? "User Confirmed" : (isPeriod ? "AI Prediction" : "Normal Mode")}",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int m) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[m - 1];
  }

  void _openSmartEditor(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SmartBottomPopupEditor(
          date: date,
          onSave: (entry) async {
            await CycleSession.updateDailyLog(entry);
            setState(() {});
          },
        );
      },
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          color: Colors.white,
          child: CycleHistorySheet(history: CycleSession.history),
        );
      },
    );
  }
}
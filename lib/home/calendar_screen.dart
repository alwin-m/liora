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
      backgroundColor: const Color(0xFFFAFAFA), // Pure minimalist background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _calendarSection(),
            const SizedBox(height: 32),
            _selectedDayInsight(),
            const SizedBox(height: 60),
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
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: Color(0xFF2D1B4D), size: 22),
          onPressed: _showHistorySheet,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ================= MINIMAL CALENDAR =================

  Widget _calendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
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
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF2D1B4D)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF2D1B4D)),
        ),
        calendarStyle: const CalendarStyle(
           todayDecoration: BoxDecoration(color: Colors.transparent),
           selectedDecoration: BoxDecoration(color: Colors.transparent),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (_, d, __) => _dayNode(d, false),
          todayBuilder: (_, d, __) => _dayNode(d, true),
          selectedBuilder: (_, d, __) => _dayNode(d, false, selected: true),
        ),
      ),
    );
  }

  Widget _dayNode(DateTime day, bool isToday, {bool selected = false}) {
    final type = algo.getType(day);
    final log = CycleSession.getLogForDay(day);
    final expectedFlow = algo.getExpectedFlowLevel(day);
    
    // Minimalist Phase Indicator Color
    Color? phaseColor;
    if (type == DayType.period) phaseColor = const Color(0xFFFF4D4D);
    if (type == DayType.ovulation) phaseColor = const Color(0xFFB39DDB);
    if (type == DayType.fertile) phaseColor = const Color(0xFF81C784);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: selected ? (phaseColor?.withOpacity(0.12) ?? Colors.grey[100]) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
           // ONLY show Cube for Period
           if (type == DayType.period)
             Opacity(
               opacity: 0.2,
               child: LiquidCubeVisualization(
                 flowLevel: log?.flowLevel ?? expectedFlow,
                 size: 34,
                 isExpected: log == null,
                 dayType: type,
               ),
             ),

           // Static Phase Indicator (Soft Circle) for Ovulation/Fertile
           if (type == DayType.ovulation || type == DayType.fertile)
             Container(
               width: 32,
               height: 32,
               decoration: BoxDecoration(
                 color: phaseColor?.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
             ),

           Text(
            "${day.day}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: (selected || isToday) ? FontWeight.w900 : FontWeight.w500,
              color: selected ? (phaseColor ?? const Color(0xFF2D1B4D)) : (phaseColor ?? Colors.grey[800]),
            ),
          ),

          if (isToday && !selected)
            Positioned(
              bottom: 8,
              child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFE67598), shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  // ================= DAY INSIGHT SECTION =================

  Widget _selectedDayInsight() {
    final log = CycleSession.getLogForDay(selectedDay);
    final type = algo.getType(selectedDay);
    final expectedFlow = algo.getExpectedFlowLevel(selectedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selected Date", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    "${selectedDay.day} ${_getMonthName(selectedDay.month)}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF2D1B4D)),
                  ),
                ],
              ),
              _interactiveLogButton(),
            ],
          ),
          const SizedBox(height: 24),
          _buildInteractiveCard(log, expectedFlow, type),
        ],
      ),
    );
  }

  Widget _interactiveLogButton() {
     return GestureDetector(
       onTap: () => _openSmartEditor(selectedDay),
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
         decoration: BoxDecoration(
           color: const Color(0xFF2D1B4D),
           borderRadius: BorderRadius.circular(20),
           boxShadow: [
             BoxShadow(color: const Color(0xFF2D1B4D).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
           ]
         ),
         child: const Text("Log Flow", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
       ),
     );
  }

  Widget _buildInteractiveCard(DailyLogEntry? log, FlowLevel expected, DayType type) {
    final isPeriod = type == DayType.period;
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40, offset: const Offset(0, 15))
        ],
      ),
      child: Row(
        children: [
          // ONLY cube for period
          if (isPeriod)
            LiquidCubeVisualization(
              flowLevel: log?.flowLevel ?? expected,
              size: 85,
              isExpected: log == null,
              dayType: type,
            )
          else
            _buildPhaseIcon(type),
          
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPeriod 
                    ? (log != null ? "Flow: ${log.flowLevel.name.toUpperCase()}" : "Predicted: ${expected.name.toUpperCase()}") 
                    : _getPhaseTitle(type),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isPeriod ? const Color(0xFFE63946) : (type == DayType.ovulation ? Colors.purple : (type == DayType.fertile ? Colors.green : Colors.grey[400])),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPhaseDescription(type, log),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIcon(DayType type) {
     Color color;
     IconData icon;
     if (type == DayType.ovulation) { color = Colors.purple; icon = Icons.auto_awesome; }
     else if (type == DayType.fertile) { color = Colors.green; icon = Icons.energy_savings_leaf_rounded; }
     else { color = Colors.grey; icon = Icons.wb_sunny_rounded; }

     return Container(
       width: 85,
       height: 85,
       decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(28)),
       child: Icon(icon, color: color, size: 32),
     );
  }

  String _getPhaseTitle(DayType type) {
     if (type == DayType.ovulation) return "OVULATION";
     if (type == DayType.fertile) return "FERTILE";
     return "NORMAL PHASE";
  }

  String _getPhaseDescription(DayType type, DailyLogEntry? log) {
     if (type == DayType.period) return log != null ? "Confirmed intense tracking." : "AI projects light spotting today.";
     if (type == DayType.ovulation) return "Highest fertility window. Energy peak.";
     if (type == DayType.fertile) return "Productive days. Hormonal rise.";
     return "Stable hormonal state. Smooth sailing.";
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
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          child: CycleHistorySheet(history: CycleSession.history),
        );
      },
    );
  }
}
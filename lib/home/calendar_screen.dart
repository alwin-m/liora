import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../home/cycle_algorithm.dart';
import '../core/cycle_session.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool isMonth = true;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  late CycleAlgorithm algo;

  final List<String> months = const [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  @override
  void initState() {
    super.initState();

    // ✅ SAME ENGINE AS HOME
    algo = CycleSession.algorithm;

    selectedDay = DateTime.now();
    focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: _monthYearToggle(),
      ),

      body: Column(
        children: [
          isMonth ? _monthCalendar() : _yearCalendar(),
          const SizedBox(height: 8),
          _editPeriodButton(),
          const SizedBox(height: 8),
          _bottomCard(),
        ],
      ),
    );
  }

  // 🔄 Month / Year toggle
  Widget _monthYearToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleItem("Month", isMonth, () {
            setState(() => isMonth = true);
          }),
          _toggleItem("Year", !isMonth, () {
            setState(() => isMonth = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 📅 Month Calendar
  Widget _monthCalendar() {
    return TableCalendar(
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
        defaultBuilder: (_, day, __) => _dayCell(day),
        todayBuilder: (_, day, __) => _todayCell(day),
        selectedBuilder: (_, day, __) => _todayCell(day),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  // 📆 Year View
  Widget _yearCalendar() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                focusedDay = DateTime(focusedDay.year, index + 1);
                isMonth = true;
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  months[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎨 Day Cell
  Widget _dayCell(DateTime day) {
    final DayType type = algo.getType(day);

    Color? borderColor;
    Color textColor = Colors.black;

    if (type == DayType.period) {
      borderColor = Colors.pink;
      textColor = Colors.pink;
    } else if (type == DayType.fertile) {
      borderColor = Colors.teal;
      textColor = Colors.teal;
    } else if (type == DayType.ovulation) {
      borderColor = Colors.purple;
      textColor = Colors.purple;
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _todayCell(DateTime day) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ✏️ EDIT PERIOD BUTTON (WORKING)
  Widget _editPeriodButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 222, 120, 154),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: _editLastPeriodDate,
      child: const Text("Edit period dates"),
    );
  }

  // 🔥 EDIT LAST PERIOD DATE LOGIC
  Future<void> _editLastPeriodDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: algo.lastPeriod,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      // 🔄 Rebuild cycle engine safely
      CycleSession.algorithm = CycleAlgorithm(
        lastPeriod: DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        ),
        cycleLength: algo.cycleLength,
        periodLength: algo.periodLength,
      );

      algo = CycleSession.algorithm;
      selectedDay = pickedDate;
      focusedDay = pickedDate;
    });
  }

  // 📊 Bottom Info Card (Cycle Day)
  Widget _bottomCard() {
    final int diff =
        selectedDay.difference(algo.lastPeriod).inDays;

    final int safeDiff =
        ((diff % algo.cycleLength) + algo.cycleLength) %
            algo.cycleLength;

    final int cycleDay = safeDiff + 1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${months[selectedDay.month - 1].substring(0, 3)} ${selectedDay.day} · Cycle day $cycleDay",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.close, color: Colors.white),
          )
        ],
      ),
    );
  }
}

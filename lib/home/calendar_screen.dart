import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' show TableCalendar, HeaderStyle, CalendarBuilders, isSameDay;

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool isMonth = true;

  DateTime focusedDay = DateTime(2026, 1);
  DateTime selectedDay = DateTime(2026, 1, 14);

  final List<int> fertileDays = [7];
  final List<int> predictedPeriodDays = [22, 23, 24, 25, 26];

  final List<String> months = const [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // ✅ FIXED CLOSE BUTTON
        /*leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),*/
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

  // 🔁 Month / Year toggle
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

  // 📅 MONTH CALENDAR
  Widget _monthCalendar() {
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2030),
      selectedDayPredicate: (d) => isSameDay(d, selectedDay),
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

  // 🗓 YEAR CALENDAR
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

  // 🟢 Normal / dotted day
  Widget _dayCell(DateTime day) {
    final int d = day.day;

    final bool isFertile = fertileDays.contains(d);
    final bool isPredicted = predictedPeriodDays.contains(d);

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isFertile
              ? Border.all(color: Colors.teal, width: 2)
              : isPredicted
                  ? Border.all(color: Colors.pink, width: 2)
                  : null,
        ),
        child: Center(
          child: Text(
            "$d",
            style: TextStyle(
              color: isPredicted
                  ? Colors.pink
                  : isFertile
                      ? Colors.teal
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 TODAY
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

  // ✏ Edit button
  Widget _editPeriodButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 222, 120, 154),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {},
      child: const Text("Edit period dates"),
    );
  }

  // ⬇ Bottom card
  Widget _bottomCard() {
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
        children: const [
          Text(
            "Jan 14 · Cycle day 22",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.close, color: Colors.white),
          )
        ],
      ),
    );
  }
}

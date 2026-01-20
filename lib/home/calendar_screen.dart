import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' show TableCalendar, HeaderStyle, CalendarBuilders, isSameDay;
import '../services/cycle_data_service.dart';
import 'cycle_algorithm.dart';
import 'first_time_setup.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool isMonth = true;
  late DateTime focusedDay;
  late DateTime selectedDay;
  late CycleDataService cycleService;

  final List<String> months = const [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    focusedDay = DateTime(today.year, today.month);
    selectedDay = today;
    cycleService = CycleDataService();
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    await cycleService.loadUserCycleData();
    if (mounted) {
      setState(() {});
    }
  }

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
      onDaySelected: (selectedDate, focusedDate) {
        setState(() {
          selectedDay = selectedDate;
          focusedDay = focusedDate;
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
    final dayType = cycleService.getDayType(day);
    final Color color = _getDayColor(dayType);

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dayType == DayType.period ? color : Colors.transparent,
          border: dayType == DayType.fertile
              ? Border.all(color: color, width: 2)
              : dayType == DayType.ovulation
                  ? Border.all(color: color, width: 2)
                  : null,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              color: dayType == DayType.period ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Color _getDayColor(DayType type) {
    switch (type) {
      case DayType.period:
        return Colors.pink;
      case DayType.fertile:
        return Colors.teal;
      case DayType.ovulation:
        return Colors.purple;
      case DayType.normal:
        return Colors.grey;
    }
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
      onPressed: () {
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
      },
      child: const Text("Edit period dates"),
    );
  }

  // ⬇ Bottom card
  Widget _bottomCard() {
    final currentCycleDay = cycleService.getCurrentCycleDay();
    final dayName = _getDayName(selectedDay);
    
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
            "$dayName ${selectedDay.day} · Cycle day $currentCycleDay",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = DateTime.now();
                focusedDay = DateTime.now();
              });
            },
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.close, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final index = date.weekday - 1;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }
}

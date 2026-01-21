import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/cycle_state.dart';
import '../core/cycle_state_manager.dart';
import '../core/prediction_engine.dart';
import 'period_input_sheet.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool isMonth = true;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  late CycleState state;

  final List<String> months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  /// Load or get cached state (optimized for quick access)
  Future<void> _initializeState() async {
    final manager = CycleStateManager.instance;
    final loadedState = await manager.loadState();
    setState(() {
      state = loadedState;
      selectedDay = DateTime.now();
      focusedDay = DateTime.now();
    });
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

      floatingActionButton: _periodInputFAB(),
    );
  }

  // 🩹 Floating action button for period tracking
  Widget _periodInputFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.pink.shade400,
      onPressed: _showPeriodInputSheet,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  // 📱 Show iOS-style bottom sheet for period input
  void _showPeriodInputSheet() async {
    // Branch on current bleeding state
    final isPeriodActive = state.bleedingState == BleedingState.activeBleeding;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (_) => PeriodInputSheet(
        isPeriodActive: isPeriodActive,
        onSaved: _handlePeriodSaved,
      ),
    );
  }

  // 💾 Handle saved period data
  Future<void> _handlePeriodSaved(String type, DateTime date) async {
    // Mutate state based on event
    if (type == 'start') {
      state.markPeriodStart(date);
    } else {
      state.markPeriodStop(date);
    }

    // Persist state using manager (also caches it)
    final manager = CycleStateManager.instance;
    await manager.updateState(state);

    // Refresh calendar immediately
    setState(() {
      selectedDay = date;
      focusedDay = date;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'start'
                ? 'Period start recorded on ${_formatDate(date)}'
                : 'Period end recorded on ${_formatDate(date)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month]} ${date.day}';
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

  // 🎨 Day Cell - Pure rendering from state
  Widget _dayCell(DateTime day) {
    final colors = _getDayColors(day);

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.backgroundColor,
          border: colors.borderColor != null
              ? Border.all(color: colors.borderColor!, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              color: colors.textColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to get colors for a day based on its type
  /// Centralized for reuse by both _dayCell and _todayCell
  _DayColors _getDayColors(DateTime day) {
    final dayType = PredictionEngine.getDayType(day, state);

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Colors.black;

    // Rendering priority as per spec:
    // 1. Confirmed bleeding (solid red)
    // 2. Active bleeding (vibrant red with animation potential)
    // 3. Predicted bleeding (light red)
    // 4. Ovulation (purple)
    // 5. Fertile window (green)
    // 6. Normal (transparent)

    switch (dayType) {
      case DayType.period:
        backgroundColor = const Color(0xFFFFE0E6); // Confirmed: light pink
        borderColor = Colors.pink;
        textColor = Colors.pink;
        break;
      case DayType.activePeriod:
        backgroundColor = const Color(0xFFFFCDD2); // Active: more vibrant pink
        borderColor = Colors.pink.shade600;
        textColor = Colors.pink.shade700;
        break;
      case DayType.predictedPeriod:
        backgroundColor = const Color(0xFFFFE0E6).withOpacity(0.6);
        borderColor = Colors.pink.shade200;
        textColor = Colors.pink.shade300;
        break;
      case DayType.ovulation:
        backgroundColor = const Color(0xFFE8E0F8);
        borderColor = Colors.purple;
        textColor = Colors.purple;
        break;
      case DayType.fertile:
        backgroundColor = const Color(0xFFDFF6DD);
        borderColor = Colors.teal;
        textColor = Colors.teal;
        break;
      case DayType.normal:
        break;
    }

    return _DayColors(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textColor: textColor,
    );
  }

  /// Today cell - shows day type colors PLUS a "today" indicator
  /// Critical fix: Today must show bleeding/fertile colors, not just grey
  Widget _todayCell(DateTime day) {
    final colors = _getDayColors(day);

    // Use day type color if available, otherwise use grey for "today"
    final bgColor = colors.backgroundColor ?? const Color(0xFFE0E0E0);

    return Center(
      child: Container(
        width: 40, // Slightly larger to indicate "today"
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.borderColor ?? Colors.grey.shade600,
            width: 2.5, // Thicker border for "today"
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: _editLastPeriodDate,
      child: const Text("Edit period dates"),
    );
  }

  // 🔥 EDIT LAST PERIOD DATE LOGIC
  Future<void> _editLastPeriodDate() async {
    final lastCycle = state.getLastConfirmedCycle();
    final initialDate = lastCycle?.cycleStartDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    // Update state and save
    state.markPeriodStart(pickedDate);
    final manager = CycleStateManager.instance;
    await manager.updateState(state);

    setState(() {
      selectedDay = pickedDate;
      focusedDay = pickedDate;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Period start updated to ${_formatDate(pickedDate)}'),
        ),
      );
    }
  }

  // 📊 Bottom Info Card (Cycle Day)
  Widget _bottomCard() {
    // Calculate cycle day based on state
    int cycleDay = 1;

    if (state.bleedingStartDate != null) {
      final diff = selectedDay.difference(state.bleedingStartDate!).inDays;
      final safeDiff =
          ((diff % state.getEffectiveCycleLength()) +
              state.getEffectiveCycleLength()) %
          state.getEffectiveCycleLength();
      cycleDay = safeDiff + 1;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
          ),
        ],
      ),
    );
  }
}

/// Helper class to hold day cell colors
class _DayColors {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color textColor;

  const _DayColors({
    this.backgroundColor,
    this.borderColor,
    required this.textColor,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/liora_theme.dart';
import '../../../core/engine/prediction_engine.dart';
import '../../cycle/providers/cycle_provider.dart';

/// Interactive calendar view with color-coded days
class CalendarView extends StatefulWidget {
  final ValueChanged<DateTime> onDaySelected;

  const CalendarView({
    super.key,
    required this.onDaySelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _pageController = PageController(
        initialPage: 1000); // Start at middle for infinite scroll
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMonthFromPage(int page) {
    final now = DateTime.now();
    final baseMonth = DateTime(now.year, now.month);
    return DateTime(baseMonth.year, baseMonth.month + (page - 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LioraRadius.xxl),
        boxShadow: LioraShadows.soft,
      ),
      child: Column(
        children: [
          // Month navigation
          _buildMonthHeader(),

          // Weekday headers
          _buildWeekdayHeaders(),

          // Calendar grid
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _focusedMonth = _getMonthFromPage(page);
                });
              },
              itemBuilder: (context, page) {
                final month = _getMonthFromPage(page);
                return _buildCalendarGrid(month);
              },
            ),
          ),

          const SizedBox(height: LioraSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.all(LioraSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: LioraColors.textPrimary,
            ),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: LioraTextStyles.calendarHeader,
          ),
          IconButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: LioraColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          return SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: LioraTextStyles.labelSmall.copyWith(
                color: LioraColors.textMuted,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final firstDayOfMonth = DateTime(month.year, month.month, 1);
        final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
        final firstWeekday = firstDayOfMonth.weekday % 7;
        final today = DateTime.now();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.sm),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42, // 6 rows x 7 columns
            itemBuilder: (context, index) {
              final dayOffset = index - firstWeekday;

              if (dayOffset < 0 || dayOffset >= lastDayOfMonth.day) {
                return const SizedBox();
              }

              final date = DateTime(month.year, month.month, dayOffset + 1);
              final isToday = _isSameDay(date, today);
              final isSelected = provider.isSelectedDate(date);
              final dayType = provider.getDayType(date);

              return _buildDayCell(
                date: date,
                dayType: dayType,
                isToday: isToday,
                isSelected: isSelected,
                onTap: () => widget.onDaySelected(date),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required DayType dayType,
    required bool isToday,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color backgroundColor = Colors.transparent;
    Color textColor = LioraColors.textPrimary;
    BoxBorder? border;

    // Apply color based on day type
    switch (dayType) {
      case DayType.period:
        backgroundColor = LioraColors.periodDay;
        textColor = Colors.white;
        break;
      case DayType.predictedPeriod:
        backgroundColor = LioraColors.predictedPeriod.withOpacity(0.6);
        break;
      case DayType.fertile:
        backgroundColor = LioraColors.fertileWindow;
        break;
      case DayType.ovulation:
        backgroundColor = LioraColors.ovulationDay;
        textColor = Colors.white;
        break;
      case DayType.normal:
        break;
    }

    // Today indicator
    if (isToday) {
      border = Border.all(color: LioraColors.deepRose, width: 2);
    }

    // Selected indicator
    if (isSelected) {
      border = Border.all(color: LioraColors.textPrimary, width: 2);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: LioraTextStyles.calendarDay.copyWith(
              color: textColor,
              fontWeight:
                  isToday || isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

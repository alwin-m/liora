import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/liora_theme.dart';
import 'onboarding_step.dart';

/// Date picker step for onboarding
class DatePickerStep extends StatefulWidget {
  final String title;
  final String subtitle;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;

  const DatePickerStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
  });

  @override
  State<DatePickerStep> createState() => _DatePickerStepState();
}

class _DatePickerStepState extends State<DatePickerStep> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.selectedDate ?? widget.maxDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      title: widget.title,
      subtitle: widget.subtitle,
      child: Column(
        children: [
          // Selected date display
          if (widget.selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LioraSpacing.lg,
                vertical: LioraSpacing.md,
              ),
              decoration: BoxDecoration(
                color: LioraColors.primaryPink,
                borderRadius: BorderRadius.circular(LioraRadius.large),
              ),
              child: Text(
                DateFormat('MMMM d, y').format(widget.selectedDate!),
                style: LioraTextStyles.h3.copyWith(
                  color: LioraColors.deepRose,
                ),
              ),
            ),

          const SizedBox(height: LioraSpacing.lg),

          // Calendar
          Expanded(
            child: _buildCalendar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        // Month navigation
        _buildMonthNavigation(),

        const SizedBox(height: LioraSpacing.md),

        // Weekday headers
        _buildWeekdayHeaders(),

        const SizedBox(height: LioraSpacing.sm),

        // Calendar grid
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _canGoBack() ? _previousMonth : null,
          icon: Icon(
            Icons.chevron_left_rounded,
            color:
                _canGoBack() ? LioraColors.textPrimary : LioraColors.textMuted,
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_displayedMonth),
          style: LioraTextStyles.label,
        ),
        IconButton(
          onPressed: _canGoForward() ? _nextMonth : null,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: _canGoForward()
                ? LioraColors.textPrimary
                : LioraColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: LioraTextStyles.labelSmall,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    // Empty cells for days before the first day of month
    for (var i = 0; i < firstWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    // Days of the month
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected =
          widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);
      final isEnabled = _isDateEnabled(date);

      days.add(
        GestureDetector(
          onTap: isEnabled ? () => widget.onDateSelected(date) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? LioraColors.accentRose : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: LioraTextStyles.calendarDay.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isEnabled
                          ? LioraColors.textPrimary
                          : LioraColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  bool _canGoBack() {
    if (widget.minDate == null) return true;
    final previousMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    return previousMonth
        .isAfter(DateTime(widget.minDate!.year, widget.minDate!.month - 1));
  }

  bool _canGoForward() {
    if (widget.maxDate == null) return true;
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    return nextMonth
        .isBefore(DateTime(widget.maxDate!.year, widget.maxDate!.month + 2));
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  bool _isDateEnabled(DateTime date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) return false;
    return true;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

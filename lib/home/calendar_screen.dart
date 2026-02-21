import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/cycle_provider.dart';
import '../home/cycle_algorithm.dart';
import '../models/cycle_data.dart';
import '../models/cycle_history_entry.dart';
import '../core/app_theme.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen>
    with SingleTickerProviderStateMixin {
  bool isMonth = true;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  static const List<String> _months = [
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: cs.onSurface),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: _monthYearToggle(cs),
      ),
      body: Consumer<CycleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }
          final data = provider.cycleData!;
          final algo = CycleAlgorithm(
            lastPeriod: data.lastPeriodStartDate,
            cycleLength: data.averageCycleLength,
            periodLength: data.averagePeriodDuration,
          );

          return Column(
            children: [
              AnimatedSwitcher(
                duration: LioraTheme.durationMedium,
                switchInCurve: LioraTheme.curveStandard,
                child: isMonth ? _monthCalendar(algo, cs) : _yearCalendar(cs),
              ),
              const SizedBox(height: LioraTheme.space8),
              _editPeriodButton(data, cs),
              const SizedBox(height: LioraTheme.space8),
              _bottomCard(provider, algo, cs),
            ],
          );
        },
      ),
    );
  }

  void _showHistorySheet(CycleProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Cycle History',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cycle history will appear here after\nyour first completed cycle.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      itemCount: provider.history.length,
                      itemBuilder: (context, index) {
                        final entry = provider.history[index];
                        return _buildHistoryItem(entry);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(CycleHistoryEntry entry) {
    final start = entry.actualStartDate ?? entry.predictedStartDate;
    final String monthName = _months[start.month - 1];

    Color indicatorColor = Colors.green;
    if (entry.predictionDeviationDays.abs() > 3) {
      indicatorColor = Colors.red;
    } else if (entry.predictionDeviationDays.abs() > 0) {
      indicatorColor = Colors.amber;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.grey[200])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$monthName ${start.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Started on ${start.day} $monthName',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoBadge(
                        '${entry.cycleLength} days',
                        Colors.grey[100]!,
                      ),
                      const SizedBox(width: 8),
                      _infoBadge(
                        'Deviation: ${entry.predictionDeviationDays}d',
                        indicatorColor.withAlpha(20),
                        textColor: indicatorColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String text, Color bg, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // Toggle
  Widget _monthYearToggle(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleItem("Month", isMonth, cs, () {
            setState(() => isMonth = true);
          }),
          _toggleItem("Year", !isMonth, cs, () {
            setState(() => isMonth = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(
    String text,
    bool active,
    ColorScheme cs,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: LioraTheme.durationFast,
        curve: LioraTheme.curveStandard,
        padding: const EdgeInsets.symmetric(
          horizontal: LioraTheme.space20,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: active ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: cs.shadow.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active ? cs.onSurface : cs.onSurface.withAlpha(120),
          ),
        ),
      ),
    );
  }

  // Month Calendar
  Widget _monthCalendar(CycleAlgorithm algo, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: LioraTheme.spaceLarge),
      decoration: BoxDecoration(
        color: LioraTheme.pureWhite,
        borderRadius: BorderRadius.circular(LioraTheme.radiusSheet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        key: const ValueKey('month'),
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
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(
            color: LioraTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: const TextStyle(
            color: LioraTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (_, day, __) => _dayCell(day, algo, cs),
          todayBuilder: (_, day, __) => _todayCell(day, cs),
          selectedBuilder: (_, day, __) => _selectedCell(day, cs),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: LioraTheme.textSecondary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: LioraTheme.textSecondary,
          ),
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: LioraTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  // Year View
  Widget _yearCalendar(ColorScheme cs) {
    return Expanded(
      key: const ValueKey('year'),
      child: GridView.builder(
        padding: const EdgeInsets.all(LioraTheme.spaceMedium),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, index) {
          final isCurrent = DateTime.now().month == index + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                focusedDay = DateTime(focusedDay.year, index + 1);
                isMonth = true;
              });
            },
            child: AnimatedContainer(
              duration: LioraTheme.durationFast,
              margin: const EdgeInsets.all(LioraTheme.space4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? LioraTheme.blushRose.withAlpha(80)
                    : LioraTheme.pureWhite,
                borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _months[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: LioraTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Day Cell with Luxury Soft Palette
  Widget _dayCell(DateTime day, CycleAlgorithm algo, ColorScheme cs) {
    final DayType type = algo.getType(day);
    Color? bgColor;
    Color textColor = LioraTheme.textPrimary;

    if (type == DayType.period) {
      bgColor = LioraTheme.roseRedMuted.withAlpha(60);
      textColor = LioraTheme.roseRedMuted;
    } else if (type == DayType.fertile || type == DayType.ovulation) {
      bgColor = LioraTheme.sageGreen.withAlpha(60);
      textColor = LioraTheme.sageGreen;
    }

    return Center(
      child: AnimatedContainer(
        duration: LioraTheme.durationStandard,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              color: textColor,
              fontWeight: bgColor != null ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _todayCell(DateTime day, ColorScheme cs) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: LioraTheme.coralSoft, width: 1.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: LioraTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedCell(DateTime day, ColorScheme cs) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: LioraTheme.blushRose,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: LioraTheme.blushRose.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: LioraTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // Edit Period Button
  Widget _editPeriodButton(CycleDataModel data, ColorScheme cs) {
    return FilledButton.tonal(
      onPressed: () => _editLastPeriodDate(data),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
        ),
      ),
      child: const Text("Edit period dates"),
    );
  }

  Future<void> _editLastPeriodDate(CycleDataModel data) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: data.lastPeriodStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;
    if (!mounted) return;
    final provider = Provider.of<CycleProvider>(context, listen: false);
    await provider.updateCycleData(
      lastPeriodStartDate: DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      ),
      averageCycleLength: data.averageCycleLength,
      averagePeriodDuration: data.averagePeriodDuration,
    );

    setState(() {
      selectedDay = pickedDate;
      focusedDay = pickedDate;
    });
  }

  // Bottom Info Card (Interactive History Bar)
  Widget _bottomCard(
    CycleProvider provider,
    CycleAlgorithm algo,
    ColorScheme cs,
  ) {
    final int diff = selectedDay.difference(algo.lastPeriod).inDays;
    final int safeDiff =
        ((diff % algo.cycleLength) + algo.cycleLength) % algo.cycleLength;
    final int cycleDay = safeDiff + 1;

    return GestureDetector(
      onTap: () => _showHistorySheet(provider),
      child: Container(
        margin: const EdgeInsets.all(LioraTheme.space16),
        padding: const EdgeInsets.symmetric(
          horizontal: LioraTheme.space24,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Cycle Day $cycleDay",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.pink[800],
                    ),
                  ),
                  Text(
                    "${_months[selectedDay.month - 1]} ${selectedDay.day}, ${selectedDay.year}",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.history_rounded, color: Colors.pink, size: 28),
          ],
        ),
      ),
    );
  }
}

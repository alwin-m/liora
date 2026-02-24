enum DayType { period, fertile, ovulation, normal }

class CycleAlgorithm {
  final DateTime lastPeriod;
  final int cycleLength;
  final int periodLength;

  CycleAlgorithm({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodLength,
  });

  int getCycleDay(DateTime date) {
    final normalizedLast = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final diff = normalizedDate.difference(normalizedLast).inDays;
    final safeDiff = ((diff % cycleLength) + cycleLength) % cycleLength;
    return safeDiff + 1;
  }

  DayType getType(DateTime date) {
    final cycleDay = getCycleDay(date);
    if (cycleDay >= 1 && cycleDay <= periodLength) {
      return DayType.period;
    }
    final ovulationDay = cycleLength - 14;
    if (cycleDay == ovulationDay) {
      return DayType.ovulation;
    }
    if (cycleDay >= ovulationDay - 5 && cycleDay < ovulationDay) {
      return DayType.fertile;
    }
    return DayType.normal;
  }

  DateTime getNextPeriodDate() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedLast = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );
    final diff = normalizedToday.difference(normalizedLast).inDays;
    if (diff <= 0) return normalizedLast;
    final cyclesPassed = diff ~/ cycleLength + 1;
    return normalizedLast.add(Duration(days: cyclesPassed * cycleLength));
  }
}

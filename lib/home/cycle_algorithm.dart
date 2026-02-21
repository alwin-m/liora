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

  /// Cycle day calculation (BIOLOGICALLY CORRECT + SAFE)
  int getCycleDay(DateTime date) {
    final normalizedLast =
        DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);
    final normalizedDate =
        DateTime(date.year, date.month, date.day);

    final diff = normalizedDate.difference(normalizedLast).inDays;

    // ✅ FIX: Safe positive modulo (prevents negative cycle days)
    final safeDiff =
        ((diff % cycleLength) + cycleLength) % cycleLength;

    return safeDiff + 1; // Day 1 = first day of period
  }

  DayType getType(DateTime date) {
    final cycleDay = getCycleDay(date);

    // 🩸 Period days: Day 1 → periodLength
    if (cycleDay >= 1 && cycleDay <= periodLength) {
      return DayType.period;
    }

    // 🥚 Ovulation ≈ 14 days before next period
    final ovulationDay = cycleLength - 14;

    if (cycleDay == ovulationDay) {
      return DayType.ovulation;
    }

    // 🌱 Fertile window = 5 days before ovulation (EXCLUDING ovulation day)
    if (cycleDay >= ovulationDay - 5 &&
        cycleDay < ovulationDay) {
      return DayType.fertile;
    }

    return DayType.normal;
  }

  /// Next period prediction (MATHEMATICALLY CORRECT)
  DateTime getNextPeriodDate() {
    final today = DateTime.now();
    final normalizedToday =
        DateTime(today.year, today.month, today.day);

    final normalizedLast =
        DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);

    final diff =
        normalizedToday.difference(normalizedLast).inDays;

    // ✅ FIX: If today is before or on lastPeriod, next = lastPeriod
    if (diff <= 0) return normalizedLast;

    final cyclesPassed = diff ~/ cycleLength + 1;

    return normalizedLast.add(
      Duration(days: cyclesPassed * cycleLength),
    );
  }
}

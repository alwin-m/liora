enum DayType { period, fertile, ovulation, normal }

class CycleAlgorithm {
  final DateTime lastPeriod;
  final int cycleLength;
  final int periodLength;
  
  // Real period data from LocalCycleStorage
  DateTime? recentPeriodStart;
  DateTime? recentPeriodEnd;

  CycleAlgorithm({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodLength,
    this.recentPeriodStart,
    this.recentPeriodEnd,
  });

  /// Cycle day calculation - uses RECENT period data if available
  int getCycleDay(DateTime date) {
    // Use recent period start if available, otherwise use algorithm's lastPeriod
    final cycleBase = recentPeriodStart ?? lastPeriod;
    
    final normalizedLast =
        DateTime(cycleBase.year, cycleBase.month, cycleBase.day);
    final normalizedDate =
        DateTime(date.year, date.month, date.day);

    final diff = normalizedDate.difference(normalizedLast).inDays;

    // ✅ FIX: Safe positive modulo (prevents negative cycle days)
    final safeDiff =
        ((diff % cycleLength) + cycleLength) % cycleLength;

    return safeDiff + 1; // Day 1 = first day of period
  }

  DayType getType(DateTime date) {
    final normalizedDate =
        DateTime(date.year, date.month, date.day);

    // ✅ NEW: Check if date is within marked period (stored start → end)
    if (recentPeriodStart != null) {
      final normalizedStart =
          DateTime(recentPeriodStart!.year, recentPeriodStart!.month, recentPeriodStart!.day);
      
      // If period end is marked, check range: start → end
      if (recentPeriodEnd != null) {
        final normalizedEnd =
            DateTime(recentPeriodEnd!.year, recentPeriodEnd!.month, recentPeriodEnd!.day);
        
        if (normalizedDate.isAfter(normalizedStart.subtract(const Duration(days: 1))) &&
            normalizedDate.isBefore(normalizedEnd.add(const Duration(days: 1)))) {
          return DayType.period;
        }
      } else {
        // Period start marked but not end → assume ongoing period for periodLength days
        final periodEndEstimate = normalizedStart.add(Duration(days: periodLength - 1));
        if (normalizedDate.isAfter(normalizedStart.subtract(const Duration(days: 1))) &&
            normalizedDate.isBefore(periodEndEstimate.add(const Duration(days: 1)))) {
          return DayType.period;
        }
      }
    }

    // Fall back to algorithm predictions
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

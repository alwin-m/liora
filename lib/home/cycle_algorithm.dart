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

  DayType getType(DateTime date) {
    final diff = date.difference(lastPeriod).inDays % cycleLength;

    if (diff >= 0 && diff < periodLength) return DayType.period;
    if (diff == cycleLength - 14) return DayType.ovulation;
    if (diff >= cycleLength - 18 && diff <= cycleLength - 11) {
      return DayType.fertile;
    }
    return DayType.normal;
  }

  /// Get the ovulation day of the current cycle
  int getOvulationDay() => cycleLength - 14;

  /// Get fertile window start day (5 days before ovulation)
  int getFertileWindowStart() => cycleLength - 18;

  /// Get fertile window end day (1 day after ovulation)
  int getFertileWindowEnd() => cycleLength - 13;

  /// Calculate next period start date
  DateTime getNextPeriodDate() {
    return lastPeriod.add(Duration(days: cycleLength));
  }

  /// Calculate next ovulation date
  DateTime getNextOvulationDate() {
    final nextCycleStart = getNextPeriodDate();
    return nextCycleStart.add(Duration(days: getOvulationDay()));
  }

  /// Get all fertile days for the next cycle
  List<DateTime> getFertileDatesForNextCycle() {
    final nextCycleStart = getNextPeriodDate();
    final List<DateTime> fertileDates = [];
    
    for (int i = getFertileWindowStart(); i <= getFertileWindowEnd(); i++) {
      fertileDates.add(nextCycleStart.add(Duration(days: i)));
    }
    return fertileDates;
  }

  /// Check if a date is within the fertile window
  bool isFertileDay(DateTime date) {
    final diff = date.difference(lastPeriod).inDays % cycleLength;
    return diff >= getFertileWindowStart() && diff <= getFertileWindowEnd();
  }

  /// Check if a date is the ovulation day
  bool isOvulationDay(DateTime date) {
    final diff = date.difference(lastPeriod).inDays % cycleLength;
    return diff == getOvulationDay();
  }

  /// Check if a date is during period
  bool isPeriodDay(DateTime date) {
    final diff = date.difference(lastPeriod).inDays % cycleLength;
    return diff >= 0 && diff < periodLength;
  }
}

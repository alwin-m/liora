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
}

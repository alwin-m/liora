import 'advanced_cycle_profile.dart';
import '../models/smart_prediction_model.dart';

enum DayType { period, fertile, ovulation, normal }

class CycleAlgorithm {
  final AdvancedCycleProfile profile;

  CycleAlgorithm({required this.profile});

  // ==============================
  // NORMALIZE DATE (REMOVE TIME)
  // ==============================

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ==============================
  // ADJUSTED CYCLE LENGTH
  // ==============================

  int get adjustedCycleLength {
    int base = profile.averageCycleLength;

    if (!profile.isRegularCycle) base += 1;
    if (profile.stressLevel == 2) base += 1;
    if (profile.hasPCOS) base += 2;
    if (profile.sleepQuality == 0) base += 1;

    return base.clamp(21, 40);
  }

  // ==============================
  // ADJUSTED PERIOD LENGTH
  // ==============================

  int get adjustedPeriodLength {
    int base = profile.averagePeriodLength;

    if (profile.flowIntensity >= 2) base += 1;
    if (profile.painLevel >= 2) base += 1;

    return base.clamp(3, 10);
  }

  // ==============================
  // SAFE CYCLE DAY CALCULATION
  // ==============================

  int getCycleDay(DateTime date) {
    final normalizedDate = _normalize(date);
    final normalizedLast = _normalize(profile.lastPeriodDate);

    final diff = normalizedDate.difference(normalizedLast).inDays;

    int cycleLength = adjustedCycleLength;

    // Proper modulo handling for negative numbers
    int cycleDay = ((diff % cycleLength) + cycleLength) % cycleLength;

    return cycleDay + 1; // 1-based cycle day
  }

  // ==============================
  // SAFE OVULATION DAY
  // ==============================

  int get ovulationDay {
    int ovDay = adjustedCycleLength - 14;

    // Biological safety guard
    if (ovDay < 10) ovDay = 10;
    if (ovDay > adjustedCycleLength - 10) {
      ovDay = adjustedCycleLength - 10;
    }

    return ovDay;
  }

  // ==============================
  // NEXT PERIOD DATE (FIXED)
  // ==============================

  DateTime getNextPeriodDate() {
    final today = _normalize(DateTime.now());
    final last = _normalize(profile.lastPeriodDate);

    final diff = today.difference(last).inDays;
    final cycleLength = adjustedCycleLength;

    if (diff < 0) {
      // If today is before last period (edge case)
      return last;
    }

    int cyclesPassed = diff ~/ cycleLength;

    return last.add(
      Duration(days: (cyclesPassed + 1) * cycleLength),
    );
  }

  // ==============================
  // DAY TYPE CLASSIFICATION
  // ==============================

  DayType getType(DateTime date) {
    final cycleDay = getCycleDay(date);
    final ovDay = ovulationDay;
    final periodLength = adjustedPeriodLength;

    // Period phase
    if (cycleDay >= 1 && cycleDay <= periodLength) {
      return DayType.period;
    }

    // Ovulation day
    if (cycleDay == ovDay) {
      return DayType.ovulation;
    }

    // Fertile window (5 days before ovulation)
    if (cycleDay >= ovDay - 5 && cycleDay < ovDay) {
      return DayType.fertile;
    }

    return DayType.normal;
  }

  // ==============================
  // FLOW ESTIMATION
  // ==============================

  FlowLevel getExpectedFlowLevel(DateTime date) {
    final cycleDay = getCycleDay(date);
    final periodLength = adjustedPeriodLength;

    if (cycleDay < 1 || cycleDay > periodLength) return FlowLevel.none;

    // Accurate flow distribution
    if (cycleDay == 1) return FlowLevel.spotting;
    if (cycleDay == 2 || cycleDay == 3) return FlowLevel.heavy;
    if (cycleDay == 4) return FlowLevel.medium;
    if (cycleDay >= 5 && cycleDay < periodLength) return FlowLevel.light;
    if (cycleDay == periodLength) return FlowLevel.spotting;

    return FlowLevel.medium;
  }

  int getDayInPhase(DateTime date) {
    return getCycleDay(date);
  }

  // ==============================
  // CONFIDENCE SCORE (90% CAP)
  // ==============================

  double get confidenceScore {
    double score = 0.75;

    if (profile.isRegularCycle) score += 0.05;
    if (!profile.hasPCOS) score += 0.05;
    if (profile.stressLevel == 0) score += 0.03;
    if (profile.sleepQuality >= 1) score += 0.02;

    return score.clamp(0.75, 0.90);
  }
}
import 'package:lioraa/models/cycle_record.dart';
import 'advanced_cycle_profile.dart';

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
  // HEALTH SCORE CALCULATION
  // ==============================

  /// Calculates a gamified health score (0-100) based on:
  /// 1. Profile factors (Regularity, PCOS, Stress, Sleep)
  /// 2. Tracking consistency (Streak)
  /// 3. Deviation history (How close actual periods were to predicted ones)
  double calculateHealthScore(List<CycleRecord> history) {
    double baseScore = 75.0; // Base starting point

    // factor 1: Profile Factors (Max +15)
    if (profile.isRegularCycle) baseScore += 5;
    if (!profile.hasPCOS) baseScore += 5;
    if (profile.stressLevel == 0) baseScore += 3;
    if (profile.sleepQuality >= 1) baseScore += 2;

    // factor 2: Tracking Streak (Max +10)
    // Each month of consistent tracking gives a 2% boost
    int streak = getTrackingStreak(history);
    baseScore += (streak * 2.0).clamp(0.0, 10.0);

    // factor 3: Deviation Penalty (Max -30)
    // We look at the last 3 records to see if there's a pattern of irregularity
    if (history.isNotEmpty) {
      double deviationPenalty = 0;
      int recordsToView = history.length > 3 ? 3 : history.length;
      
      for (int i = 0; i < recordsToView; i++) {
        int absDev = history[i].deviation.abs();
        if (absDev > 10) {
          deviationPenalty += 10;
        } else if (absDev > 5) {
          deviationPenalty += 5;
        } else if (absDev > 2) {
          deviationPenalty += 2;
        }
      }
      baseScore -= deviationPenalty;
    }

    return baseScore.clamp(1.0, 100.0);
  }

  /// Calculates the tracking streak in months.
  /// A streak is maintained if there is a record for consecutive months.
  int getTrackingStreak(List<CycleRecord> history) {
    if (history.isEmpty) return 0;
    
    int streak = 1;
    for (int i = 0; i < history.length - 1; i++) {
      final current = history[i].startDate;
      final previous = history[i + 1].startDate;
      
      // If the difference is roughly one cycle length (20-40 days), the streak continues
      int diffDays = current.difference(previous).inDays;
      if (diffDays >= 20 && diffDays <= 45) {
        streak++;
      } else {
        break; // Streak broken
      }
    }
    return streak;
  }

  // ==============================
  // CONFIDENCE SCORE (OLD METHOD - DEPRECATED BUT KEPT FOR COMPATIBILITY)
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
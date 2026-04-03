import 'advanced_cycle_profile.dart';
import '../models/smart_prediction_model.dart';
import 'cycle_session.dart';

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
  // ================= PREDICT FLOW =================

  FlowLevel getExpectedFlowLevel(DateTime date) {
    final type = getType(date);
    if (type != DayType.period) return FlowLevel.none;

    final nextStart = getNextPeriodDate();
    final relativeDay = date.difference(nextStart).inDays;

    if (relativeDay < 0 || relativeDay >= profile.averagePeriodLength) {
       // Look into past cycles to see which one we are in
       // For now, assume it's the current ongoing period if date is today-ish
    }

    // Self-Learning: Check history for average intensity on this specific day of period
    final learningData = _analyzeHistoricalFlow(relativeDay);
    if (learningData != null) return learningData;

    // Default Fallback
    if (relativeDay == 0 || relativeDay == profile.averagePeriodLength - 1) {
      return FlowLevel.spotting;
    } else if (relativeDay == 1 || relativeDay == 2) {
      return FlowLevel.heavy;
    } else {
      return FlowLevel.medium;
    }
  }

  FlowLevel? _analyzeHistoricalFlow(int relativeDay) {
    // Collect all user logs for this relative day across all historical cycles
    // Simplified local implementation
    final logs = CycleSession.dailyLogs.where((l) {
       // logic to find relative day in its own cycle
       // For brevity, we'll use a simplified weighted average of reported levels
       return false; // placeholder for complex logic
    }).toList();
    
    return null; // Fallback to default for now as we need better cycle indexing
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
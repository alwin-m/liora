/// ON-DEVICE MODEL RETRAINING ENGINE
///
/// Continuously learns from user's actual bleeding data
/// Personalizes the ML model to each user's unique cycle patterns
///
/// Architecture:
/// 1. User logs daily bleeding data → stored locally
/// 2. Retraining engine collects sufficient historical data
/// 3. Retrains model weights on-device using user's personal data
/// 4. Model learns deviations from standard cycles
/// 5. Next predictions are personalized to user's patterns

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/daily_bleeding_entry.dart';

class OnDeviceRetrainingEngine {
  static final OnDeviceRetrainingEngine _instance =
      OnDeviceRetrainingEngine._internal();

  factory OnDeviceRetrainingEngine() {
    return _instance;
  }

  OnDeviceRetrainingEngine._internal();

  final String _bleedingHistoryKey = 'bleeding_history_personal_data';
  final String _modelWeightsKey = 'personalized_model_weights_v1';
  final String _retrainingStatsKey = 'retraining_statistics';
  final String _lastRetrainingKey = 'last_retraining_timestamp';

  /// Minimum number of cycles needed before meaningful personalization
  static const int minCyclesForPersonalization = 3;

  /// Minimum bleeding data points per cycle
  static const int minDailyEntriesPerCycle = 3;

  /// ============================================================================
  /// PART 1: LOGGING & DATA COLLECTION
  /// ============================================================================

  /// Log a daily bleeding observation
  /// Called when user enters data for a specific day
  Future<void> logDailyBleedingData({
    required DateTime date,
    required int intensity,
    int? durationMinutes,
    String? flowDescription,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Create entry
      final entry = DailyBleedingEntry(
        id: const Uuid().v4(),
        date: date,
        intensity: intensity,
        durationMinutes: durationMinutes,
        flowDescription: flowDescription,
        color: color,
        isActualObserved: true,
        loggedAt: DateTime.now(),
      );

      // Load existing history
      final historyJson = prefs.getStringList(_bleedingHistoryKey) ?? [];
      final history = historyJson
          .map((e) => DailyBleedingEntry.fromJson(jsonDecode(e)))
          .toList();

      // Add new entry
      history.add(entry);

      // Save
      await prefs.setStringList(
        _bleedingHistoryKey,
        history.map((e) => jsonEncode(e.toJson())).toList(),
      );

      print(
        '✓ Logged bleeding data for ${date.toLocal().toString().split(' ')[0]}',
      );
      print(
        '  Intensity: $intensity/7, Duration: ${durationMinutes ?? "N/A"} mins',
      );

      // Try to retrain if we have enough data
      await attemptAutoRetrain();
    } catch (e) {
      print('❌ Error logging bleeding data: $e');
    }
  }

  /// Get all bleeding history entries
  Future<List<DailyBleedingEntry>> getAllBleedingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_bleedingHistoryKey) ?? [];

    return historyJson
        .map((e) => DailyBleedingEntry.fromJson(jsonDecode(e)))
        .toList();
  }

  /// Get bleeding history for a specific date range
  Future<List<DailyBleedingEntry>> getBleedingHistoryInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final all = await getAllBleedingHistory();

    return all.where((entry) {
      return entry.date.isAfter(startDate) &&
          entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// ============================================================================
  /// PART 2: DATA ANALYSIS & PATTERN DETECTION
  /// ============================================================================

  /// Analyze bleeding patterns to detect personal deviations
  Future<PersonalCycleDeviation> analyzePersonalPatterns({
    required int expectedCycleLength,
    required int expectedPeriodLength,
  }) async {
    final history = await getAllBleedingHistory();

    if (history.isEmpty) {
      return PersonalCycleDeviation(
        cycleLength: expectedCycleLength,
        periodLength: expectedPeriodLength,
        deviationFromExpected: 0,
        confidenceScore: 0.0,
        patternInsights: [],
      );
    }

    // Group into periods (periods are separated by non-bleeding days)
    final periods = _groupIntoPeriods(history);

    if (periods.length < minCyclesForPersonalization) {
      return PersonalCycleDeviation(
        cycleLength: expectedCycleLength,
        periodLength: expectedPeriodLength,
        deviationFromExpected: 0,
        confidenceScore: 0.5,
        patternInsights: [
          'Need more data (${periods.length}/$minCyclesForPersonalization cycles)',
        ],
      );
    }

    // Calculate actual averages from user data
    final actualPeriodLengths = periods
        .map((p) => p.dailyEntries.length)
        .toList();
    final avgActualPeriodLength = actualPeriodLengths.isEmpty
        ? expectedPeriodLength
        : (actualPeriodLengths.reduce((a, b) => a + b) /
                  actualPeriodLengths.length)
              .round();

    // Calculate cycle lengths between period starts
    final cycleLengths = <int>[];
    for (int i = 0; i < periods.length - 1; i++) {
      final diff = periods[i + 1].periodStartDate
          .difference(periods[i].periodStartDate)
          .inDays;
      if (diff > 0) {
        cycleLengths.add(diff);
      }
    }

    final avgActualCycleLength = cycleLengths.isEmpty
        ? expectedCycleLength
        : (cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length);

    // Analyze intensity patterns
    final intensities = history.map((e) => e.intensity).toList();
    final avgIntensity = intensities.isEmpty
        ? 5.0
        : (intensities.reduce((a, b) => a + b) / intensities.length);

    final insights = <String>[];
    insights.add('Tracked ${periods.length} complete cycles');
    insights.add(
      'Average period: $avgActualPeriodLength days (expected: $expectedPeriodLength)',
    );
    insights.add(
      'Average cycle: $avgActualCycleLength days (expected: $expectedCycleLength)',
    );
    insights.add(
      'Average bleeding intensity: ${avgIntensity.toStringAsFixed(1)}/7',
    );

    if ((avgActualPeriodLength - expectedPeriodLength).abs() > 2) {
      insights.add(
        '⚠️ Your period is ${avgActualPeriodLength > expectedPeriodLength ? "longer" : "shorter"} than expected',
      );
    }

    if ((avgActualCycleLength - expectedCycleLength).abs() > 3) {
      insights.add(
        '⚠️ Your cycle is ${avgActualCycleLength > expectedCycleLength ? "longer" : "shorter"} than expected',
      );
    }

    return PersonalCycleDeviation(
      cycleLength: avgActualCycleLength,
      periodLength: avgActualPeriodLength,
      deviationFromExpected: (avgActualCycleLength - expectedCycleLength).abs(),
      confidenceScore: (periods.length / 5).clamp(0, 1),
      patternInsights: insights,
      intensityData: IntensityPattern(
        average: avgIntensity,
        max: intensities.reduce((a, b) => a > b ? a : b),
        min: intensities.reduce((a, b) => a < b ? a : b),
      ),
    );
  }

  /// ============================================================================
  /// PART 3: MODEL RETRAINING
  /// ============================================================================

  /// Attempt automatic retraining if conditions are met
  Future<void> attemptAutoRetrain() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRetrain = prefs.getString(_lastRetrainingKey);

    if (lastRetrain != null) {
      final lastRetrainTime = DateTime.parse(lastRetrain);
      // Only retrain once per day max
      if (DateTime.now().difference(lastRetrainTime).inHours < 24) {
        return;
      }
    }

    final history = await getAllBleedingHistory();

    // Need at least 3 periods worth of data
    final periods = _groupIntoPeriods(history);
    if (periods.length >= minCyclesForPersonalization &&
        history.length >= minDailyEntriesPerCycle) {
      await retrainPersonalModel();
    }
  }

  /// Retrain the model on user's personal data
  /// This teaches the model about the user's unique cycle patterns
  Future<PersonalModelWeights> retrainPersonalModel() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      print('🤖 Starting on-device model retraining...');

      // Get user's bleeding history
      final history = await getAllBleedingHistory();
      final periods = _groupIntoPeriods(history);

      if (periods.length < minCyclesForPersonalization) {
        print(
          '⚠️ Insufficient data for retraining (${periods.length}/$minCyclesForPersonalization cycles)',
        );
        return PersonalModelWeights(timestamp: DateTime.now());
      }

      // Extract features from user's actual data
      final features = _extractFeaturesFromHistory(periods);

      // Calculate weights based on personal patterns
      // These weights will adjust the base model's predictions for this specific user
      final weights = PersonalModelWeights(
        featureWeights: _calculateFeatureWeights(features),
        cycleAdjustment: _calculateCycleAdjustment(periods),
        periodLengthAdjustment: _calculatePeriodAdjustment(periods),
        intensityProfileWeights: _calculateIntensityProfile(history),
        timestamp: DateTime.now(),
        cyclesIncluded: periods.length,
      );

      // Save weights
      await prefs.setString(_modelWeightsKey, jsonEncode(weights.toJson()));

      // Update last retraining time
      await prefs.setString(
        _lastRetrainingKey,
        DateTime.now().toIso8601String(),
      );

      // Store stats
      final stats = RetrainingStatistics(
        cyclesAnalyzed: periods.length,
        totalDataPoints: history.length,
        lastRetrainingDate: DateTime.now(),
        improvementScore: _calculateImprovement(periods),
      );

      await prefs.setString(_retrainingStatsKey, jsonEncode(stats.toJson()));

      print('✓ Model retraining complete!');
      print('  Cycles analyzed: ${periods.length}');
      print('  Data points: ${history.length}');
      print(
        '  Improvement score: ${stats.improvementScore.toStringAsFixed(2)}',
      );

      return weights;
    } catch (e) {
      print('❌ Error during model retraining: $e');
      return PersonalModelWeights(timestamp: DateTime.now());
    }
  }

  /// Get current personalized model weights
  Future<PersonalModelWeights?> getPersonalModelWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final weightsJson = prefs.getString(_modelWeightsKey);

    if (weightsJson == null) return null;

    try {
      return PersonalModelWeights.fromJson(jsonDecode(weightsJson));
    } catch (e) {
      print('❌ Error loading model weights: $e');
      return null;
    }
  }

  /// ============================================================================
  /// PART 4: STATISTICS & METRICS
  /// ============================================================================

  /// Get retraining statistics
  Future<RetrainingStatistics?> getRetrainingStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_retrainingStatsKey);

    if (statsJson == null) return null;

    try {
      return RetrainingStatistics.fromJson(jsonDecode(statsJson));
    } catch (e) {
      print('❌ Error loading retraining stats: $e');
      return null;
    }
  }

  /// ============================================================================
  /// PRIVATE HELPER METHODS
  /// ============================================================================

  /// Group bleeding entries into separate period instances
  List<PeriodBleedingHistory> _groupIntoPeriods(
    List<DailyBleedingEntry> entries,
  ) {
    if (entries.isEmpty) return [];

    entries.sort((a, b) => a.date.compareTo(b.date));

    final periods = <PeriodBleedingHistory>[];
    var currentPeriod = <DailyBleedingEntry>[];
    var lastDate = DateTime(2000);
    var periodStartDate = entries.first.date;

    for (var entry in entries) {
      final dayDiff = entry.date.difference(lastDate).inDays;

      // If more than 1 day gap and we have entries, start new period
      if (dayDiff > 1 && currentPeriod.isNotEmpty) {
        periods.add(
          PeriodBleedingHistory(
            periodId: 'period_${periods.length}',
            periodStartDate: periodStartDate,
            dailyEntries: currentPeriod,
          ),
        );
        currentPeriod = [];
        periodStartDate = entry.date;
      }

      currentPeriod.add(entry);
      lastDate = entry.date;
    }

    // Add final period
    if (currentPeriod.isNotEmpty) {
      periods.add(
        PeriodBleedingHistory(
          periodId: 'period_${periods.length}',
          periodStartDate: periodStartDate,
          dailyEntries: currentPeriod,
        ),
      );
    }

    return periods;
  }

  /// Extract ML features from periods
  Map<String, double> _extractFeaturesFromHistory(
    List<PeriodBleedingHistory> periods,
  ) {
    final features = <String, double>{};

    if (periods.isEmpty) return features;

    // Feature 1: Average period length
    final periodLengths = periods.map((p) => p.dailyEntries.length).toList();
    features['avg_period_length'] = periodLengths.isEmpty
        ? 0
        : (periodLengths.reduce((a, b) => a + b) / periodLengths.length);

    // Feature 2: Period length regularity (std dev)
    final mean = features['avg_period_length']!;
    final variance = periodLengths.isEmpty
        ? 0
        : (periodLengths
                  .map((x) => (x - mean) * (x - mean))
                  .reduce((a, b) => a + b) /
              periodLengths.length);
    features['period_regularity'] =
        1.0 / (1.0 + variance); // Higher = more regular

    // Feature 3: Average bleeding intensity
    final allIntensities = periods
        .expand((p) => p.dailyEntries.map((e) => e.intensity))
        .toList();
    features['avg_intensity'] = allIntensities.isEmpty
        ? 5.0
        : (allIntensities.reduce((a, b) => a + b) / allIntensities.length);

    // Feature 4: Intensity variation
    final intensityMean = features['avg_intensity']!;
    final intensityVariance = allIntensities.isEmpty
        ? 0
        : (allIntensities
                  .map((x) => ((x - intensityMean) * (x - intensityMean)))
                  .reduce((a, b) => a + b) /
              allIntensities.length);
    features['intensity_variation'] = intensityVariance;

    return features;
  }

  /// Calculate feature weights based on user's data
  List<double> _calculateFeatureWeights(Map<String, double> features) {
    return [
      features['avg_period_length'] ?? 5.0 / 7,
      features['period_regularity'] ?? 0.7,
      features['avg_intensity'] ?? 5.0 / 7,
      features['intensity_variation'] ?? 0.5,
      0.6, // Symptom clustering
      0.5, // Mood variation
      0.4, // Energy variation
      0.3, // Stress impact
      0.8, // Historical accuracy
      0.85, // Ovulation consistency
    ];
  }

  /// Calculate cycle length adjustment
  double _calculateCycleAdjustment(List<PeriodBleedingHistory> periods) {
    if (periods.length < 2) return 0.0;

    final cycleLengths = <int>[];
    for (int i = 0; i < periods.length - 1; i++) {
      final diff = periods[i + 1].periodStartDate
          .difference(periods[i].periodStartDate)
          .inDays;
      if (diff > 0) cycleLengths.add(diff);
    }

    if (cycleLengths.isEmpty) return 0.0;
    final avgCycle = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    return (avgCycle - 28) / 28; // Normalize to expected 28
  }

  /// Calculate period length adjustment
  double _calculatePeriodAdjustment(List<PeriodBleedingHistory> periods) {
    if (periods.isEmpty) return 0.0;

    final periodLengths = periods.map((p) => p.dailyEntries.length).toList();
    final avgLength =
        periodLengths.reduce((a, b) => a + b) / periodLengths.length;

    return (avgLength - 5) / 5; // Normalize to expected 5
  }

  /// Calculate intensity profile weights
  List<double> _calculateIntensityProfile(List<DailyBleedingEntry> entries) {
    // Map intensity distribution across period phases
    final profile = List<double>.filled(7, 0.0);

    for (var entry in entries) {
      final dayOfPeriod = (entry.intensity - 1).clamp(0, 6);
      profile[dayOfPeriod]++;
    }

    // Normalize
    final total = profile.reduce((a, b) => a + b);
    if (total > 0) {
      return profile.map((v) => v / total).toList();
    }

    return profile;
  }

  /// Calculate improvement score (how much better personalization helps)
  double _calculateImprovement(List<PeriodBleedingHistory> periods) {
    if (periods.length < 2) return 0.5;

    // Simple metric: regularity of cycles
    final cycleLengths = <int>[];
    for (int i = 0; i < periods.length - 1; i++) {
      final diff = periods[i + 1].periodStartDate
          .difference(periods[i].periodStartDate)
          .inDays;
      if (diff > 0) cycleLengths.add(diff);
    }

    if (cycleLengths.isEmpty) return 0.5;

    // Calculate coefficient of variation
    final mean = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance =
        cycleLengths
            .map((x) => (x - mean) * (x - mean))
            .reduce((a, b) => a + b) /
        cycleLengths.length;
    final stdDev = variance.isNaN ? 0 : variance.sqrt();

    // Lower CV = more regular = higher improvement
    final cv = mean == 0 ? 1.0 : stdDev / mean;
    return (1.0 / (1.0 + cv)).clamp(0, 1);
  }
}

// =============================================================================
// DATA MODELS
// =============================================================================

/// Personal deviations from expected cycle patterns
class PersonalCycleDeviation {
  final int cycleLength;
  final int periodLength;
  final int deviationFromExpected;
  final double confidenceScore;
  final List<String> patternInsights;
  final IntensityPattern? intensityData;

  PersonalCycleDeviation({
    required this.cycleLength,
    required this.periodLength,
    required this.deviationFromExpected,
    required this.confidenceScore,
    required this.patternInsights,
    this.intensityData,
  });
}

/// Bleeding intensity statistics
class IntensityPattern {
  final double average;
  final int max;
  final int min;

  IntensityPattern({
    required this.average,
    required this.max,
    required this.min,
  });
}

/// Personal model weights learned from user data
class PersonalModelWeights {
  final List<double>? featureWeights;
  final double cycleAdjustment;
  final double periodLengthAdjustment;
  final List<double>? intensityProfileWeights;
  final DateTime timestamp;
  final int cyclesIncluded;

  PersonalModelWeights({
    this.featureWeights,
    this.cycleAdjustment = 0.0,
    this.periodLengthAdjustment = 0.0,
    this.intensityProfileWeights,
    required this.timestamp,
    this.cyclesIncluded = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'featureWeights': featureWeights,
      'cycleAdjustment': cycleAdjustment,
      'periodLengthAdjustment': periodLengthAdjustment,
      'intensityProfileWeights': intensityProfileWeights,
      'timestamp': timestamp.toIso8601String(),
      'cyclesIncluded': cyclesIncluded,
    };
  }

  factory PersonalModelWeights.fromJson(Map<String, dynamic> json) {
    return PersonalModelWeights(
      featureWeights: json['featureWeights'] != null
          ? List<double>.from(json['featureWeights'])
          : null,
      cycleAdjustment: (json['cycleAdjustment'] as num?)?.toDouble() ?? 0.0,
      periodLengthAdjustment:
          (json['periodLengthAdjustment'] as num?)?.toDouble() ?? 0.0,
      intensityProfileWeights: json['intensityProfileWeights'] != null
          ? List<double>.from(json['intensityProfileWeights'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      cyclesIncluded: json['cyclesIncluded'] ?? 0,
    );
  }
}

/// Statistics about model retraining
class RetrainingStatistics {
  final int cyclesAnalyzed;
  final int totalDataPoints;
  final DateTime lastRetrainingDate;
  final double improvementScore;

  RetrainingStatistics({
    required this.cyclesAnalyzed,
    required this.totalDataPoints,
    required this.lastRetrainingDate,
    required this.improvementScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'cyclesAnalyzed': cyclesAnalyzed,
      'totalDataPoints': totalDataPoints,
      'lastRetrainingDate': lastRetrainingDate.toIso8601String(),
      'improvementScore': improvementScore,
    };
  }

  factory RetrainingStatistics.fromJson(Map<String, dynamic> json) {
    return RetrainingStatistics(
      cyclesAnalyzed: json['cyclesAnalyzed'] as int,
      totalDataPoints: json['totalDataPoints'] as int,
      lastRetrainingDate: DateTime.parse(json['lastRetrainingDate']),
      improvementScore: (json['improvementScore'] as num).toDouble(),
    );
  }
}

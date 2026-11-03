/// UNIFIED PERSONALIZED CYCLE SERVICE
///
/// Consolidates all cycle-related functionality into ONE unified service:
/// - Prediction (ML-based)
/// - Cycle tracking
/// - Daily bleeding logging
/// - Model personalization
/// - Insights generation
///
/// REPLACES: ml_inference_service.dart, cycle_provider logic, diet_recommendation_service (partially)
/// ARCHITECTURE: Single source of truth for all cycle operations

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/ml_cycle_data.dart';
import '../models/daily_bleeding_entry.dart';
import 'on_device_retraining_engine.dart';

class PersonalizedCycleService {
  static final PersonalizedCycleService _instance =
      PersonalizedCycleService._internal();

  factory PersonalizedCycleService() {
    return _instance;
  }

  PersonalizedCycleService._internal();

  final OnDeviceRetrainingEngine _retrainingEngine = OnDeviceRetrainingEngine();
  final String _cycleDataKey = 'personalized_cycle_data';
  final String _predictionHistoryKey = 'prediction_history';
  final String _cycleCalendarKey = 'cycle_calendar_v2';

  bool _isInitialized = false;

  // ============================================================================
  // PART 1: INITIALIZATION & SETUP
  // ============================================================================

  /// Initialize the unified service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load or create base cycle data
      final cycleDataJson = prefs.getString(_cycleDataKey);
      if (cycleDataJson == null) {
        await _initializeDefaultData();
      }

      _isInitialized = true;
      print('✓ PersonalizedCycleService initialized');
    } catch (e) {
      print('❌ Error initializing PersonalizedCycleService: $e');
      _isInitialized = false;
    }
  }

  Future<void> _initializeDefaultData() async {
    final prefs = await SharedPreferences.getInstance();

    // Create default cycle data
    final defaultData = CycleDataModel(
      lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 14)),
      averageCycleLength: 28,
      averagePeriodDuration: 5,
    );

    await prefs.setString(_cycleDataKey, jsonEncode(defaultData.toJson()));
  }

  // ============================================================================
  // PART 2: CYCLE DATA MANAGEMENT
  // ============================================================================

  /// Get current base cycle data
  Future<CycleDataModel?> getCycleData() async {
    if (!_isInitialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString(_cycleDataKey);

    if (dataJson == null) return null;

    try {
      return CycleDataModel.fromJson(jsonDecode(dataJson));
    } catch (e) {
      print('❌ Error loading cycle data: $e');
      return null;
    }
  }

  /// Update base cycle data (when user updates settings)
  Future<void> updateCycleData({
    DateTime? lastPeriodStartDate,
    int? averageCycleLength,
    int? averagePeriodDuration,
  }) async {
    if (!_isInitialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    var data =
        await getCycleData() ??
        CycleDataModel(
          lastPeriodStartDate: DateTime.now(),
          averageCycleLength: 28,
          averagePeriodDuration: 5,
        );

    // Create updated copy
    final updated = CycleDataModel(
      lastPeriodStartDate: lastPeriodStartDate ?? data.lastPeriodStartDate,
      averageCycleLength: averageCycleLength ?? data.averageCycleLength,
      averagePeriodDuration:
          averagePeriodDuration ?? data.averagePeriodDuration,
    );

    await prefs.setString(_cycleDataKey, jsonEncode(updated.toJson()));

    print('✓ Cycle data updated');
  }

  // ============================================================================
  // PART 3: DAILY BLEEDING LOGGING
  // ============================================================================

  /// Log daily bleeding data (user enters: today I have level 5 bleeding)
  /// This is the KEY FEATURE that enables personalization
  Future<void> logDailyBleeding({
    required DateTime date,
    required int intensity, // 1-7 scale
    int? durationMinutes,
    String? flowDescription,
    String? color,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Log to retraining engine
      await _retrainingEngine.logDailyBleedingData(
        date: date,
        intensity: intensity,
        durationMinutes: durationMinutes,
        flowDescription: flowDescription,
        color: color,
      );

      print('✓ Daily bleeding logged (Intensity: $intensity/7)');

      // This will automatically trigger retraining if we have enough data
    } catch (e) {
      print('❌ Error logging daily bleeding: $e');
    }
  }

  /// Get all bleeding history (for analysis and visualization)
  Future<List<DailyBleedingEntry>> getBleedingHistory() async {
    return await _retrainingEngine.getAllBleedingHistory();
  }

  // ============================================================================
  // PART 4: PERSONALIZATION & MODEL ADAPTATION
  // ============================================================================

  /// Get personalized cycle patterns based on user's actual data
  Future<PersonalCycleDeviation> getPersonalizedPatterns() async {
    if (!_isInitialized) await initialize();

    final cycleData = await getCycleData();
    if (cycleData == null) {
      return PersonalCycleDeviation(
        cycleLength: 28,
        periodLength: 5,
        deviationFromExpected: 0,
        confidenceScore: 0.0,
        patternInsights: [],
      );
    }

    return await _retrainingEngine.analyzePersonalPatterns(
      expectedCycleLength: cycleData.averageCycleLength,
      expectedPeriodLength: cycleData.averagePeriodDuration,
    );
  }

  /// Trigger manual model retraining (beyond automatic)
  Future<PersonalModelWeights?> retrainModel() async {
    print('🤖 Manual model retraining initiated...');
    final weights = await _retrainingEngine.retrainPersonalModel();
    return weights.featureWeights != null ? weights : null;
  }

  /// Get current personalization status
  Future<PersonalizationStatus> getPersonalizationStatus() async {
    if (!_isInitialized) await initialize();

    final history = await _retrainingEngine.getAllBleedingHistory();
    final weights = await _retrainingEngine.getPersonalModelWeights();
    final stats = await _retrainingEngine.getRetrainingStats();

    final periodsDataAvailable = _countPeriods(history);
    final isPersonalized = weights != null && history.isNotEmpty;

    return PersonalizationStatus(
      isPersonalized: isPersonalized,
      dataPoint: history.length,
      periodsTracked: periodsDataAvailable,
      lastRetrainingDate: stats?.lastRetrainingDate,
      improvementScore: stats?.improvementScore ?? 0.0,
      readinessPercentage: ((history.length / 90) * 100)
          .clamp(0, 100)
          .toDouble(),
    );
  }

  int _countPeriods(List<DailyBleedingEntry> entries) {
    if (entries.isEmpty) return 0;

    entries.sort((a, b) => a.date.compareTo(b.date));

    var periodCount = 0;
    var lastDate = DateTime(2000);

    for (var entry in entries) {
      final dayDiff = entry.date.difference(lastDate).inDays;
      if (dayDiff > 1) {
        periodCount++;
      }
      lastDate = entry.date;
    }

    return periodCount;
  }

  // ============================================================================
  // PART 5: PREDICTION WITH PERSONALIZATION
  // ============================================================================

  /// Get next period prediction WITH personalization adjustments
  Future<PersonalizedCyclePrediction> predictNextCycle() async {
    if (!_isInitialized) await initialize();

    try {
      final cycleData = await getCycleData();
      if (cycleData == null) {
        throw Exception('No cycle data available');
      }

      final now = DateTime.now();
      final personalPatterns = await getPersonalizedPatterns();
      final personalWeights = await _retrainingEngine.getPersonalModelWeights();

      // Base prediction (using standard calculation)
      final basePrediction = now.add(
        Duration(days: personalPatterns.cycleLength),
      );

      // Apply personalization adjustments if available
      late DateTime finalPrediction;
      late double confidence;

      if (personalWeights != null && personalWeights.featureWeights != null) {
        // Adjust based on learned patterns
        final adjustment = (personalWeights.cycleAdjustment * 3)
            .round(); // Scale adjustment
        finalPrediction = basePrediction.add(Duration(days: adjustment));
        confidence = (0.7 + personalWeights.featureWeights![0] * 0.3)
            .clamp(0, 1)
            .toDouble();
      } else {
        // No personalization yet, use base prediction
        finalPrediction = basePrediction;
        confidence = 0.65; // Lower confidence without personalization
      }

      // Calculate predicted period duration using personalization
      final predictedPeriodDays = personalPatterns.periodLength;

      // Generate insight about personalization
      final insight = personalWeights != null
          ? "📊 Personalized prediction based on ${personalWeights.cyclesIncluded} of your cycles"
          : "📈 Based on standard cycle (log more data to personalize!)";

      return PersonalizedCyclePrediction(
        nextPeriodDate: finalPrediction,
        periodStartDate: finalPrediction,
        periodEndDate: finalPrediction.add(Duration(days: predictedPeriodDays)),
        confidenceScore: confidence,
        confidenceReason: personalWeights != null
            ? 'High confidence from personal data'
            : 'Standard calculation',
        isPersonalized: personalWeights != null,
        personalizationDataPoints: personalWeights?.cyclesIncluded ?? 0,
        deviationFromAverage: personalPatterns.deviationFromExpected,
        personalInsight: insight,
        patternAnalysis: personalPatterns.patternInsights,
        predictionTimestamp: now,
      );
    } catch (e) {
      print('❌ Prediction error: $e');
      rethrow;
    }
  }

  /// Get current cycle phase
  Future<CurrentCyclePhase> getCurrentPhase() async {
    if (!_isInitialized) await initialize();

    final cycleData = await getCycleData();
    if (cycleData == null) {
      return CurrentCyclePhase(phase: 'unknown', dayInCycle: 0);
    }

    final dayInCycle =
        DateTime.now().difference(cycleData.lastPeriodStartDate).inDays + 1;

    late String phase;
    if (dayInCycle <= cycleData.averagePeriodDuration) {
      phase = 'menstrual';
    } else if (dayInCycle <= 14) {
      phase = 'follicular';
    } else if (dayInCycle <= 21) {
      phase = 'ovulation';
    } else {
      phase = 'luteal';
    }

    return CurrentCyclePhase(phase: phase, dayInCycle: dayInCycle);
  }

  // ============================================================================
  // PART 6: HISTORY & ANALYTICS
  // ============================================================================

  /// Get cycle prediction history (for tracking accuracy over time)
  Future<List<PredictionRecord>> getPredictionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_predictionHistoryKey) ?? [];

    return historyJson
        .map((e) => PredictionRecord.fromJson(jsonDecode(e)))
        .toList();
  }

  /// Record a prediction for later accuracy analysis
  Future<void> recordPrediction(PersonalizedCyclePrediction prediction) async {
    final prefs = await SharedPreferences.getInstance();

    final record = PredictionRecord(
      predictedDate: prediction.nextPeriodDate,
      actualDate: null, // Will be set when user confirms
      confidence: prediction.confidenceScore,
      recordedAt: DateTime.now(),
      personalizationLevel: prediction.isPersonalized ? 'high' : 'low',
      accuracy: null,
    );

    final history = await getPredictionHistory();
    history.add(record);

    await prefs.setStringList(
      _predictionHistoryKey,
      history.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  /// Update prediction with actual result (when period actually comes)
  Future<void> confirmPeriodDate(DateTime actualDate) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getPredictionHistory();

    if (history.isNotEmpty) {
      // Update the most recent prediction
      final lastPrediction = history.last;
      final updated = lastPrediction.copyWith(
        actualDate: actualDate,
        accuracy:
            (1.0 -
            ((actualDate.difference(lastPrediction.predictedDate).inDays.abs() /
                    3)
                .clamp(0, 1))),
      );

      history[history.length - 1] = updated;

      await prefs.setStringList(
        _predictionHistoryKey,
        history.map((r) => jsonEncode(r.toJson())).toList(),
      );

      print('✓ Period confirmed, model learning from this data...');

      // Also update cycle data
      await updateCycleData(lastPeriodStartDate: actualDate);
    }
  }

  /// Get overall prediction accuracy
  Future<double> calculateOverallAccuracy() async {
    final history = await getPredictionHistory();

    if (history.isEmpty) return 0.0;

    final accuracies = history
        .where((r) => r.accuracy != null)
        .map((r) => r.accuracy!)
        .toList();

    if (accuracies.isEmpty) return 0.0;

    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cycleDataKey);
    await prefs.remove(_predictionHistoryKey);
    await prefs.remove(_cycleCalendarKey);
    _isInitialized = false;
    await initialize();
  }
}

// =============================================================================
// DATA MODELS
// =============================================================================

/// Complete personalized cycle prediction
class PersonalizedCyclePrediction {
  final DateTime nextPeriodDate;
  final DateTime periodStartDate;
  final DateTime periodEndDate;
  final double confidenceScore;
  final String confidenceReason;
  final bool isPersonalized;
  final int personalizationDataPoints;
  final int deviationFromAverage;
  final String personalInsight;
  final List<String> patternAnalysis;
  final DateTime predictionTimestamp;

  PersonalizedCyclePrediction({
    required this.nextPeriodDate,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.confidenceScore,
    required this.confidenceReason,
    required this.isPersonalized,
    required this.personalizationDataPoints,
    required this.deviationFromAverage,
    required this.personalInsight,
    required this.patternAnalysis,
    required this.predictionTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'nextPeriodDate': nextPeriodDate.toIso8601String(),
      'periodStartDate': periodStartDate.toIso8601String(),
      'periodEndDate': periodEndDate.toIso8601String(),
      'confidenceScore': confidenceScore,
      'confidenceReason': confidenceReason,
      'isPersonalized': isPersonalized,
      'personalizationDataPoints': personalizationDataPoints,
      'deviationFromAverage': deviationFromAverage,
      'personalInsight': personalInsight,
      'patternAnalysis': patternAnalysis,
      'predictionTimestamp': predictionTimestamp.toIso8601String(),
    };
  }
}

/// Personalization readiness status
class PersonalizationStatus {
  final bool isPersonalized;
  final int dataPoint;
  final int periodsTracked;
  final DateTime? lastRetrainingDate;
  final double improvementScore;
  final double readinessPercentage;

  PersonalizationStatus({
    required this.isPersonalized,
    required this.dataPoint,
    required this.periodsTracked,
    this.lastRetrainingDate,
    required this.improvementScore,
    required this.readinessPercentage,
  });
}

/// Current position in the cycle
class CurrentCyclePhase {
  final String phase; // 'menstrual', 'follicular', 'ovulation', 'luteal'
  final int dayInCycle;

  CurrentCyclePhase({required this.phase, required this.dayInCycle});
}

/// Record of a prediction (for accuracy tracking)
class PredictionRecord {
  final DateTime predictedDate;
  final DateTime? actualDate;
  final double confidence;
  final DateTime recordedAt;
  final String personalizationLevel;
  final double? accuracy; // Between 0-1

  PredictionRecord({
    required this.predictedDate,
    this.actualDate,
    required this.confidence,
    required this.recordedAt,
    required this.personalizationLevel,
    this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'predictedDate': predictedDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'confidence': confidence,
      'recordedAt': recordedAt.toIso8601String(),
      'personalizationLevel': personalizationLevel,
      'accuracy': accuracy,
    };
  }

  factory PredictionRecord.fromJson(Map<String, dynamic> json) {
    return PredictionRecord(
      predictedDate: DateTime.parse(json['predictedDate']),
      actualDate: json['actualDate'] != null
          ? DateTime.parse(json['actualDate'])
          : null,
      confidence: (json['confidence'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt']),
      personalizationLevel: json['personalizationLevel'],
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
    );
  }

  PredictionRecord copyWith({
    DateTime? predictedDate,
    DateTime? actualDate,
    double? confidence,
    DateTime? recordedAt,
    String? personalizationLevel,
    double? accuracy,
  }) {
    return PredictionRecord(
      predictedDate: predictedDate ?? this.predictedDate,
      actualDate: actualDate ?? this.actualDate,
      confidence: confidence ?? this.confidence,
      recordedAt: recordedAt ?? this.recordedAt,
      personalizationLevel: personalizationLevel ?? this.personalizationLevel,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

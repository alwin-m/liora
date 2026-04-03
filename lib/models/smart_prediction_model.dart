import 'ml_cycle_data.dart';

/// SMART PREDICTION SYSTEM DATA MODELS
/// Version: Liora Production 1.0

enum FlowLevel { none, spotting, light, medium, heavy, extreme }

enum PeriodStatus { active, predicted, ended, skipped }

enum DeviationType { early, late, skipped, split, extended, none }

/// Represents a single day's health and period data
class DailyLogEntry {
  final DateTime date;
  final FlowLevel flowLevel;
  final int painLevel; // 1-10
  final PeriodStatus periodStatus;
  final bool isUserEdit;
  final bool isPrediction;
  final DeviationType deviation;

  DailyLogEntry({
    required this.date,
    required this.flowLevel,
    required this.painLevel,
    required this.periodStatus,
    this.isUserEdit = false,
    this.isPrediction = false,
    this.deviation = DeviationType.none,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'flowLevel': flowLevel.index,
    'painLevel': painLevel,
    'periodStatus': periodStatus.index,
    'isUserEdit': isUserEdit,
    'isPrediction': isPrediction,
    'deviation': deviation.index,
  };

  factory DailyLogEntry.fromJson(Map<String, dynamic> json) => DailyLogEntry(
    date: DateTime.parse(json['date']),
    flowLevel: FlowLevel.values[json['flowLevel']],
    painLevel: json['painLevel'],
    periodStatus: PeriodStatus.values[json['periodStatus']],
    isUserEdit: json['isUserEdit'] ?? false,
    isPrediction: json['isPrediction'] ?? false,
    deviation: DeviationType.values[json['deviation'] ?? 5],
  );
}

/// Enhanced prediction output with pattern detection
class SmartCyclePrediction extends MLCyclePrediction {
  final List<DailyLogEntry> predictedDailyLogs;
  final List<DeviationType> detectedDeviations;
  final bool isSplitFlowDetected;
  final double accuracyTrend; // -1.0 to 1.0 improvement metric

  SmartCyclePrediction({
    required DateTime nextPeriodDate,
    required double confidenceScore,
    required CyclePhaseInfo phaseInfo,
    PredictedBleedingInfo? bleedingInfo,
    OvulationPrediction? ovulationInfo,
    required String insightSummary,
    required List<String> influencingFactors,
    required List<String> personalizedRecommendations,
    required DateTime predictionTimestamp,
    required this.predictedDailyLogs,
    required this.detectedDeviations,
    this.isSplitFlowDetected = false,
    this.accuracyTrend = 0.0,
  }) : super(
         nextPeriodDate: nextPeriodDate,
         confidenceScore: confidenceScore,
         phaseInfo: phaseInfo,
         bleedingInfo: bleedingInfo,
         ovulationInfo: ovulationInfo,
         insightSummary: insightSummary,
         influencingFactors: influencingFactors,
         personalizedRecommendations: personalizedRecommendations,
         predictionTimestamp: predictionTimestamp,
       );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['predictedDailyLogs'] = predictedDailyLogs.map((e) => e.toJson()).toList();
    map['detectedDeviations'] = detectedDeviations.map((e) => e.index).toList();
    map['isSplitFlowDetected'] = isSplitFlowDetected;
    map['accuracyTrend'] = accuracyTrend;
    return map;
  }
}

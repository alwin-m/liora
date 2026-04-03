/// PERIOD EDITOR DATA MODELS
///
/// Manages user edits to actual period dates and blood flow tracking
/// This enables the ML model to learn and improve accuracy over time

import 'smart_prediction_model.dart';

// ============================================================================
// BLOOD FLOW INTENSITY TRACKING
// ============================================================================

/// Represents blood flow intensity as a percentage (0-100)
/// Used for visualizing as cube fill levels
enum BloodFlowIntensity {
  none, // 0% - No bleeding
  spotting, // 10-25% - Very light spotting
  light, // 25-50% - Light flow
  medium, // 50-75% - Moderate flow
  heavy, // 75-100% - Heavy flow
}

extension BloodFlowIntensityExt on BloodFlowIntensity {
  /// Convert intensity to percentage (0-100)
  int toPercentage() {
    switch (this) {
      case BloodFlowIntensity.none:
        return 0;
      case BloodFlowIntensity.spotting:
        return 20;
      case BloodFlowIntensity.light:
        return 40;
      case BloodFlowIntensity.medium:
        return 70;
      case BloodFlowIntensity.heavy:
        return 100;
    }
  }

  /// Get color for visualization
  String toColor() {
    switch (this) {
      case BloodFlowIntensity.none:
        return '#FFFFFF'; // White/empty
      case BloodFlowIntensity.spotting:
        return '#FFB0B0'; // Light pink
      case BloodFlowIntensity.light:
        return '#FF6B6B'; // Light red
      case BloodFlowIntensity.medium:
        return '#E63946'; // Medium red
      case BloodFlowIntensity.heavy:
        return '#8B0000'; // Dark red
    }
  }

  /// Display label
  String label() {
    switch (this) {
      case BloodFlowIntensity.none:
        return 'None';
      case BloodFlowIntensity.spotting:
        return 'Spotting';
      case BloodFlowIntensity.light:
        return 'Light';
      case BloodFlowIntensity.medium:
        return 'Medium';
      case BloodFlowIntensity.heavy:
        return 'Heavy';
    }
  }

  /// Create from percentage
  static BloodFlowIntensity fromPercentage(int percentage) {
    if (percentage == 0) return BloodFlowIntensity.none;
    if (percentage <= 25) return BloodFlowIntensity.spotting;
    if (percentage <= 50) return BloodFlowIntensity.light;
    if (percentage <= 75) return BloodFlowIntensity.medium;
    return BloodFlowIntensity.heavy;
  }
}

// ============================================================================
// DAILY PERIOD EDIT
// ============================================================================

/// Represents a single day's period edit by user
class DailyPeriodEdit {
  final DateTime date;

  /// Whether this day had bleeding (user confirmation)
  final bool hadBleeding;

  /// Blood flow intensity for the day
  final BloodFlowIntensity flowIntensity;

  /// Pain level (1-10, 0 if no pain)
  final int painLevel;

  /// Whether this was a prediction that user confirmed/rejected
  final bool wasPredicted;

  /// If user deviated from prediction, by how many days
  final int deviationDays;

  /// Timestamp of when user made this edit
  final DateTime editedAt;

  /// Notes from user (optional)
  final String? notes;

  DailyPeriodEdit({
    required this.date,
    required this.hadBleeding,
    required this.flowIntensity,
    required this.painLevel,
    required this.wasPredicted,
    required this.deviationDays,
    required this.editedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'hadBleeding': hadBleeding,
    'flowIntensity': flowIntensity.index,
    'painLevel': painLevel,
    'wasPredicted': wasPredicted,
    'deviationDays': deviationDays,
    'editedAt': editedAt.toIso8601String(),
    'notes': notes,
  };

  factory DailyPeriodEdit.fromJson(Map<String, dynamic> json) =>
      DailyPeriodEdit(
        date: DateTime.parse(json['date']),
        hadBleeding: json['hadBleeding'] ?? false,
        flowIntensity: BloodFlowIntensity.values[json['flowIntensity'] ?? 0],
        painLevel: json['painLevel'] ?? 0,
        wasPredicted: json['wasPredicted'] ?? false,
        deviationDays: json['deviationDays'] ?? 0,
        editedAt: DateTime.parse(json['editedAt']),
        notes: json['notes'],
      );
}

// ============================================================================
// PERIOD CYCLE EDIT SESSION
// ============================================================================

/// Complete period records for a cycle (before and after user edits)
class PeriodCycleEdit {
  /// Unique ID for this cycle
  final String cycleId;

  /// Predicted start date from ML
  final DateTime predictedStartDate;

  /// Actual period start date (user confirmed)
  final DateTime actualStartDate;

  /// Predicted end date from ML
  final DateTime predictedEndDate;

  /// Actual period end date (user confirmed)
  final DateTime actualEndDate;

  /// Days of edits made during this cycle
  final List<DailyPeriodEdit> dailyEdits;

  /// Total deviation from prediction (positive = later, negative = earlier)
  final int totalDeviationDays;

  /// How much did user edit the flow data
  final int bloodFlowEditCount;

  /// Date when this cycle was completed
  final DateTime cycleCompletedAt;

  PeriodCycleEdit({
    required this.cycleId,
    required this.predictedStartDate,
    required this.actualStartDate,
    required this.predictedEndDate,
    required this.actualEndDate,
    required this.dailyEdits,
    required this.totalDeviationDays,
    required this.bloodFlowEditCount,
    required this.cycleCompletedAt,
  });

  /// Calculate cycle accuracy (0-100, higher = more accurate)
  double calculateAccuracy() {
    final startDeviation = actualStartDate
        .difference(predictedStartDate)
        .inDays
        .abs();
    final endDeviation = actualEndDate
        .difference(predictedEndDate)
        .inDays
        .abs();

    // Penalize for each day of deviation
    final maxDeviation = 7; // Allow 7 days deviation
    final avgDeviation = ((startDeviation + endDeviation) / 2).clamp(
      0,
      maxDeviation,
    );

    // Convert to percentage (100 = no deviation, 0 = max deviation)
    return ((maxDeviation - avgDeviation) / maxDeviation * 100).clamp(0, 100);
  }

  /// Calculate period length (actual)
  int getActualPeriodLength() {
    return actualEndDate.difference(actualStartDate).inDays + 1;
  }

  /// Calculate period length (predicted)
  int getPredictedPeriodLength() {
    return predictedEndDate.difference(predictedStartDate).inDays + 1;
  }

  Map<String, dynamic> toJson() => {
    'cycleId': cycleId,
    'predictedStartDate': predictedStartDate.toIso8601String(),
    'actualStartDate': actualStartDate.toIso8601String(),
    'predictedEndDate': predictedEndDate.toIso8601String(),
    'actualEndDate': actualEndDate.toIso8601String(),
    'dailyEdits': dailyEdits.map((e) => e.toJson()).toList(),
    'totalDeviationDays': totalDeviationDays,
    'bloodFlowEditCount': bloodFlowEditCount,
    'cycleCompletedAt': cycleCompletedAt.toIso8601String(),
  };

  factory PeriodCycleEdit.fromJson(Map<String, dynamic> json) =>
      PeriodCycleEdit(
        cycleId: json['cycleId'],
        predictedStartDate: DateTime.parse(json['predictedStartDate']),
        actualStartDate: DateTime.parse(json['actualStartDate']),
        predictedEndDate: DateTime.parse(json['predictedEndDate']),
        actualEndDate: DateTime.parse(json['actualEndDate']),
        dailyEdits: (json['dailyEdits'] as List)
            .map((e) => DailyPeriodEdit.fromJson(e))
            .toList(),
        totalDeviationDays: json['totalDeviationDays'] ?? 0,
        bloodFlowEditCount: json['bloodFlowEditCount'] ?? 0,
        cycleCompletedAt: DateTime.parse(json['cycleCompletedAt']),
      );
}

// ============================================================================
// PERIOD HISTORY WITH BLOOD FLOW
// ============================================================================

/// Visual representation of blood flow history for a month/cycle
class BloodFlowHistory {
  /// All days with their flow intensity
  final Map<DateTime, BloodFlowIntensity> dayFlowMap;

  /// Number of days with active bleeding
  final int activeBleedingDays;

  /// Average intensity across bleeding days
  final BloodFlowIntensity averageIntensity;

  /// Deviations detected
  final List<PeriodDeviation> deviations;

  /// Overall cycle score (0-100)
  final double cycleScore;

  BloodFlowHistory({
    required this.dayFlowMap,
    required this.activeBleedingDays,
    required this.averageIntensity,
    required this.deviations,
    required this.cycleScore,
  });

  /// Get flow for specific day
  BloodFlowIntensity getFlowForDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return dayFlowMap[normalized] ?? BloodFlowIntensity.none;
  }

  /// Get bleeding days in order
  List<DateTime> getBleedingDays() {
    return dayFlowMap.entries
        .where((e) => e.value != BloodFlowIntensity.none)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  Map<String, dynamic> toJson() => {
    'dayFlowMap': dayFlowMap.map(
      (k, v) => MapEntry(k.toIso8601String(), v.index),
    ),
    'activeBleedingDays': activeBleedingDays,
    'averageIntensity': averageIntensity.index,
    'deviations': deviations.map((e) => e.toJson()).toList(),
    'cycleScore': cycleScore,
  };
}

// ============================================================================
// PERIOD DEVIATIONS
// ============================================================================

/// Represents a deviation from predicted cycle
class PeriodDeviation {
  /// Type of deviation
  final DeviationType type;

  /// Expected date from prediction
  final DateTime expectedDate;

  /// Actual date
  final DateTime actualDate;

  /// Number of days off
  final int daysDifference;

  /// Confidence in prediction before this deviation
  final double predictionConfidence;

  /// Whether marked as unusual
  final bool isUnusual;

  PeriodDeviation({
    required this.type,
    required this.expectedDate,
    required this.actualDate,
    required this.daysDifference,
    required this.predictionConfidence,
    required this.isUnusual,
  });

  String getDescription() {
    switch (type) {
      case DeviationType.early:
        return 'Period started $daysDifference day${daysDifference > 1 ? 's' : ''} earlier than predicted';
      case DeviationType.late:
        return 'Period started $daysDifference day${daysDifference > 1 ? 's' : ''} later than predicted';
      case DeviationType.skipped:
        return 'Period was skipped this cycle';
      case DeviationType.split:
        return 'Bleeding occurred on non-consecutive days';
      case DeviationType.extended:
        return 'Period lasted $daysDifference day${daysDifference > 1 ? 's' : ''} longer than predicted';
      case DeviationType.none:
        return 'No significant deviation';
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'expectedDate': expectedDate.toIso8601String(),
    'actualDate': actualDate.toIso8601String(),
    'daysDifference': daysDifference,
    'predictionConfidence': predictionConfidence,
    'isUnusual': isUnusual,
  };

  factory PeriodDeviation.fromJson(Map<String, dynamic> json) =>
      PeriodDeviation(
        type: DeviationType.values[json['type'] ?? 5],
        expectedDate: DateTime.parse(json['expectedDate']),
        actualDate: DateTime.parse(json['actualDate']),
        daysDifference: json['daysDifference'] ?? 0,
        predictionConfidence: json['predictionConfidence'] ?? 0.0,
        isUnusual: json['isUnusual'] ?? false,
      );
}

// ============================================================================
// MODEL UPDATE DATA
// ============================================================================

/// Data sent to ML model for retraining/learning
class ModelUpdateData {
  /// The cycle edit that triggered this update
  final PeriodCycleEdit cycleEdit;

  /// Deviation detected
  final PeriodDeviation? deviation;

  /// New blood flow data
  final List<DailyPeriodEdit> newBloodFlowData;

  /// Prediction confidence before edit
  final double previousConfidence;

  /// Timestamp of update
  final DateTime updatedAt;

  ModelUpdateData({
    required this.cycleEdit,
    this.deviation,
    required this.newBloodFlowData,
    required this.previousConfidence,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'cycleEdit': cycleEdit.toJson(),
    'deviation': deviation?.toJson(),
    'newBloodFlowData': newBloodFlowData.map((e) => e.toJson()).toList(),
    'previousConfidence': previousConfidence,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

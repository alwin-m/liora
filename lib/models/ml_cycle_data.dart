/// ML-POWERED CYCLE PREDICTION SYSTEM
///
/// This file contains all ML-related data models and structures
/// for the enhanced menstrual cycle prediction system.

// ============================================================================
// PART 1: ADVANCED CYCLE DATA MODEL
// ============================================================================

/// Comprehensive cycle data with ML-friendly structure
class CycleMLDataModel {
  final DateTime lastPeriodStart;
  final DateTime lastPeriodEnd;
  final int cycleLength; // Days
  final int periodLength; // Days

  /// Bleeding characteristics
  final List<BleedingDay> bleedingPattern; // Historical bleeding data

  /// Symptom tracking
  final List<SymptomEntry> symptomHistory;

  /// Mood and energy
  final List<MoodEntry> moodHistory;

  /// Stress and sleep (optional but useful)
  final List<HealthEntry> healthHistory;

  /// Temperature data (if available from wearables)
  final List<TemperatureEntry>? temperatureData;

  /// Derived features (calculated for ML)
  final CycleDerivedFeatures derivedFeatures;

  /// Personal baseline deviations
  final PersonalBaseline personalBaseline;

  CycleMLDataModel({
    required this.lastPeriodStart,
    required this.lastPeriodEnd,
    required this.cycleLength,
    required this.periodLength,
    required this.bleedingPattern,
    required this.symptomHistory,
    required this.moodHistory,
    required this.healthHistory,
    this.temperatureData,
    required this.derivedFeatures,
    required this.personalBaseline,
  });

  /// Convert to ML feature vector (normalization)
  List<double> toFeatureVector() {
    return [
      derivedFeatures.cycleRegularity,
      derivedFeatures.bleedingIntensityVariance,
      derivedFeatures.symptomClusteringScore,
      derivedFeatures.moodVariation,
      derivedFeatures.energyVariation,
      derivedFeatures.stressImpactScore,
      derivedFeatures.historicalAccuracy,
      derivedFeatures.ovulationConsistency,
      personalBaseline.baselineCycleLength.toDouble(),
      personalBaseline.baselinePeriodLength.toDouble(),
    ];
  }

  /// Serialize for storage
  Map<String, dynamic> toJson() {
    return {
      'lastPeriodStart': lastPeriodStart.toIso8601String(),
      'lastPeriodEnd': lastPeriodEnd.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'bleedingPattern': bleedingPattern.map((e) => e.toJson()).toList(),
      'symptomHistory': symptomHistory.map((e) => e.toJson()).toList(),
      'moodHistory': moodHistory.map((e) => e.toJson()).toList(),
      'healthHistory': healthHistory.map((e) => e.toJson()).toList(),
      'temperatureData': temperatureData?.map((e) => e.toJson()).toList(),
      'derivedFeatures': derivedFeatures.toJson(),
      'personalBaseline': personalBaseline.toJson(),
    };
  }
}

// ============================================================================
// PART 2: BLEEDING CHARACTERISTICS
// ============================================================================

class BleedingDay {
  final DateTime date;
  final BleedingIntensity intensity; // light, medium, heavy
  final BloodColor color; // bright_red, dark_red, brown, pink
  final bool clots;
  final int spotValue; // 1-5 scale for spotting vs heavy flow

  BleedingDay({
    required this.date,
    required this.intensity,
    required this.color,
    required this.clots,
    required this.spotValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'intensity': intensity.toString(),
      'color': color.toString(),
      'clots': clots,
      'spotValue': spotValue,
    };
  }

  factory BleedingDay.fromJson(Map<String, dynamic> json) {
    return BleedingDay(
      date: DateTime.parse(json['date']),
      intensity: BleedingIntensity.values.firstWhere(
        (e) => e.toString() == json['intensity'],
      ),
      color: BloodColor.values.firstWhere((e) => e.toString() == json['color']),
      clots: json['clots'],
      spotValue: json['spotValue'],
    );
  }
}

enum BleedingIntensity { light, medium, heavy, spotting }

enum BloodColor { brightRed, darkRed, brown, pink }

// ============================================================================
// PART 3: SYMPTOM TRACKING
// ============================================================================

class SymptomEntry {
  final DateTime date;
  final List<CycleSymptom> symptoms;
  final Map<CycleSymptom, int> symptomIntensity; // 1-10 scale

  SymptomEntry({
    required this.date,
    required this.symptoms,
    required this.symptomIntensity,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'symptoms': symptoms.map((e) => e.toString()).toList(),
      'symptomIntensity': symptomIntensity.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      date: DateTime.parse(json['date']),
      symptoms: (json['symptoms'] as List)
          .map((e) => CycleSymptom.values.firstWhere((s) => s.toString() == e))
          .toList(),
      symptomIntensity: {},
    );
  }
}

enum CycleSymptom {
  cramps,
  bloating,
  headache,
  fatigue,
  breastTenderness,
  moodSwings,
  acne,
  nausea,
  backPain,
  constipation,
  diarrhea,
  cravings,
  waterRetention,
  concentrationDifficulty,
  jointPain,
}

// ============================================================================
// PART 4: MOOD & ENERGY TRACKING
// ============================================================================

class MoodEntry {
  final DateTime date;
  final int moodScore; // 1-10 scale
  final MoodCategory category;
  final int energyLevel; // 1-10 scale
  final int libido; // 1-10 scale (optional)
  final List<String>
  emotionalState; // Keywords: happy, anxious, irritable, etc.

  MoodEntry({
    required this.date,
    required this.moodScore,
    required this.category,
    required this.energyLevel,
    required this.libido,
    required this.emotionalState,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'moodScore': moodScore,
      'category': category.toString(),
      'energyLevel': energyLevel,
      'libido': libido,
      'emotionalState': emotionalState,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      moodScore: json['moodScore'],
      category: MoodCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      energyLevel: json['energyLevel'],
      libido: json['libido'] ?? 5,
      emotionalState: List<String>.from(json['emotionalState'] ?? []),
    );
  }
}

enum MoodCategory { happy, sad, anxious, irritable, calm, energetic, neutral }

// ============================================================================
// PART 5: HEALTH TRACKING (Sleep, Stress, Diet)
// ============================================================================

class HealthEntry {
  final DateTime date;
  final int? sleepHours; // Hours slept
  final int sleepQuality; // 1-10 scale
  final int stressLevel; // 1-10 scale
  final String? diet; // Food log description
  final int? waterIntake; // Cups per day
  final bool exercise;
  final int exerciseDuration; // Minutes
  final String exerciseType; // e.g., "cardio", "strength", "yoga"

  HealthEntry({
    required this.date,
    this.sleepHours,
    required this.sleepQuality,
    required this.stressLevel,
    this.diet,
    this.waterIntake,
    required this.exercise,
    required this.exerciseDuration,
    required this.exerciseType,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sleepHours': sleepHours,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
      'diet': diet,
      'waterIntake': waterIntake,
      'exercise': exercise,
      'exerciseDuration': exerciseDuration,
      'exerciseType': exerciseType,
    };
  }

  factory HealthEntry.fromJson(Map<String, dynamic> json) {
    return HealthEntry(
      date: DateTime.parse(json['date']),
      sleepHours: json['sleepHours'],
      sleepQuality: json['sleepQuality'],
      stressLevel: json['stressLevel'],
      diet: json['diet'],
      waterIntake: json['waterIntake'],
      exercise: json['exercise'],
      exerciseDuration: json['exerciseDuration'],
      exerciseType: json['exerciseType'],
    );
  }
}

// ============================================================================
// PART 6: TEMPERATURE DATA (Optional, from wearables)
// ============================================================================

class TemperatureEntry {
  final DateTime timestamp;
  final double basalBodyTemperature; // Celsius
  final int temperatureIndex; // 1-3: pre-ovulation, ovulation, post-ovulation

  TemperatureEntry({
    required this.timestamp,
    required this.basalBodyTemperature,
    required this.temperatureIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'basalBodyTemperature': basalBodyTemperature,
      'temperatureIndex': temperatureIndex,
    };
  }

  factory TemperatureEntry.fromJson(Map<String, dynamic> json) {
    return TemperatureEntry(
      timestamp: DateTime.parse(json['timestamp']),
      basalBodyTemperature: json['basalBodyTemperature'],
      temperatureIndex: json['temperatureIndex'],
    );
  }
}

// ============================================================================
// PART 7: DERIVED FEATURES FOR ML
// ============================================================================

/// Calculated features derived from raw data for ML model
class CycleDerivedFeatures {
  /// How consistent are cycle lengths (0-1, higher=more consistent)
  final double cycleRegularity;

  /// Variance in bleeding intensity across cycles
  final double bleedingIntensityVariance;

  /// How clustered are symptoms (0-1, higher=clear patterns)
  final double symptomClusteringScore;

  /// Variance in mood scores across cycle
  final double moodVariation;

  /// Variance in energy levels
  final double energyVariation;

  /// How much does stress impact cycle
  final double stressImpactScore;

  /// Historical prediction accuracy (0-1)
  final double historicalAccuracy;

  /// How consistent is ovulation timing (0-1)
  final double ovulationConsistency;

  /// Average cycle length variance
  final double cycleLengthStdDev;

  /// Symptom frequency map
  final Map<CycleSymptom, double> symptomFrequency;

  CycleDerivedFeatures({
    required this.cycleRegularity,
    required this.bleedingIntensityVariance,
    required this.symptomClusteringScore,
    required this.moodVariation,
    required this.energyVariation,
    required this.stressImpactScore,
    required this.historicalAccuracy,
    required this.ovulationConsistency,
    required this.cycleLengthStdDev,
    required this.symptomFrequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'cycleRegularity': cycleRegularity,
      'bleedingIntensityVariance': bleedingIntensityVariance,
      'symptomClusteringScore': symptomClusteringScore,
      'moodVariation': moodVariation,
      'energyVariation': energyVariation,
      'stressImpactScore': stressImpactScore,
      'historicalAccuracy': historicalAccuracy,
      'ovulationConsistency': ovulationConsistency,
      'cycleLengthStdDev': cycleLengthStdDev,
      'symptomFrequency': symptomFrequency.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }
}

// ============================================================================
// PART 8: PERSONAL BASELINE
// ============================================================================

/// User's personal baseline metrics for personalized predictions
class PersonalBaseline {
  /// User's average cycle length
  final int baselineCycleLength;

  /// User's average period length
  final int baselinePeriodLength;

  /// User's typical ovulation day relative to cycle start
  final int typicalOvulationDay;

  /// Most common bleeding intensity
  final BleedingIntensity typicalBleedingIntensity;

  /// Most common premenstrual symptoms
  final List<CycleSymptom> commonPMSSymptoms;

  /// Baseline energy level (1-10 average)
  final double baselineEnergy;

  /// Baseline mood (1-10 average)
  final double baselineMood;

  /// Number of cycles tracked (for reliability)
  final int cyclesTracked;

  PersonalBaseline({
    required this.baselineCycleLength,
    required this.baselinePeriodLength,
    required this.typicalOvulationDay,
    required this.typicalBleedingIntensity,
    required this.commonPMSSymptoms,
    required this.baselineEnergy,
    required this.baselineMood,
    required this.cyclesTracked,
  });

  Map<String, dynamic> toJson() {
    return {
      'baselineCycleLength': baselineCycleLength,
      'baselinePeriodLength': baselinePeriodLength,
      'typicalOvulationDay': typicalOvulationDay,
      'typicalBleedingIntensity': typicalBleedingIntensity.toString(),
      'commonPMSSymptoms': commonPMSSymptoms.map((e) => e.toString()).toList(),
      'baselineEnergy': baselineEnergy,
      'baselineMood': baselineMood,
      'cyclesTracked': cyclesTracked,
    };
  }

  factory PersonalBaseline.fromJson(Map<String, dynamic> json) {
    return PersonalBaseline(
      baselineCycleLength: json['baselineCycleLength'],
      baselinePeriodLength: json['baselinePeriodLength'],
      typicalOvulationDay: json['typicalOvulationDay'],
      typicalBleedingIntensity: BleedingIntensity.values.firstWhere(
        (e) => e.toString() == json['typicalBleedingIntensity'],
      ),
      commonPMSSymptoms: (json['commonPMSSymptoms'] as List)
          .map((e) => CycleSymptom.values.firstWhere((s) => s.toString() == e))
          .toList(),
      baselineEnergy: json['baselineEnergy'],
      baselineMood: json['baselineMood'],
      cyclesTracked: json['cyclesTracked'],
    );
  }
}

// ============================================================================
// PART 9: CYCLE PHASE PREDICTION
// ============================================================================

/// Detailed cycle phase information with probabilities
class CyclePhaseInfo {
  final CyclePhase phase; // menstrual, follicular, ovulation, luteal
  final DateTime estimatedStartDate;
  final DateTime estimatedEndDate;
  final int dayInPhase;
  final double confidenceScore; // 0-1
  final String hormonalExplanation;
  final String bodyChangesExplanation;
  final List<String> expectedSymptoms;
  final List<String> recommendedFoods;
  final List<String> foodsToAvoid;

  CyclePhaseInfo({
    required this.phase,
    required this.estimatedStartDate,
    required this.estimatedEndDate,
    required this.dayInPhase,
    required this.confidenceScore,
    required this.hormonalExplanation,
    required this.bodyChangesExplanation,
    required this.expectedSymptoms,
    required this.recommendedFoods,
    required this.foodsToAvoid,
  });

  Map<String, dynamic> toJson() {
    return {
      'phase': phase.toString(),
      'estimatedStartDate': estimatedStartDate.toIso8601String(),
      'estimatedEndDate': estimatedEndDate.toIso8601String(),
      'dayInPhase': dayInPhase,
      'confidenceScore': confidenceScore,
      'hormonalExplanation': hormonalExplanation,
      'bodyChangesExplanation': bodyChangesExplanation,
      'expectedSymptoms': expectedSymptoms,
      'recommendedFoods': recommendedFoods,
      'foodsToAvoid': foodsToAvoid,
    };
  }
}

enum CyclePhase { menstrual, follicular, ovulation, luteal }

// ============================================================================
// PART 10: ML PREDICTION OUTPUT
// ============================================================================

/// Complete ML-based cycle prediction output
class MLCyclePrediction {
  /// Next predicted period date
  final DateTime nextPeriodDate;

  /// Confidence score (0-1)
  final double confidenceScore;

  /// Detailed phase information
  final CyclePhaseInfo phaseInfo;

  /// Predicted bleeding info (if in menstrual phase)
  final PredictedBleedingInfo? bleedingInfo;

  /// Ovulation prediction (if applicable)
  final OvulationPrediction? ovulationInfo;

  /// AI-generated insight summary
  final String insightSummary;

  /// Key factors influencing prediction
  final List<String> influencingFactors;

  /// Personalized recommendations
  final List<String> personalizedRecommendations;

  /// Timestamp of prediction
  final DateTime predictionTimestamp;

  MLCyclePrediction({
    required this.nextPeriodDate,
    required this.confidenceScore,
    required this.phaseInfo,
    this.bleedingInfo,
    this.ovulationInfo,
    required this.insightSummary,
    required this.influencingFactors,
    required this.personalizedRecommendations,
    required this.predictionTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'nextPeriodDate': nextPeriodDate.toIso8601String(),
      'confidenceScore': confidenceScore,
      'phaseInfo': phaseInfo.toJson(),
      'bleedingInfo': bleedingInfo?.toJson(),
      'ovulationInfo': ovulationInfo?.toJson(),
      'insightSummary': insightSummary,
      'influencingFactors': influencingFactors,
      'personalizedRecommendations': personalizedRecommendations,
      'predictionTimestamp': predictionTimestamp.toIso8601String(),
    };
  }
}

class PredictedBleedingInfo {
  final BleedingIntensity expectedIntensity;
  final BloodColor expectedColor;
  final bool likelyClots;
  final String physiologicalExplanation;
  final List<String> ironRichFoodSuggestions;

  PredictedBleedingInfo({
    required this.expectedIntensity,
    required this.expectedColor,
    required this.likelyClots,
    required this.physiologicalExplanation,
    required this.ironRichFoodSuggestions,
  });

  Map<String, dynamic> toJson() {
    return {
      'expectedIntensity': expectedIntensity.toString(),
      'expectedColor': expectedColor.toString(),
      'likelyClots': likelyClots,
      'physiologicalExplanation': physiologicalExplanation,
      'ironRichFoodSuggestions': ironRichFoodSuggestions,
    };
  }
}

class OvulationPrediction {
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final double confidenceScore;
  final String hormonalPeakExplanation;
  final List<String> expectedBodyChanges;
  final List<String> energyFoods;

  OvulationPrediction({
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.confidenceScore,
    required this.hormonalPeakExplanation,
    required this.expectedBodyChanges,
    required this.energyFoods,
  });

  Map<String, dynamic> toJson() {
    return {
      'ovulationDate': ovulationDate.toIso8601String(),
      'fertileWindowStart': fertileWindowStart.toIso8601String(),
      'fertileWindowEnd': fertileWindowEnd.toIso8601String(),
      'confidenceScore': confidenceScore,
      'hormonalPeakExplanation': hormonalPeakExplanation,
      'expectedBodyChanges': expectedBodyChanges,
      'energyFoods': energyFoods,
    };
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ml_cycle_data.dart';

/// ML INFERENCE SERVICE
///
/// Handles TensorFlow Lite model loading, inference, and on-device learning
/// This is the core prediction engine for the AI-powered cycle system
class MLCycleInferenceService {
  static final MLCycleInferenceService _instance =
      MLCycleInferenceService._internal();

  factory MLCycleInferenceService() {
    return _instance;
  }

  MLCycleInferenceService._internal();

  // TODO: Integrate TensorFlow Lite Dart bindings
  // import 'package:tflite_flutter/tflite_flutter.dart';
  // late Interpreter _interpreter;

  bool _isInitialized = false;
  PersonalModelWeights? _personalModelWeights;
  final String _modelStorageKey = 'ml_cycle_model_weights';

  /// Initialize the ML service and load model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load pre-trained base model
      await _loadPretrainedModel();

      // Load personal model weights if available
      await _loadPersonalModelWeights();

      _isInitialized = true;
    } catch (e) {
      print('ML Service initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Load base model from assets
  /// Model should be exported from Python as .tflite file
  Future<void> _loadPretrainedModel() async {
    // TODO: Implement TensorFlow Lite model loading
    // final modelBytes = await rootBundle.load('assets/ml_models/cycle_model.tflite');
    // _interpreter = Interpreter.fromBuffer(modelBytes.buffer.asUint8List());

    // For now: Placeholder
    print('Loading pretrained cycle prediction model...');
  }

  /// Load user's personal model weights from local storage
  Future<void> _loadPersonalModelWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final weightsJson = prefs.getString(_modelStorageKey);

    if (weightsJson != null) {
      try {
        final json = jsonDecode(weightsJson);
        _personalModelWeights = PersonalModelWeights.fromJson(json);
      } catch (e) {
        print('Error loading personal weights: $e');
      }
    }
  }

  /// Main prediction function
  /// Converts user data to ML features and runs inference
  Future<MLCyclePrediction> predictCycle(CycleMLDataModel userData) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Step 1: Normalize input data
      final features = _normalizeFeatures(userData);

      // Step 2: Apply personal model weights if available
      if (_personalModelWeights != null) {
        _applyPersonalWeights(features);
      }

      // Step 3: Run ML inference
      final rawPrediction = await _runInference(features);

      // Step 4: Post-process predictions
      final prediction = _postProcessPrediction(rawPrediction, userData);

      // Step 5: Cache prediction
      await _cachePrediction(prediction);

      return prediction;
    } catch (e) {
      print('Prediction error: $e');
      // Fallback to deterministic prediction
      return _fallbackPrediction(userData);
    }
  }

  /// Normalize user data into ML feature vector
  List<double> _normalizeFeatures(CycleMLDataModel data) {
    // Normalization: Convert all features to 0-1 range

    // 1. Cycle length (normalize to 0-1, typical range 21-35)
    final cycleNorm = (data.cycleLength - 21) / (35 - 21);

    // 2. Period length (normalize to 0-1, typical range 3-7)
    final periodNorm = (data.periodLength - 3) / (7 - 3);

    // 3. Bleeding intensity variance (already 0-1 scale)
    final bleedingVar = data.derivedFeatures.bleedingIntensityVariance;

    // 4. Cycle regularity (already 0-1 scale)
    final regularity = data.derivedFeatures.cycleRegularity;

    // 5. Symptom clustering (already 0-1 scale)
    final symptomCluster = data.derivedFeatures.symptomClusteringScore;

    // 6. Mood variation (already 0-1 scale)
    final moodVar = data.derivedFeatures.moodVariation;

    // 7. Energy variation (already 0-1 scale)
    final energyVar = data.derivedFeatures.energyVariation;

    // 8. Stress impact (already 0-1 scale)
    final stressImpact = data.derivedFeatures.stressImpactScore;

    // 9. Ovulation consistency (already 0-1 scale)
    final ovulationConsistency = data.derivedFeatures.ovulationConsistency;

    // 10. Historical accuracy (already 0-1 scale)
    final historicalAccuracy = data.derivedFeatures.historicalAccuracy;

    // Return feature vector
    return [
      cycleNorm.clamp(0, 1),
      periodNorm.clamp(0, 1),
      bleedingVar,
      regularity,
      symptomCluster,
      moodVar,
      energyVar,
      stressImpact,
      ovulationConsistency,
      historicalAccuracy,
    ];
  }

  /// Apply personal model weights personalization
  void _applyPersonalWeights(List<double> features) {
    if (_personalModelWeights == null) return;

    // Apply learned weights that make model specific to this user
    for (
      int i = 0;
      i < features.length && i < _personalModelWeights!.weights.length;
      i++
    ) {
      features[i] = features[i] * _personalModelWeights!.weights[i];
    }
  }

  /// Run TensorFlow Lite inference
  Future<Map<String, dynamic>> _runInference(List<double> features) async {
    // TODO: Real TensorFlow inference
    // final input = [features];
    // final output = List(1).generate((_) => List(4)); // 4 outputs: period_date, confidence, phase, ovulation
    // _interpreter.run(input, output);
    // return {
    //   'period_date_offset': output[0][0],  // Days from today
    //   'confidence': output[0][1],           // 0-1
    //   'phase_logits': output[0][2],         // Raw phase prediction
    //   'ovulation_probability': output[0][3] // Ovulation likelihood
    // };

    // For now: Placeholder deterministic-based output
    return {
      'period_date_offset': 14.0, // Days until next period
      'confidence': 0.82,
      'phase_logits': [
        0.1,
        0.3,
        0.05,
        0.55,
      ], // menstrual, follicular, ovulation, luteal
      'ovulation_probability': 0.3,
    };
  }

  /// Post-process raw ML predictions into user-friendly format
  MLCyclePrediction _postProcessPrediction(
    Map<String, dynamic> rawPrediction,
    CycleMLDataModel userData,
  ) {
    final now = DateTime.now();

    // Parse period prediction
    final periodDateOffset = rawPrediction['period_date_offset'] as double;
    final nextPeriodDate = now.add(Duration(days: periodDateOffset.toInt()));
    final confidenceScore = ((rawPrediction['confidence'] as double).clamp(
      0,
      1,
    )).toDouble();

    // Parse phase logits
    final phaseLogits = List<double>.from(rawPrediction['phase_logits']);
    final phases = [
      CyclePhase.menstrual,
      CyclePhase.follicular,
      CyclePhase.ovulation,
      CyclePhase.luteal,
    ];
    final maxIdx = phaseLogits.indexOf(
      phaseLogits.reduce((a, b) => a > b ? a : b),
    );
    final currentPhase = phases[maxIdx];

    // Determine cycle phase info
    final phaseInfo = _generatePhaseInfo(
      currentPhase,
      nextPeriodDate,
      userData,
    );

    // Generate bleeding prediction if in menstrual phase
    final bleedingInfo = currentPhase == CyclePhase.menstrual
        ? _predictBleeding(userData)
        : null;

    // Generate ovulation prediction
    final ovulationProbability =
        rawPrediction['ovulation_probability'] as double;
    final ovulationInfo = ovulationProbability > 0.3
        ? _predictOvulation(nextPeriodDate, ovulationProbability)
        : null;

    // Generate insights and recommendations
    final insightSummary = _generateInsightSummary(
      phaseInfo,
      userData,
      confidenceScore,
    );

    final influencingFactors = _identifyInfluencingFactors(userData);
    final recommendations = _generateRecommendations(phaseInfo, userData);

    return MLCyclePrediction(
      nextPeriodDate: nextPeriodDate,
      confidenceScore: confidenceScore,
      phaseInfo: phaseInfo,
      bleedingInfo: bleedingInfo,
      ovulationInfo: ovulationInfo,
      insightSummary: insightSummary,
      influencingFactors: influencingFactors,
      personalizedRecommendations: recommendations,
      predictionTimestamp: DateTime.now(),
    );
  }

  /// Generate detailed phase information
  CyclePhaseInfo _generatePhaseInfo(
    CyclePhase phase,
    DateTime nextPeriodDate,
    CycleMLDataModel userData,
  ) {
    final now = DateTime.now();
    final dayInPhase = now.difference(userData.lastPeriodStart).inDays + 1;

    switch (phase) {
      case CyclePhase.menstrual:
        return CyclePhaseInfo(
          phase: phase,
          estimatedStartDate: now,
          estimatedEndDate: now.add(Duration(days: userData.periodLength)),
          dayInPhase: dayInPhase,
          confidenceScore: 0.95,
          hormonalExplanation:
              'Estrogen and progesterone levels are at their lowest. The uterine lining is shedding.',
          bodyChangesExplanation:
              'Menstruation is occurring. You may experience cramping as the uterus contracts to shed the lining.',
          expectedSymptoms: [
            'Cramping',
            'Fatigue',
            'Breast tenderness',
            'Mood changes',
          ],
          recommendedFoods: [
            'Iron-rich foods (spinach, lean meat)',
            'Dark chocolate',
            'Warm herbal tea',
            'Salmon (omega-3s)',
            'Red lentils',
          ],
          foodsToAvoid: [
            'Excessive caffeine',
            'Alcohol',
            'High-sodium foods',
            'Refined sugars',
          ],
        );

      case CyclePhase.follicular:
        return CyclePhaseInfo(
          phase: phase,
          estimatedStartDate: userData.lastPeriodStart.add(
            Duration(days: userData.periodLength),
          ),
          estimatedEndDate: userData.lastPeriodStart.add(
            Duration(days: userData.cycleLength ~/ 2),
          ),
          dayInPhase: dayInPhase,
          confidenceScore: 0.85,
          hormonalExplanation:
              'Estrogen levels are rising. The pituitary gland is stimulating the follicle-stimulating hormone (FSH).',
          bodyChangesExplanation:
              'Your energy and mood are improving. Skin may look clearer. Increased cervical mucus indicates approaching ovulation.',
          expectedSymptoms: [
            'Increased energy',
            'Better mood',
            'Clear skin',
            'Increased libido',
          ],
          recommendedFoods: [
            'Complex carbohydrates',
            'Lean proteins',
            'Fresh vegetables',
            'Berries',
            'Nuts and seeds',
          ],
          foodsToAvoid: ['Heavy, greasy foods'],
        );

      case CyclePhase.ovulation:
        return CyclePhaseInfo(
          phase: phase,
          estimatedStartDate: userData.lastPeriodStart.add(
            Duration(days: userData.cycleLength ~/ 2 - 1),
          ),
          estimatedEndDate: userData.lastPeriodStart.add(
            Duration(days: userData.cycleLength ~/ 2 + 1),
          ),
          dayInPhase: dayInPhase,
          confidenceScore: 0.80,
          hormonalExplanation:
              'Luteinizing hormone (LH) surge triggers ovulation. Estrogen peaks. An egg is released from the ovary.',
          bodyChangesExplanation:
              'You may feel a slight pain (mittelschmerz). Cervical mucus becomes clear and stretchy. Increased libido.',
          expectedSymptoms: [
            'Ovulation pain',
            'Peak libido',
            'Clear cervical mucus',
            'Highest energy',
          ],
          recommendedFoods: [
            'Anti-inflammatory foods',
            'Leafy greens',
            'Fatty fish',
            'Antioxidant-rich foods',
          ],
          foodsToAvoid: [
            'Inflammatory foods',
            'Processed foods',
            'Excess sugar',
          ],
        );

      case CyclePhase.luteal:
        return CyclePhaseInfo(
          phase: phase,
          estimatedStartDate: userData.lastPeriodStart.add(
            Duration(days: userData.cycleLength ~/ 2 + 2),
          ),
          estimatedEndDate: userData.lastPeriodStart.add(
            Duration(days: userData.cycleLength - 1),
          ),
          dayInPhase: dayInPhase,
          confidenceScore: 0.85,
          hormonalExplanation:
              'Progesterone levels rise. The empty follicle (corpus luteum) secretes hormones. If no implantation, hormones drop before menstruation.',
          bodyChangesExplanation:
              'You may experience bloating, mood changes, and increased appetite. Sleep and rest become more important.',
          expectedSymptoms: [
            'Bloating',
            'Mood swings',
            'Food cravings',
            'Fatigue',
            'Breast tenderness',
          ],
          recommendedFoods: [
            'Magnesium-rich foods (dark chocolate, pumpkin seeds)',
            'Complex carbohydrates',
            'Calcium sources',
            'Herbal teas (red raspberry leaf)',
            'Cooked vegetables',
          ],
          foodsToAvoid: [
            'Excess caffeine',
            'Spicy foods',
            'Processed snacks',
            'Excess salt',
          ],
        );
    }
  }

  /// Predict bleeding characteristics
  PredictedBleedingInfo _predictBleeding(CycleMLDataModel userData) {
    // Analyze historical bleeding patterns
    final recentBleeding = userData.bleedingPattern.where((b) {
      return b.date.isAfter(DateTime.now().subtract(Duration(days: 90)));
    }).toList();

    BleedingIntensity predictedIntensity = BleedingIntensity.medium;
    if (recentBleeding.isNotEmpty) {
      final intensities = recentBleeding.map((b) => b.intensity).toList();
      predictedIntensity = intensities.reduce((a, b) => a == b ? a : b);
    }

    return PredictedBleedingInfo(
      expectedIntensity: predictedIntensity,
      expectedColor: BloodColor.brightRed,
      likelyClots: recentBleeding.any((b) => b.clots),
      physiologicalExplanation:
          'The uterine lining is shedding, releasing blood and tissue. Color and flow vary naturally.',
      ironRichFoodSuggestions: [
        'Red meat',
        'Spinach and dark leafy greens',
        'Lentils and beans',
        'Fortified cereals',
        'Oysters',
      ],
    );
  }

  /// Predict ovulation timing
  OvulationPrediction _predictOvulation(
    DateTime nextPeriodDate,
    double confidence,
  ) {
    // Typically 14 days before next period
    final ovulationDate = nextPeriodDate.subtract(Duration(days: 14));
    final fertileStart = nextPeriodDate.subtract(Duration(days: 19));
    final fertileEnd = nextPeriodDate.subtract(Duration(days: 10));

    return OvulationPrediction(
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      confidenceScore: confidence,
      hormonalPeakExplanation:
          'Your body experiences a surge in luteinizing hormone (LH), triggering ovulation.',
      expectedBodyChanges: [
        'Slight temperature increase',
        'Increase in cervical mucus',
        'Breast sensitivity',
        'increased libido',
      ],
      energyFoods: [
        'Complex carbohydrates',
        'Protein (eggs, chicken, fish)',
        'Berries',
        'Nuts',
      ],
    );
  }

  /// Generate human-readable insight summary
  String _generateInsightSummary(
    CyclePhaseInfo phaseInfo,
    CycleMLDataModel userData,
    double confidence,
  ) {
    final confidenceText = confidence > 0.85
        ? 'high confidence'
        : confidence > 0.70
        ? 'moderate confidence'
        : 'lower confidence';

    return 'Based on your cycle patterns, you are likely in your ${phaseInfo.phase.toString().split('.').last} phase with $confidenceText. '
        '${phaseInfo.hormonalExplanation.substring(0, 100)}...';
  }

  /// Identify key factors influencing prediction
  List<String> _identifyInfluencingFactors(CycleMLDataModel userData) {
    final factors = <String>[];

    if (userData.derivedFeatures.cycleRegularity > 0.8) {
      factors.add('Very regular cycle pattern');
    }

    if (userData.derivedFeatures.moodVariation > 0.6) {
      factors.add('Noticeable mood fluctuations');
    }

    if (userData.healthHistory.isNotEmpty) {
      final recentStress = userData.healthHistory
          .where(
            (h) => h.date.isAfter(DateTime.now().subtract(Duration(days: 7))),
          )
          .map((h) => h.stressLevel)
          .average();
      if (recentStress > 6) {
        factors.add('Recent elevated stress levels');
      }
    }

    if (userData.symptomHistory.isNotEmpty) {
      factors.add('Consistent symptom patterns');
    }

    return factors.isEmpty ? ['Standard cycle calculation'] : factors;
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(
    CyclePhaseInfo phaseInfo,
    CycleMLDataModel userData,
  ) {
    final recommendations = <String>[];

    // Add phase-specific recommendations
    recommendations.addAll(phaseInfo.recommendedFoods.take(2));

    // Add stress management if stress is high
    if (userData.healthHistory.isNotEmpty) {
      final avgStress = userData.healthHistory
          .map((h) => h.stressLevel)
          .average();
      if (avgStress > 6) {
        recommendations.add(
          'Try stress-reduction techniques like yoga or meditation',
        );
      }
    }

    // Add sleep recommendation if sleep is poor
    if (userData.healthHistory.isNotEmpty) {
      final avgSleep = userData.healthHistory
          .where((h) => h.sleepHours != null)
          .map((h) => h.sleepHours!)
          .average();
      if (avgSleep < 7) {
        recommendations.add('Aim for 7-9 hours of sleep tonight');
      }
    }

    return recommendations;
  }

  /// Update personal model weights based on confirmed data
  /// Called after user confirms their period date
  Future<void> updatePersonalModel(DateTime confirmedPeriodDate) async {
    if (_personalModelWeights == null) {
      _personalModelWeights = PersonalModelWeights.initialize();
    }

    // Adjust weights based on prediction accuracy
    // (Simplified: real implementation would use gradient descent)
    for (int i = 0; i < _personalModelWeights!.weights.length; i++) {
      _personalModelWeights!.weights[i] *= 0.99; // Decay slight adjustment
      if (i % 2 == 0) {
        _personalModelWeights!.weights[i] += 0.01;
      }
    }

    _personalModelWeights!.updateCount += 1;

    // Save updated weights
    await _savePersonalModelWeights();
  }

  /// Save personalized weights to local storage
  Future<void> _savePersonalModelWeights() async {
    if (_personalModelWeights == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _modelStorageKey,
      jsonEncode(_personalModelWeights!.toJson()),
    );
  }

  /// Cache prediction for offline access
  Future<void> _cachePrediction(MLCyclePrediction prediction) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'ml_prediction_cache_${DateTime.now().year}_${DateTime.now().month}',
      jsonEncode(prediction.toJson()),
    );
  }

  /// Fallback to deterministic prediction if ML fails
  MLCyclePrediction _fallbackPrediction(CycleMLDataModel userData) {
    final now = DateTime.now();
    final nextPeriod = userData.lastPeriodStart.add(
      Duration(days: userData.cycleLength),
    );

    return MLCyclePrediction(
      nextPeriodDate: nextPeriod,
      confidenceScore: 0.65,
      phaseInfo: CyclePhaseInfo(
        phase: CyclePhase.follicular,
        estimatedStartDate: now,
        estimatedEndDate: nextPeriod,
        dayInPhase: now.difference(userData.lastPeriodStart).inDays,
        confidenceScore: 0.65,
        hormonalExplanation: 'Using baseline calculation',
        bodyChangesExplanation: 'Standard cycle progression',
        expectedSymptoms: [],
        recommendedFoods: [],
        foodsToAvoid: [],
      ),
      insightSummary:
          'ML prediction unavailable. Using standard cycle calculation.',
      influencingFactors: ['Fallback mode - insufficient data'],
      personalizedRecommendations: [
        'Log more data for better predictions',
        'Track symptoms consistently',
      ],
      predictionTimestamp: DateTime.now(),
    );
  }

  bool get isInitialized => _isInitialized;
}

/// Personal model weights - learned from user's patterns
class PersonalModelWeights {
  List<double> weights; // Feature importance weights
  int updateCount; // How many times model has been updated

  PersonalModelWeights({required this.weights, required this.updateCount});

  factory PersonalModelWeights.initialize() {
    return PersonalModelWeights(
      weights: List.filled(10, 1.0), // Initialize all weights to 1.0
      updateCount: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'weights': weights, 'updateCount': updateCount};
  }

  factory PersonalModelWeights.fromJson(Map<String, dynamic> json) {
    return PersonalModelWeights(
      weights: List<double>.from(json['weights']),
      updateCount: json['updateCount'],
    );
  }
}

/// Helper extension for calculating average
extension Average on Iterable<num> {
  double average() => isEmpty ? 0 : reduce((a, b) => a + b) / length;
}

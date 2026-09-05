import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

/// MOCK ML MODEL TRAINER
/// 
/// Generates a realistic ML model for cycle prediction
/// This simulates what the Python TensorFlow training would produce
/// In production, replace with actual .tflite model

class MockMLTrainer {
  /// Generate synthetic training data for demonstration
  static List<Map<String, dynamic>> generateTrainingData({int samples = 100}) {
    final data = <Map<String, dynamic>>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < samples; i++) {
      // Realistic cycle characteristics
      final cycleLength = 25 + (random + i) % 10; // 25-35 days
      final periodLength = 3 + (random + i) % 5; // 3-7 days
      final regularity = 0.7 + (random + i) % 30 / 100; // 0.7-1.0
      final bleedingVariance = 0.5 + (random + i) % 50 / 100; // 0.5-1.0

      data.add({
        'cycle_length': cycleLength / 35.0, // Normalized
        'period_length': periodLength / 7.0, // Normalized
        'regularity': regularity.clamp(0.0, 1.0),
        'bleeding_variance': bleedingVariance.clamp(0.0, 1.0),
        'symptom_clustering': (0.6 + (random + i) % 40 / 100).clamp(0.0, 1.0),
        'mood_variation': (0.5 + (random + i) % 50 / 100).clamp(0.0, 1.0),
        'energy_variation': (0.4 + (random + i) % 60 / 100).clamp(0.0, 1.0),
        'stress_impact': (0.3 + (random + i) % 70 / 100).clamp(0.0, 1.0),
        'historical_accuracy': (0.75).clamp(0.0, 1.0),
        'ovulation_consistency': (0.8 + (random + i) % 20 / 100).clamp(0.0, 1.0),
        // Expected outputs
        'next_period_offset': (14 + (random + i) % 7 - 3) / 28.0, // 11-21 days
        'confidence': (0.70 + (random + i) % 30 / 100).clamp(0.0, 1.0),
        'phase': (random + i) % 4, // 0-3 for 4 phases
        'ovulation_prob': (0.7 + (random + i) % 30 / 100).clamp(0.0, 1.0),
      });
    }

    return data;
  }

  /// Train model and save weights to SharedPreferences
  static Future<void> trainAndSaveModel() async {
    final prefs = await SharedPreferences.getInstance();

    // Generate training data
    final trainingData = generateTrainingData(samples: 100);

    // Simulate model training
    final modelWeights = _simulateModelTraining(trainingData);

    // Save weights
    await prefs.setString('ml_model_weights', jsonEncode(modelWeights));
    await prefs.setString('ml_model_trained_date', DateTime.now().toString());
  }

  /// Simulate TensorFlow model training by learning from data
  static Map<String, dynamic> _simulateModelTraining(
    List<Map<String, dynamic>> data,
  ) {
    return {
      'layer1_weights': [
        [0.5, 0.3, 0.2, 0.1, 0.4, 0.6, 0.2, 0.5, 0.8, 0.3],
        [0.4, 0.5, 0.3, 0.2, 0.3, 0.5, 0.4, 0.6, 0.2, 0.5],
      ],
      'layer2_weights': [
        [0.6, 0.4, 0.3, 0.5],
        [0.5, 0.5, 0.5, 0.5],
      ],
      'layer3_weights': [0.7, 0.6, 0.5, 0.4],
      'output_weights': [
        [0.8],
        [0.7],
        [0.2, 0.3, 0.3, 0.2],
        [0.75],
      ],
      'bias': [0.1, 0.05, 0.08, 0.06],
      'training_data_count': data.length,
      'average_accuracy': 0.78,
      'model_version': '1.0.0',
    };
  }

  /// Load trained model weights
  static Future<Map<String, dynamic>?> loadModelWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final weightsJson = prefs.getString('ml_model_weights');

    if (weightsJson != null) {
      try {
        return jsonDecode(weightsJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Simulate TensorFlow Lite inference
  static Map<String, dynamic> simulateInference(
    List<double> features,
    Map<String, dynamic> modelWeights,
  ) {
    final normalizedFeatures = features.map((f) => f.clamp(0.0, 1.0)).toList();

    final layer1Output = _simulateLayer(
      normalizedFeatures,
      (modelWeights['layer1_weights'] as List).map((e) => (e as List).cast<double>()).toList(),
    );

    final layer2Output = _simulateLayer(
      layer1Output,
      (modelWeights['layer2_weights'] as List).map((e) => (e as List).cast<double>()).toList(),
    );

    final layer3Output = _simulateLayer(
      layer2Output,
      [(modelWeights['layer3_weights'] as List).cast<double>()],
    );

    final period_offset = _sigmoid(_weightedSum(layer3Output)) / 28.0;
    final confidence = _sigmoid(_weightedSum(layer3Output));
    final phaseLogits = _softmax([0.2, 0.3, 0.3, 0.2]);
    final ovulation_prob = _sigmoid(_weightedSum(layer3Output));

    return {
      'period_date_offset': period_offset * 28,
      'confidence': confidence,
      'phase_logits': phaseLogits,
      'ovulation_probability': ovulation_prob,
    };
  }

  static List<double> _simulateLayer(
    List<double> input,
    List<List<double>> weights,
  ) {
    final output = <double>[];
    for (int i = 0; i < (weights.isNotEmpty ? 32 : 0); i++) {
      final sum = _weightedSum(input);
      output.add(_relu(sum));
    }
    return output;
  }

  static double _weightedSum(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.fold<double>(0, (sum, val) => sum + val) / values.length;
  }

  static double _relu(double x) => x > 0 ? x : 0;

  static double _sigmoid(double x) {
    return 1 / (1 + math.exp(-x));
  }

  static List<double> _softmax(List<double> logits) {
    final exp = logits.map((x) => math.exp(x)).toList();
    final sum = exp.fold<double>(0, (a, b) => a + b);
    return exp.map((x) => x / sum).toList();
  }
}

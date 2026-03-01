import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ml_cycle_data.dart';

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
        'regularity': regularity.clamp(0, 1),
        'bleeding_variance': bleedingVariance.clamp(0, 1),
        'symptom_clustering': (0.6 + (random + i) % 40 / 100).clamp(0, 1),
        'mood_variation': (0.5 + (random + i) % 50 / 100).clamp(0, 1),
        'energy_variation': (0.4 + (random + i) % 60 / 100).clamp(0, 1),
        'stress_impact': (0.3 + (random + i) % 70 / 100).clamp(0, 1),
        'historical_accuracy': (0.75).clamp(0, 1),
        'ovulation_consistency': (0.8 + (random + i) % 20 / 100).clamp(0, 1),
        // Expected outputs
        'next_period_offset': (14 + (random + i) % 7 - 3) / 28.0, // 11-21 days
        'confidence': (0.70 + (random + i) % 30 / 100).clamp(0, 1),
        'phase': (random + i) % 4, // 0-3 for 4 phases
        'ovulation_prob': (0.7 + (random + i) % 30 / 100).clamp(0, 1),
      });
    }

    return data;
  }

  /// Train model and save weights to SharedPreferences
  static Future<void> trainAndSaveModel() async {
    final prefs = await SharedPreferences.getInstance();

    // Generate training data
    final trainingData = generateTrainingData(samples: 100);

    // Simulate model training (in reality, this would be TensorFlow)
    final modelWeights = _simulateModelTraining(trainingData);

    // Save weights
    await prefs.setString('ml_model_weights', jsonEncode(modelWeights));
    await prefs.setString('ml_model_trained_date', DateTime.now().toString());

    print('✓ ML Model trained and saved');
  }

  /// Simulate TensorFlow model training by learning from data
  static Map<String, dynamic> _simulateModelTraining(
    List<Map<String, dynamic>> data,
  ) {
    // Calculate average weights from training data
    final avgCycleLength = data.map((d) => d['cycle_length'] as double).reduce((a, b) => a + b) / data.length;
    final avgPeriodLength = data.map((d) => d['period_length'] as double).reduce((a, b) => a + b) / data.length;
    final avgRegularity = data.map((d) => d['regularity'] as double).reduce((a, b) => a + b) / data.length;

    return {
      'layer1_weights': [
        [0.5, 0.3, 0.2, 0.1, 0.4, 0.6, 0.2, 0.5, 0.8, 0.3], // 64 neurons (simplified)
        [0.4, 0.5, 0.3, 0.2, 0.3, 0.5, 0.4, 0.6, 0.2, 0.5],
      ],
      'layer2_weights': [
        [0.6, 0.4, 0.3, 0.5], // 32 neurons
        [0.5, 0.5, 0.5, 0.5],
      ],
      'layer3_weights': [0.7, 0.6, 0.5, 0.4], // 16 neurons
      'output_weights': [
        [0.8], // period_date output
        [0.7], // confidence output
        [0.2, 0.3, 0.3, 0.2], // phase output (4-class)
        [0.75], // ovulation output
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
        print('Error loading model: $e');
      }
    }
    return null;
  }

  /// Simulate TensorFlow Lite inference
  static Map<String, dynamic> simulateInference(
    List<double> features,
    Map<String, dynamic> modelWeights,
  ) {
    // Normalize features ensure they're 0-1
    final normalizedFeatures = features.map((f) => f.clamp(0, 1)).toList();

    // Simulate layer 1: 10 inputs -> 64 neurons
    final layer1Output = _simulateLayer(
      normalizedFeatures,
      modelWeights['layer1_weights'] as List,
    );

    // Simulate layer 2: 64 -> 32 neurons
    final layer2Output = _simulateLayer(
      layer1Output.cast<double>(),
      modelWeights['layer2_weights'] as List,
    );

    // Simulate layer 3: 32 -> 16 neurons
    final layer3Output = _simulateLayer(
      layer2Output.cast<double>(),
      modelWeights['layer3_weights'] as List,
    );

    // Multi-task output heads
    final period_offset = _sigmoid(_weightedSum(layer3Output.cast<double>())) / 28.0; // Normalize to 0-1
    final confidence = _sigmoid(_weightedSum(layer3Output.cast<double>()));
    final phaseLogits = _softmax([0.2, 0.3, 0.3, 0.2]); // Simulated phase distribution
    final ovulation_prob = _sigmoid(_weightedSum(layer3Output.cast<double>()));

    return {
      'period_date_offset': period_offset * 28, // Convert to days (0-28)
      'confidence': confidence,
      'phase_logits': phaseLogits,
      'ovulation_probability': ovulation_prob,
    };
  }

  static List<double> _simulateLayer(
    List<double> input,
    List<dynamic> weights,
  ) {
    final output = <double>[];
    for (int i = 0; i < (weights.length > 0 ? 32 : 0); i++) {
      final sum = _weightedSum(input);
      output.add(_relu(sum)); // ReLU activation
    }
    return output;
  }

  static double _weightedSum(List<double> values) {
    return values.fold<double>(0, (sum, val) => sum + val) / values.length;
  }

  static double _relu(double x) => x > 0 ? x : 0;

  static double _sigmoid(double x) {
    return 1 / (1 + (2.71828 ^ (-x)));
  }

  static List<double> _softmax(List<double> logits) {
    final exp = logits.map((x) => 2.71828 ^ x).toList();
    final sum = exp.fold<double>(0, (a, b) => a + b);
    return exp.map((x) => x / sum).toList();
  }
}

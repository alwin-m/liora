import 'package:flutter/material.dart';
import '../models/ml_cycle_data.dart';
import '../services/ml_inference_service.dart';
import '../services/diet_recommendation_service.dart';
import '../services/mock_ml_trainer.dart';

/// ML PREDICTION TESTER SCREEN
/// 
/// Tests the AI prediction system with realistic cycle data
/// Shows: ML inference, confidence scores, phase predictions, diet recommendations

class MLPredictionTesterScreen extends StatefulWidget {
  const MLPredictionTesterScreen({Key? key}) : super(key: key);

  @override
  State<MLPredictionTesterScreen> createState() => _MLPredictionTesterScreenState();
}

class _MLPredictionTesterScreenState extends State<MLPredictionTesterScreen> {
  final MLCycleInferenceService _mlService = MLCycleInferenceService();
  final DietRecommendationEngine _dietEngine = DietRecommendationEngine();

  MLCyclePrediction? _prediction;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndTrain();
  }

  Future<void> _initializeAndTrain() async {
    try {
      setState(() => _statusMessage = '🎓 Training ML model...');
      
      // Train the mock model
      await MockMLTrainer.trainAndSaveModel();
      
      setState(() => _statusMessage = '✓ Model trained. Ready to predict!');
      
      // Initialize inference service
      await _mlService.initialize();
      
      setState(() => _statusMessage = '✓ ML Service initialized');
    } catch (e) {
      setState(() => _statusMessage = '⚠️ Error: $e');
    }
  }

  Future<void> _generateTestPrediction() async {
    setState(() => _isLoading = true);

    try {
      // Create realistic test data
      final now = DateTime.now();
      final testData = CycleMLDataModel(
        lastPeriodStart: now.subtract(const Duration(days: 20)),
        lastPeriodEnd: now.subtract(const Duration(days: 15)),
        cycleLength: 28,
        periodLength: 5,
        bleedingPattern: [
          BleedingDay(
            date: now.subtract(const Duration(days: 20)),
            intensity: BleedingIntensity.heavy,
            color: BloodColor.brightRed,
            clots: true,
            spotValue: 5,
          ),
          BleedingDay(
            date: now.subtract(const Duration(days: 19)),
            intensity: BleedingIntensity.medium,
            color: BloodColor.darkRed,
            clots: false,
            spotValue: 4,
          ),
        ],
        symptomHistory: [
          SymptomEntry(
            date: now.subtract(const Duration(days: 1)),
            symptoms: [
              CycleSymptomWithIntensity(
                symptom: CycleSymptom.bloating,
                intensity: 7,
              ),
              CycleSymptomWithIntensity(
                symptom: CycleSymptom.fatigue,
                intensity: 5,
              ),
            ],
          ),
        ],
        moodHistory: [
          MoodEntry(
            date: now.subtract(const Duration(days: 1)),
            moodScore: 6,
            moodCategory: MoodCategory.calm,
            energyLevel: 5,
            libido: 4,
            emotionalState: ['reflective', 'introspective'],
          ),
        ],
        healthHistory: [
          HealthEntry(
            date: now.subtract(const Duration(days: 1)),
            sleepHours: 7.5,
            sleepQuality: 7,
            stressLevel: 4,
            diet: 'Balanced meals, high in iron',
            waterIntake: 8,
            exerciseDuration: 30,
            exerciseType: 'Walking',
          ),
        ],
        temperatureData: [],
        derivedFeatures: CycleDerivedFeatures(
          cycleRegularity: 0.85,
          bleedingIntensityVariance: 0.65,
          symptomClusteringScore: 0.72,
          moodVariation: 0.58,
          energyVariation: 0.62,
          stressImpactScore: 0.45,
          historicalAccuracy: 0.78,
          ovulationConsistency: 0.82,
          cycleLengthStdDev: 1.5,
          symptomFrequency: {},
        ),
        personalBaseline: PersonalBaseline(
          baselineCycleLength: 28,
          baselinePeriodLength: 5,
          typicalOvulationDay: 14,
          typicalBleedingIntensity: BleedingIntensity.medium,
          commonPMSSymptoms: [CycleSymptom.bloating, CycleSymptom.fatigue],
          baselineEnergy: 6.5,
          baselineMood: 6.5,
          cyclesTracked: 12,
        ),
      );

      setState(() => _statusMessage = '🤖 Running ML inference...');

      // Get prediction
      final prediction = await _mlService.predictCycle(testData);

      setState(() {
        _prediction = prediction;
        _statusMessage = '✓ Prediction complete!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Prediction error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Cycle Prediction Tester'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateTestPrediction,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.lightning_bolt),
                label: Text(_isLoading ? 'Predicting...' : 'Generate AI Prediction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Prediction Results
            if (_prediction != null) ...[
              _buildPredictionCard(),
              const SizedBox(height: 16),
              _buildPhaseCard(),
              const SizedBox(height: 16),
              _buildConfidenceCard(),
              const SizedBox(height: 16),
              _buildInsightsCard(),
              const SizedBox(height: 16),
              _buildInfluencingFactorsCard(),
            ] else if (!_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Click "Generate AI Prediction" to test',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    final nextPeriod = _prediction!.nextPeriodDate;
    final daysUntil = nextPeriod.difference(DateTime.now()).inDays;

    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predicted Next Period',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(nextPeriod),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'in $daysUntil days',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard() {
    final phase = _prediction!.phaseInfo.phase;
    final phaseEmoji = _getPhaseEmoji(phase);
    final phaseColor = _getPhaseColor(phase);

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: phaseColor.withOpacity(0.1),
          border: Border.all(color: phaseColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  phaseEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.name.toUpperCase(),
                        style: TextStyle(
                          color: phaseColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Day ${_prediction!.phaseInfo.dayInPhase} of phase',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _prediction!.phaseInfo.hormonalExplanation,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: _prediction!.phaseInfo.expectedSymptoms
                  .take(3)
                  .map(
                    (symptom) => Chip(
                      label: Text(symptom),
                      backgroundColor: phaseColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: phaseColor),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final confidence = _prediction!.confidenceScore;
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Confidence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$confidencePercent%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  confidence > 0.8
                      ? Colors.green
                      : confidence > 0.6
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              confidence > 0.8
                  ? 'Excellent prediction confidence'
                  : confidence > 0.6
                      ? 'Good prediction confidence'
                      : 'Moderate prediction confidence - log more data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _prediction!.insightSummary,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._prediction!.personalizedRecommendations
                .take(4)
                .map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ '),
                        Expanded(
                          child: Text(
                            rec,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfluencingFactorsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Factors Influencing Prediction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._prediction!.influencingFactors
                .map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            factor,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getPhaseEmoji(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return '❤️';
      case CyclePhase.follicular:
        return '🌞';
      case CyclePhase.ovulation:
        return '⭐';
      case CyclePhase.luteal:
        return '🌙';
    }
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return Colors.red;
      case CyclePhase.follicular:
        return Colors.orange;
      case CyclePhase.ovulation:
        return Colors.yellow[700]!;
      case CyclePhase.luteal:
        return Colors.indigo;
    }
  }
}

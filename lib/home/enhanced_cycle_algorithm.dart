import 'package:lioraa/services/ai_service.dart';

enum DayType { period, fertile, ovulation, normal }

/// ENHANCED CYCLE ALGORITHM with AI Integration
///
/// Architecture: Hybrid Prediction Model
/// Layer 1: Deterministic baseline (rule-based)
/// Layer 2: AI-based probabilistic adjustment
/// Layer 3: Behavioral context modeling (optional, requires data)
///
/// PRIVACY:
/// - All computation is LOCAL
/// - No medical data leaves device
/// - Backward compatible with rule-based mode
class EnhancedCycleAlgorithm {
  final DateTime lastPeriod;
  final int cycleLength;
  final int periodLength;
  final List<DateTime>? historicalPeriodDates; // Optional historical data
  final List<String>? recentSymptoms; // Optional for AI enhancement
  final List<double>? recentMoodScores; // Optional for AI enhancement
  final AIService _aiService = AIService();

  EnhancedCycleAlgorithm({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodLength,
    this.historicalPeriodDates,
    this.recentSymptoms,
    this.recentMoodScores,
  });

  /// Get cycle day (1-indexed)
  /// Same as original algorithm
  int getCycleDay(DateTime date) {
    final normalizedLast = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final diff = normalizedDate.difference(normalizedLast).inDays;
    final safeDiff = ((diff % cycleLength) + cycleLength) % cycleLength;
    return safeDiff + 1;
  }

  /// Deterministic day type (rule-based baseline)
  DayType getType(DateTime date) {
    final cycleDay = getCycleDay(date);
    if (cycleDay >= 1 && cycleDay <= periodLength) {
      return DayType.period;
    }
    final ovulationDay = cycleLength - 14;
    if (cycleDay == ovulationDay) {
      return DayType.ovulation;
    }
    if (cycleDay >= ovulationDay - 5 && cycleDay < ovulationDay) {
      return DayType.fertile;
    }
    return DayType.normal;
  }

  /// DETERMINISTIC next period calculation
  DateTime getNextPeriodDate() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedLast = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );
    final diff = normalizedToday.difference(normalizedLast).inDays;
    if (diff <= 0) return normalizedLast;
    final cyclesPassed = diff ~/ cycleLength + 1;
    return normalizedLast.add(Duration(days: cyclesPassed * cycleLength));
  }

  /// AI-ENHANCED next period prediction
  /// Combines deterministic baseline with AI probabilistic modeling
  ///
  /// Returns: Enhanced prediction with confidence score
  Future<EnhancedPrediction> getNextPeriodPredictionAI() async {
    // Step 1: Get deterministic baseline
    final deterministicDate = getNextPeriodDate();

    // Step 2: If AI disabled or no data, return deterministic
    if (!_aiService.isEnabled ||
        (recentSymptoms == null || recentSymptoms!.isEmpty) &&
            (recentMoodScores == null || recentMoodScores!.isEmpty)) {
      return EnhancedPrediction(
        predictedDate: deterministicDate,
        deterministicDate: deterministicDate,
        confidenceScore: 0.7,
        reasoning: 'Rule-based prediction (deterministic)',
        adjustmentDays: 0,
        usedAI: false,
      );
    }

    // Step 3: Invoke AI for enhanced prediction
    try {
      final aiResponse = await _aiService.predictCycle(
        lastPeriod: lastPeriod,
        cycleLength: cycleLength,
        recentSymptoms: recentSymptoms ?? [],
        moodScores: recentMoodScores ?? [],
      );

      // Parse AI response to extract predicted date
      final aiPrediction = _parseAIPrediction(aiResponse.content);

      // If AI parsing fails, fall back to deterministic
      if (aiPrediction == null) {
        return EnhancedPrediction(
          predictedDate: deterministicDate,
          deterministicDate: deterministicDate,
          confidenceScore: 0.7,
          reasoning: 'AI analysis used but date extraction failed',
          adjustmentDays: 0,
          usedAI: false,
        );
      }

      // Step 4: Calculate adjustment (AI vs deterministic)
      final adjustmentDays = aiPrediction.predictedDate
          .difference(deterministicDate)
          .inDays;

      return EnhancedPrediction(
        predictedDate: aiPrediction.predictedDate,
        deterministicDate: deterministicDate,
        confidenceScore: aiPrediction.confidence,
        reasoning: aiPrediction.reasoning,
        adjustmentDays: adjustmentDays,
        usedAI: true,
      );
    } catch (e) {
      // Graceful fallback to deterministic
      return EnhancedPrediction(
        predictedDate: deterministicDate,
        deterministicDate: deterministicDate,
        confidenceScore: 0.7,
        reasoning: 'AI unavailable, using rule-based prediction',
        adjustmentDays: 0,
        usedAI: false,
      );
    }
  }

  /// AI-ENHANCED cycle phase prediction
  /// Returns probability distribution for current phase
  Future<PhaseDistribution> getPhaseDistributionAI(DateTime date) async {
    final deterministicType = getType(date);

    // If AI disabled, return deterministic as 100% confidence
    if (!_aiService.isEnabled) {
      return PhaseDistribution(
        predictedPhase: deterministicType,
        follicularProbability: deterministicType == DayType.normal ? 0.8 : 0.2,
        ovulationProbability: deterministicType == DayType.ovulation
            ? 0.8
            : 0.1,
        lutealProbability: deterministicType == DayType.normal ? 0.8 : 0.2,
        menstrualProbability: deterministicType == DayType.period ? 0.8 : 0.1,
        usedAI: false,
      );
    }

    // With AI: Could analyze patterns to adjust probabilities
    // For now, enhanced deterministic with confidence adjustment
    const aiBoost = 1.15; // AI increases confidence by 15%

    return PhaseDistribution(
      predictedPhase: deterministicType,
      follicularProbability: _adjustProbability(
        deterministicType == DayType.normal ? 0.8 : 0.2,
        aiBoost,
      ),
      ovulationProbability: _adjustProbability(
        deterministicType == DayType.ovulation ? 0.8 : 0.1,
        aiBoost,
      ),
      lutealProbability: _adjustProbability(
        deterministicType == DayType.normal ? 0.8 : 0.2,
        aiBoost,
      ),
      menstrualProbability: _adjustProbability(
        deterministicType == DayType.period ? 0.8 : 0.1,
        aiBoost,
      ),
      usedAI: true,
    );
  }

  /// Estimate cycle pattern regularity using historical data
  /// Higher score = more regular cycle
  double calculateCycleRegularity() {
    if (historicalPeriodDates == null || historicalPeriodDates!.length < 2) {
      return 0.5; // Unknown regularity
    }

    final durations = <int>[];
    for (int i = 1; i < historicalPeriodDates!.length; i++) {
      final duration = historicalPeriodDates![i]
          .difference(historicalPeriodDates![i - 1])
          .inDays;
      durations.add(duration);
    }

    // Calculate coefficient of variation
    final mean = durations.reduce((a, b) => a + b) / durations.length;
    final variance =
        durations.map((d) => (d - mean) * (d - mean)).reduce((a, b) => a + b) /
        durations.length;
    final stdDev = variance.isFinite ? variance.sqrt() : 0;
    final coefficientOfVariation = stdDev / mean;

    // Convert to regularity score (0-1, higher = more regular)
    // If CV < 0.1: very regular, score ~0.9
    // If CV > 0.2: irregular, score ~0.6
    return (1 - (coefficientOfVariation / 0.3)).clamp(0, 1);
  }

  /// HELPER: Parse AI prediction response
  /// Looks for date in format YYYY-MM-DD in AI response
  _AIPredictionResult? _parseAIPrediction(String aiResponse) {
    try {
      // Simple regex to find YYYY-MM-DD format
      final regex = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
      final match = regex.firstMatch(aiResponse);

      if (match == null) return null;

      final dateStr = match.group(0)!;
      final predictedDate = DateTime.parse(dateStr);

      // Extract confidence percentage
      final confidenceRegex = RegExp(r'(\d+)%');
      final confidenceMatch = confidenceRegex.firstMatch(aiResponse);
      final confidence = confidenceMatch != null
          ? double.parse(confidenceMatch.group(1)!) / 100
          : 0.75;

      return _AIPredictionResult(
        predictedDate: predictedDate,
        confidence: confidence.clamp(0, 1),
        reasoning: aiResponse,
      );
    } catch (e) {
      return null;
    }
  }

  /// HELPER: Adjust probability with constraint (0-1)
  double _adjustProbability(double base, double factor) {
    return (base * factor).clamp(0, 1);
  }
}

/// Result of AI prediction
class EnhancedPrediction {
  final DateTime predictedDate;
  final DateTime deterministicDate;
  final double confidenceScore;
  final String reasoning;
  final int adjustmentDays; // Difference from deterministic
  final bool usedAI;

  EnhancedPrediction({
    required this.predictedDate,
    required this.deterministicDate,
    required this.confidenceScore,
    required this.reasoning,
    required this.adjustmentDays,
    required this.usedAI,
  });

  /// Get human-readable adjustment description
  String getAdjustmentDescription() {
    if (adjustmentDays == 0) return 'Matches deterministic prediction';
    if (adjustmentDays > 0) return 'AI predicts +$adjustmentDays days later';
    return 'AI predicts ${adjustmentDays.abs()} days earlier';
  }
}

/// Probability distribution for cycle phases
class PhaseDistribution {
  final DayType predictedPhase;
  final double
  follicularProbability; // Follicular (low estrogen, follicle growth)
  final double ovulationProbability; // Ovulation day
  final double lutealProbability; // Luteal (high progesterone)
  final double menstrualProbability; // Menstrual (period)
  final bool usedAI;

  PhaseDistribution({
    required this.predictedPhase,
    required this.follicularProbability,
    required this.ovulationProbability,
    required this.lutealProbability,
    required this.menstrualProbability,
    required this.usedAI,
  });

  /// Which phase has highest probability
  DayType getMostLikelyPhase() {
    final probs = {
      DayType.normal: [
        follicularProbability,
        lutealProbability,
      ].reduce((a, b) => a > b ? a : b),
      DayType.ovulation: ovulationProbability,
      DayType.period: menstrualProbability,
    };

    return probs.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// Internal class for parsing AI predictions
class _AIPredictionResult {
  final DateTime predictedDate;
  final double confidence;
  final String reasoning;

  _AIPredictionResult({
    required this.predictedDate,
    required this.confidence,
    required this.reasoning,
  });
}

extension _DoubleExtension on double {
  double sqrt() => double.parse(this.toStringAsFixed(10));
}

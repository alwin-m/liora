import 'ai_service.dart';

/// JOURNAL ANALYSIS SERVICE
///
/// Analyzes free-text journal entries to extract:
/// - Physical symptoms (cramps, bloating, fatigue, etc.)
/// - Emotional/mood indicators
/// - Energy levels
/// - Physical state observations
/// - Cycle phase correlations
///
/// PRIVACY: All analysis is local. No entries leave device.
class JournalAnalysisService {
  final AIService _aiService = AIService();

  /// Analyze a single journal entry
  Future<JournalAnalysis> analyzeEntry({
    required String entryText,
    required DateTime entryDate,
  }) async {
    if (!_aiService.isEnabled) {
      return JournalAnalysis.fromDeterministic(
        entryText: entryText,
        entryDate: entryDate,
      );
    }

    try {
      final aiResponse = await _aiService.analyzeJournalEntry(
        entryText: entryText,
        entryDate: entryDate,
      );

      return JournalAnalysis.fromAIResponse(
        response: aiResponse,
        entryText: entryText,
        entryDate: entryDate,
      );
    } catch (e) {
      return JournalAnalysis.fromDeterministic(
        entryText: entryText,
        entryDate: entryDate,
      );
    }
  }

  /// Analyze multiple journal entries and extract patterns
  Future<JournalPatterns> analyzePatterns(
    List<JournalAnalysis> analyses,
  ) async {
    if (analyses.isEmpty) {
      return JournalPatterns.empty();
    }

    // Extract all symptom occurrences
    final symptomsMap = <String, int>{};
    for (final analysis in analyses) {
      for (final symptom in analysis.symptoms) {
        symptomsMap[symptom] = (symptomsMap[symptom] ?? 0) + 1;
      }
    }

    // Sort by frequency
    final topSymptoms = symptomsMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate average mood trend
    final validMoodScores = analyses
        .map((a) => a.moodScore)
        .where((m) => m != null)
        .cast<double>()
        .toList();
    final averageMood = validMoodScores.isNotEmpty
        ? validMoodScores.reduce((a, b) => a + b) / validMoodScores.length
        : null;

    return JournalPatterns(
      topSymptoms: topSymptoms.map((e) => e.key).toList(),
      symptomFrequency: Map.fromEntries(topSymptoms),
      averageMood: averageMood,
      totalEntries: analyses.length,
      dateRange: DateRange(
        start: analyses.first.entryDate,
        end: analyses.last.entryDate,
      ),
    );
  }

  /// Get recommendations based on journal patterns
  Future<String> getRecommendationsFromPatterns(
    JournalPatterns patterns,
    String cyclePhase,
  ) async {
    if (!_aiService.isEnabled || patterns.topSymptoms.isEmpty) {
      return 'Keep journaling to see patterns emerge.';
    }

    try {
      final response = await _aiService.generateWellnessRecommendation(
        cyclePhase: cyclePhase,
        currentSymptoms: patterns.topSymptoms.take(3).toList(),
        userPreference: 'general wellness',
      );

      return response.content;
    } catch (e) {
      return 'Continue tracking for personalized insights.';
    }
  }
}

/// Analyzed journal entry
class JournalAnalysis {
  final String entryText;
  final DateTime entryDate;
  final List<String> symptoms; // Extracted symptoms
  final List<String> moodIndicators; // Mood keywords
  final double? moodScore; // Calculated mood (1-10)
  final String? physicalState; // Energy, pain, etc.
  final String? phaseAssessment; // User-perceived phase
  final String? keyInsight; // Single key insight
  final bool usedAI;

  JournalAnalysis({
    required this.entryText,
    required this.entryDate,
    required this.symptoms,
    required this.moodIndicators,
    this.moodScore,
    this.physicalState,
    this.phaseAssessment,
    this.keyInsight,
    this.usedAI = true,
  });

  /// Create from AI response
  factory JournalAnalysis.fromAIResponse({
    required AIResponse response,
    required String entryText,
    required DateTime entryDate,
  }) {
    try {
      // Try to parse JSON response
      // Expected format: {"symptoms":[], "mood":[], "physical":"", "phase":"", "insight":""}

      // For now, simplified extraction
      final symptoms = _extractList(response.content, 'symptoms');
      final mood = _extractList(response.content, 'mood');

      return JournalAnalysis(
        entryText: entryText,
        entryDate: entryDate,
        symptoms: symptoms,
        moodIndicators: mood,
        moodScore: _extractMoodScore(response.content),
        physicalState: _extractValue(response.content, 'physical'),
        phaseAssessment: _extractValue(response.content, 'phase'),
        keyInsight: _extractValue(response.content, 'insight'),
        usedAI: true,
      );
    } catch (e) {
      return JournalAnalysis.fromDeterministic(
        entryText: entryText,
        entryDate: entryDate,
      );
    }
  }

  /// Create from deterministic analysis (when AI disabled)
  factory JournalAnalysis.fromDeterministic({
    required String entryText,
    required DateTime entryDate,
  }) {
    // Simple keyword extraction
    final text = entryText.toLowerCase();
    final symptoms = _detectKeywords(text, _commonSymptomKeywords);
    const moodKeywords = {
      'happy': 1.0,
      'sad': 0.3,
      'tired': 0.4,
      'energetic': 0.8,
      'anxious': 0.2,
      'calm': 0.7,
      'irritable': 0.2,
      'fine': 0.5,
      'good': 0.7,
      'bad': 0.3,
    };
    final mood = _detectKeywords(text, moodKeywords);

    return JournalAnalysis(
      entryText: entryText,
      entryDate: entryDate,
      symptoms: symptoms,
      moodIndicators: mood,
      moodScore: _calculateMoodScore(mood),
      usedAI: false,
    );
  }

  /// Common symptom keywords for deterministic extraction
  static const _commonSymptomKeywords = {
    'cramp': 'Cramps',
    'bloat': 'Bloating',
    'headache': 'Headache',
    'fatigue': 'Fatigue',
    'tired': 'Fatigue',
    'mood swing': 'Mood swings',
    'acne': 'Acne',
    'nausea': 'Nausea',
    'discharge': 'Discharge changes',
    'pain': 'Pelvic pain',
  };
}

/// Patterns extracted from multiple journal entries
class JournalPatterns {
  final List<String> topSymptoms; // Most frequent symptoms
  final Map<String, int> symptomFrequency; // Symptom -> count
  final double? averageMood;
  final int totalEntries;
  final DateRange dateRange;

  JournalPatterns({
    required this.topSymptoms,
    required this.symptomFrequency,
    this.averageMood,
    required this.totalEntries,
    required this.dateRange,
  });

  factory JournalPatterns.empty() {
    return JournalPatterns(
      topSymptoms: [],
      symptomFrequency: {},
      totalEntries: 0,
      dateRange: DateRange.empty(),
    );
  }

  /// Human-readable summary
  String getSummary() {
    if (topSymptoms.isEmpty) {
      return 'Not enough data to identify patterns.';
    }

    final symptomsList = topSymptoms.take(3).join(', ');
    final moodText = averageMood != null
        ? ' Average mood: ${averageMood!.toStringAsFixed(1)}/10.'
        : '';
    return 'Most common: $symptomsList.$moodText';
  }
}

/// Date range utility
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  factory DateRange.empty() {
    return DateRange(start: DateTime.now(), end: DateTime.now());
  }

  int get daysSpanned => end.difference(start).inDays;
}

// HELPER FUNCTIONS
List<String> _extractList(String response, String key) {
  try {
    final pattern = RegExp('\"$key\"\\s*:\\s*\\[([^\\]]+)\\]');
    final match = pattern.firstMatch(response);
    if (match != null) {
      final content = match.group(1)!;
      return content
          .split(',')
          .map((s) => s.replaceAll('"', '').replaceAll("'", '').trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  } catch (e) {}
  return [];
}

String? _extractValue(String response, String key) {
  try {
    final pattern = RegExp('\"$key\"\\s*:\\s*\"([^\"]+)\"');
    final match = pattern.firstMatch(response);
    return match?.group(1);
  } catch (e) {}
  return null;
}

double? _extractMoodScore(String response) {
  try {
    final regex = RegExp(r'mood[^0-9]*([0-9]+)');
    final match = regex.firstMatch(response);
    if (match != null) {
      return double.parse(match.group(1)!) / 10;
    }
  } catch (e) {}
  return null;
}

double _calculateMoodScore(List<String> moodKeywords) {
  const moodValues = {
    'happy': 0.8,
    'sad': 0.3,
    'tired': 0.4,
    'energetic': 0.8,
    'anxious': 0.2,
    'calm': 0.7,
    'irritable': 0.2,
    'fine': 0.5,
    'good': 0.7,
    'bad': 0.3,
  };

  if (moodKeywords.isEmpty) return 0.5;
  final sum = moodKeywords.fold<double>(
    0,
    (sum, mood) => sum + (moodValues[mood] ?? 0.5),
  );
  return sum / moodKeywords.length;
}

List<String> _detectKeywords(String text, Map<String, dynamic> keywords) {
  return keywords.keys
      .where((keyword) => text.contains(keyword.toLowerCase()))
      .map((keyword) => keywords[keyword].toString())
      .toList();
}

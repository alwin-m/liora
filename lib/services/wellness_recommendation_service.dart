import 'ai_service.dart';

/// WELLNESS AND PRODUCT RECOMMENDATION ENGINE
///
/// AI-powered personalized recommendations based on:
/// - Current cycle phase
/// - Tracked symptoms
/// - Historical patterns
/// - User preferences
///
/// Integrates with the shop to suggest relevant products
/// while maintaining wellness-first approach (not sales-driven)
class WellnessRecommendationEngine {
  final AIService _aiService = AIService();

  /// Get wellness recommendations for current phase
  Future<WellnessRecommendation> getRecommendation({
    required String cyclePhase, // follicular/ovulation/luteal/menstrual
    required List<String> currentSymptoms,
    required String focusArea, // exercise/nutrition/rest/mindfulness
  }) async {
    if (!_aiService.isEnabled) {
      return _getDefaultRecommendation(cyclePhase, focusArea);
    }

    try {
      final aiResponse = await _aiService.generateWellnessRecommendation(
        cyclePhase: cyclePhase,
        currentSymptoms: currentSymptoms,
        userPreference: focusArea,
      );

      return WellnessRecommendation(
        cyclePhase: cyclePhase,
        focusArea: focusArea,
        recommendation: aiResponse.content,
        source: RecommendationSource.ai,
        confidence: aiResponse.confidence,
      );
    } catch (e) {
      return _getDefaultRecommendation(cyclePhase, focusArea);
    }
  }

  /// Get product recommendations for current cycle state
  Future<List<ProductRecommendation>> recommendProducts({
    required String cyclePhase,
    required List<String> symptoms,
    required int budgetLevel, // 1=budget, 2=mid, 3=premium
  }) async {
    if (!_aiService.isEnabled) {
      return _getDefaultProductRecommendations(cyclePhase);
    }

    try {
      final aiResponse = await _aiService.recommendProducts(
        cyclePhase: cyclePhase,
        symptoms: symptoms,
        budgetRange: budgetLevel,
      );

      return _parseProductRecommendations(aiResponse.content, cyclePhase);
    } catch (e) {
      return _getDefaultProductRecommendations(cyclePhase);
    }
  }

  /// Get phase-specific wellness tips
  List<String> getPhaseSpecificTips(String cyclePhase) {
    const tips = {
      'menstrual': [
        'Prioritize rest and iron-rich foods',
        'Stay hydrated throughout your cycle',
        'Gentle yoga or stretching may help with discomfort',
        'Track how you\'re feeling to build patterns',
      ],
      'follicular': [
        'Energy levels rising - great time for new activities',
        'Consider strength training if interested',
        'Eat nutrient-dense foods to support hormone production',
        'This is often a good time for social activities',
      ],
      'ovulation': [
        'Peak energy and confidence day nearby',
        'Maintain consistent nutrition',
        'Stay hydrated and get adequate sleep',
        'May notice increased cervical mucus (normal)',
      ],
      'luteal': [
        'Energy may decline - listen to your body',
        'Increase magnesium and complex carbs if helpful',
        'Low-impact exercise might feel better',
        'Extra self-care time is beneficial',
      ],
    };

    return tips[cyclePhase] ?? tips['normal'] ?? [];
  }

  /// Get symptom management suggestions
  Map<String, String> getSymptomRelief(List<String> symptoms) {
    const relief = {
      'Cramps': 'Heat therapy, magnesium, light exercise',
      'Bloating': 'Stay hydrated, reduce salt, light walking',
      'Fatigue': 'Iron-rich foods, extra rest, B vitamins',
      'Headache': 'Hydration, rest, magnesium',
      'Mood swings': 'Omega-3s, B6, structured routine',
      'Acne': 'Gentle skincare, avoid touching face',
      'Nausea': 'Ginger, small frequent meals',
    };

    return {
      for (final symptom in symptoms)
        symptom: relief[symptom] ?? 'Consult healthcare provider',
    };
  }

  // PRIVATE HELPERS

  WellnessRecommendation _getDefaultRecommendation(
    String cyclePhase,
    String focusArea,
  ) {
    const defaults = {
      'menstrual': {
        'exercise': 'Rest and gentle movement are prioritized now.',
        'nutrition': 'Focus on iron-rich foods and staying well-hydrated.',
        'rest': 'This is a good time for restorative activities.',
        'mindfulness': 'Consider meditation or journaling for reflection.',
      },
      'follicular': {
        'exercise': 'Your energy is rising - great for new activities.',
        'nutrition': 'Support hormone production with nutrient-dense food.',
        'rest': 'You may need less rest this phase.',
        'mindfulness': 'Channel your rising energy into positive focus.',
      },
      'ovulation': {
        'exercise': 'Peak performance window - strength training is ideal.',
        'nutrition': 'Maintain balanced, anti-inflammatory foods.',
        'rest': 'Adequate sleep supports hormonal balance.',
        'mindfulness': 'Great time for confidence-building practices.',
      },
      'luteal': {
        'exercise': 'Lower intensity, restorative movement feels better.',
        'nutrition': 'Add complex carbs and magnesium-rich foods if helpful.',
        'rest': 'More rest supports your luteal phase needs.',
        'mindfulness': 'Introspection and self-care align with this phase.',
      },
    };

    final phaseDefaults = defaults[cyclePhase] ?? defaults['menstrual']!;
    return WellnessRecommendation(
      cyclePhase: cyclePhase,
      focusArea: focusArea,
      recommendation:
          phaseDefaults[focusArea] ??
          'Continue tracking for personalized insights.',
      source: RecommendationSource.default_,
      confidence: 0.6,
    );
  }

  List<ProductRecommendation> _getDefaultProductRecommendations(
    String cyclePhase,
  ) {
    final defaults = {
      'menstrual': [
        ProductRecommendation(
          category: 'Pain Relief',
          reason: 'Heat therapy helps with menstrual discomfort',
          examples: ['Heating pad', 'Microwaveable heat pack'],
        ),
        ProductRecommendation(
          category: 'Nutrition',
          reason: 'Iron-rich supplements support energy',
          examples: ['Iron supplement', 'Fortified foods'],
        ),
      ],
      'follicular': [
        ProductRecommendation(
          category: 'Vitamins',
          reason: 'Support rising energy and hormone production',
          examples: ['B-complex', 'Multivitamin'],
        ),
      ],
      'ovulation': [
        ProductRecommendation(
          category: 'Skincare',
          reason: 'Hormones peak - extra skincare support',
          examples: ['Gentle cleanser', 'Light moisturizer'],
        ),
      ],
      'luteal': [
        ProductRecommendation(
          category: 'Magnesium',
          reason: 'Supports mood and reduces discomfort',
          examples: ['Magnesium supplement', 'Magnesium oil'],
        ),
        ProductRecommendation(
          category: 'Comfort Items',
          reason: 'Self-care items for introspective phase',
          examples: ['Heating pad', 'Comfort tea'],
        ),
      ],
    };

    return defaults[cyclePhase] ?? [];
  }

  List<ProductRecommendation> _parseProductRecommendations(
    String aiResponse,
    String cyclePhase,
  ) {
    // Try to parse product recommendations from AI response
    // Format expected: "Category: [reason]"
    final lines = aiResponse.split('\n');
    final recommendations = <ProductRecommendation>[];

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          recommendations.add(
            ProductRecommendation(
              category: parts[0].trim(),
              reason: parts[1].trim(),
              examples: [],
            ),
          );
        }
      }
    }

    return recommendations.isNotEmpty
        ? recommendations
        : _getDefaultProductRecommendations(cyclePhase);
  }
}

/// Wellness recommendation
class WellnessRecommendation {
  final String cyclePhase;
  final String focusArea;
  final String recommendation;
  final RecommendationSource source;
  final double confidence;
  final DateTime timestamp;

  WellnessRecommendation({
    required this.cyclePhase,
    required this.focusArea,
    required this.recommendation,
    required this.source,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get source label for display
  String getSourceLabel() {
    switch (source) {
      case RecommendationSource.ai:
        return 'AI-Personalized';
      case RecommendationSource.default_:
        return 'General Guidance';
      case RecommendationSource.user_preference:
        return 'Based on Your Preferences';
    }
  }

  /// Get confidence description
  String getConfidenceLabel() {
    if (confidence > 0.8) return 'High confidence';
    if (confidence > 0.6) return 'Moderately confident';
    return 'Based on available data';
  }
}

/// Product recommendation
class ProductRecommendation {
  final String category;
  final String reason;
  final List<String> examples;

  ProductRecommendation({
    required this.category,
    required this.reason,
    required this.examples,
  });

  /// Get formatted display text
  String getFormattedText() {
    final examplesText = examples.isNotEmpty
        ? ' (e.g., ${examples.join(', ')})'
        : '';
    return '$category: $reason$examplesText';
  }
}

/// Recommendation source
enum RecommendationSource { ai, default_, user_preference }

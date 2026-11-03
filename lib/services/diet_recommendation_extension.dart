import 'package:lioraa/models/ml_cycle_data.dart';
import 'package:lioraa/services/diet_recommendation_service.dart';

/// DIET RECOMMENDATION EXTENSIONS
///
/// Extensions to DietRecommendationEngine for the demo app
/// Provides methods to get foods for phases and foods to avoid

extension DietRecommendationExtension on DietRecommendationEngine {
  /// Get recommended foods for a specific cycle phase (Legacy support)
  List<String> getFoodsForPhase(CyclePhase phase) {
    // We default to Global wellness plan for legacy calls
    return getFoodsForPhase(phase); // This calls the compatibility method in the engine
  }

  /// Get foods to avoid during a specific cycle phase (Legacy support)
  List<String> getFoodsToAvoid(CyclePhase phase) {
    return getFoodsToAvoid(phase); // This calls the compatibility method in the engine
  }
}

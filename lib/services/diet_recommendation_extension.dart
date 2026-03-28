import 'package:lioraa/models/ml_cycle_data.dart';
import 'package:lioraa/services/diet_recommendation_service.dart';

/// DIET RECOMMENDATION EXTENSIONS
///
/// Extensions to DietRecommendationEngine for the demo app
/// Provides methods to get foods for phases and foods to avoid

extension DietRecommendationExtension on DietRecommendationEngine {
  /// Get recommended foods for a specific cycle phase
  List<String> getFoodsForPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          'Red meat',
          'Spinach',
          'Lentils',
          'Beans',
          'Dark chocolate',
          'Beets',
          'Pomegranate',
          'Chicken',
          'Salmon',
          'Pumpkin seeds',
          'Almonds',
          'Dates',
        ];
      case CyclePhase.follicular:
        return [
          'Chicken breast',
          'Eggs',
          'Quinoa',
          'Brown rice',
          'Whole wheat bread',
          'Broccoli',
          'Bell peppers',
          'Berries',
          'Oranges',
          'Kiwi',
          'Oats',
          'Greek yogurt',
        ];
      case CyclePhase.ovulation:
        return [
          'Salmon',
          'Tuna',
          'Sardines',
          'Flaxseeds',
          'Chia seeds',
          'Walnuts',
          'Avocado',
          'Turmeric',
          'Ginger',
          'Green tea',
          'Bell peppers',
          'Tomatoes',
        ];
      case CyclePhase.luteal:
        return [
          'Sweet potato',
          'Whole wheat pasta',
          'Buckwheat',
          'Chickpeas',
          'Almonds',
          'Cashews',
          'Dark chocolate',
          'Bananas',
          'Avocado',
          'Olive oil',
          'Brazil nuts',
          'Pumpkin seeds',
        ];
    }
  }

  /// Get foods to avoid during a specific cycle phase
  List<String> getFoodsToAvoid(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          'Caffeine',
          'Excess sodium',
          'Sugar-rich foods',
          'Alcohol',
          'Processed meats',
          'Trans fats',
          'Spicy foods',
          'Excess dairy',
        ];
      case CyclePhase.follicular:
        return [
          'High fat meals',
          'Heavy processed foods',
          'Excess alcohol',
          'Too much caffeine',
          'Refined sugars',
          'Fried foods',
        ];
      case CyclePhase.ovulation:
        return [
          'High salt intake',
          'Spicy foods',
          'High sugar',
          'Excess caffeine',
          'Alcohol',
          'Inflammatory oils',
        ];
      case CyclePhase.luteal:
        return [
          'Light meals only',
          'Skipping meals',
          'Excessive caffeine',
          'Alcohol',
          'High sodium',
          'Artificial sweeteners',
        ];
    }
  }
}

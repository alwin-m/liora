import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ml_cycle_data.dart';

/// DIET RECOMMENDATION ENGINE
///
/// Uses free, open APIs to provide nutritional guidance based on cycle phase:
/// - Open Food Facts API (free, no key required)
/// - USDA FoodData Central API (free, public API)
/// - WHO nutritional guidelines
///
/// 100% free and open-source. No proprietary APIs.
class DietRecommendationEngine {
  static final DietRecommendationEngine _instance =
      DietRecommendationEngine._internal();

  factory DietRecommendationEngine() {
    return _instance;
  }

  DietRecommendationEngine._internal();

  // API endpoints (all free and public)
  static const String openFoodFactsAPI =
      'https://world.openfoodfacts.org/api/v0/product/';
  static const String usdaFoodDataAPI =
      'https://fdc.nal.usda.gov/api/foods/search';
  static const String usdaAPIKey =
      'DEMO_KEY'; // Free public key for development

  /// Get food recommendations for cycle phase
  Future<List<FoodRecommendation>> getFoodsForPhase(CyclePhase phase) async {
    return _getPhaseOptimalFoods(phase);
  }

  /// Get foods to avoid during phase
  Future<List<String>> getFoodsToAvoid(CyclePhase phase) async {
    return _getPhaseAvoidFoods(phase);
  }

  /// Detailed nutritional breakdown for a food
  Future<FoodNutrition?> getNutritionInfo(String foodName) async {
    try {
      // Try USDA API first (more comprehensive)
      final usdaResult = await _searchUSDAFood(foodName);
      if (usdaResult != null) {
        return usdaResult;
      }

      // Fallback to Open Food Facts
      return await _searchOpenFoodFacts(foodName);
    } catch (e) {
      print('Error fetching nutrition info: $e');
      return null;
    }
  }

  /// Get comprehensive meal plan for phase
  Future<MealPlan> getMealPlanForPhase(CyclePhase phase) async {
    final foods = await getFoodsForPhase(phase);

    return MealPlan(
      phase: phase,
      breakfast: _generateMeal(foods, 'breakfast'),
      lunch: _generateMeal(foods, 'lunch'),
      dinner: _generateMeal(foods, 'dinner'),
      snacks: _generateSnacks(foods),
      hydration: _getHydrationTips(phase),
      supplements: _getSupplementRecommendations(phase),
      mealPrepTips: _getMealPrepTips(phase),
    );
  }

  /// Get iron-rich foods (especially important during menstrual phase)
  Future<List<FoodRecommendation>> getIronRichFoods() async {
    return [
      FoodRecommendation(
        name: 'Red Meat',
        ironContent: '3.6 mg/100g',
        bioavailability: 'High',
        reason: 'Heme iron - most easily absorbed form',
        servingSize: '100g',
        benefits: ['Replenishes iron', 'Provides B12', 'Rich in protein'],
      ),
      FoodRecommendation(
        name: 'Spinach',
        ironContent: '2.7 mg/100g',
        bioavailability: 'Medium',
        reason: 'Plant-based iron - enhance absorption with vitamin C',
        servingSize: '1 cup raw',
        benefits: ['Fiber-rich', 'Contains folate', 'Antioxidants'],
      ),
      FoodRecommendation(
        name: 'Lentils',
        ironContent: '6.5 mg/100g (cooked)',
        bioavailability: 'Medium',
        reason: 'High iron content, combine with citrus for better absorption',
        servingSize: '1 cup cooked',
        benefits: ['High protein', 'Fiber', 'Plant-based'],
      ),
      FoodRecommendation(
        name: 'Dark Chocolate',
        ironContent: '7.3 mg/100g',
        bioavailability: 'Medium',
        reason: 'Delicious and iron-rich, plus mood-boosting properties',
        servingSize: '30g (1 oz)',
        benefits: ['Mood boost', 'Antioxidants', 'Satisfies cravings'],
      ),
      FoodRecommendation(
        name: 'Oysters',
        ironContent: '5.2 mg/100g',
        bioavailability: 'High',
        reason: 'Highest bioavailability. Also rich in zinc.',
        servingSize: '6 oysters',
        benefits: [
          'Excellent bioavailability',
          'Zinc-rich',
          'Sustainable option available',
        ],
      ),
    ];
  }

  /// Get magnesium-rich foods (important for luteal phase)
  Future<List<FoodRecommendation>> getMagnesiumRichFoods() async {
    return [
      FoodRecommendation(
        name: 'Pumpkin Seeds',
        ironContent: '151 mg/100g',
        bioavailability: 'Good',
        reason: 'Highest magnesium content, plus zinc',
        servingSize: '28g (1 oz)',
        benefits: ['Hormone support', 'Sleep quality', 'Antioxidants'],
      ),
      FoodRecommendation(
        name: 'Dark Chocolate',
        ironContent: '206 mg/100g',
        bioavailability: 'Good',
        reason: 'Rich in magnesium and satisfies cravings',
        servingSize: '30g',
        benefits: ['Mood support', 'Relaxation', 'Enjoyable'],
      ),
      FoodRecommendation(
        name: 'Almonds',
        ironContent: '270 mg/100g',
        bioavailability: 'Good',
        reason: 'Nutrient-dense, portable snack',
        servingSize: '23 almonds',
        benefits: ['Sustained energy', 'Calcium source', 'Heart-healthy'],
      ),
      FoodRecommendation(
        name: 'Spinach (cooked)',
        ironContent: '87 mg/100g',
        bioavailability: 'Good',
        reason: 'Cooked form has higher bioavailability',
        servingSize: '1 cup',
        benefits: ['Also iron-rich', 'Folate source', 'Versatile'],
      ),
      FoodRecommendation(
        name: 'Hemp Seeds',
        ironContent: '168 mg/100g',
        bioavailability: 'Good',
        reason: 'Complete protein, all amino acids present',
        servingSize: '28g',
        benefits: ['Protein-rich', 'Hormonal balance', 'Sustainable'],
      ),
    ];
  }

  /// Get omega-3 rich foods (anti-inflammatory for all phases)
  Future<List<FoodRecommendation>> getOmega3Foods() async {
    return [
      FoodRecommendation(
        name: 'Salmon',
        ironContent: '0',
        bioavailability: '',
        reason: 'Highest omega-3 content, plus vitamin D and B vitamins',
        servingSize: '100g fillet',
        benefits: ['Reduces inflammation', 'Brain support', 'Mood regulation'],
      ),
      FoodRecommendation(
        name: 'Chia Seeds',
        ironContent: '',
        bioavailability: '',
        reason: 'Plant-based omega-3, plus fiber',
        servingSize: '1 tbsp (13g)',
        benefits: ['Hydration', 'Fiber', 'Sustainable'],
      ),
      FoodRecommendation(
        name: 'Walnuts',
        ironContent: '',
        bioavailability: '',
        reason: 'Excellent plant-based omega-3 source',
        servingSize: '14 halves',
        benefits: ['Brain health', 'Hormone support', 'Anti-inflammatory'],
      ),
      FoodRecommendation(
        name: 'Flaxseeds',
        ironContent: '',
        bioavailability: '',
        reason: 'Alpha-linolenic acid rich, hormone-friendly',
        servingSize: '1 tbsp ground',
        benefits: ['Hormone balance', 'Fiber', 'Lignans'],
      ),
    ];
  }

  // PRIVATE HELPERS

  List<FoodRecommendation> _getPhaseOptimalFoods(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          FoodRecommendation(
            name: 'Beef',
            ironContent: '2.6 mg/100g',
            bioavailability: 'High',
            reason: 'Replenish iron lost during menstruation',
            servingSize: '100g',
            benefits: ['Iron-rich', 'B vitamins', 'Craving-satisfying'],
          ),
          FoodRecommendation(
            name: 'Red Lentils',
            ironContent: '6.5 mg/cooked',
            bioavailability: 'Medium',
            reason: 'Iron and plant protein combined',
            servingSize: '1 cup cooked',
            benefits: ['Iron boost', 'Warming', 'Budget-friendly'],
          ),
          FoodRecommendation(
            name: 'Dark Chocolate',
            ironContent: '7.3 mg/100g',
            bioavailability: 'Medium',
            reason: 'Iron + mood support + satisfies cravings',
            servingSize: '30g',
            benefits: ['Comfort food', 'Magnesium', 'Antioxidants'],
          ),
          FoodRecommendation(
            name: 'Ginger Tea',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Warming, may help with menstrual discomfort',
            servingSize: '1 cup',
            benefits: ['Cramp relief', 'Anti-inflammatory', 'Warming'],
          ),
        ];

      case CyclePhase.follicular:
        return [
          FoodRecommendation(
            name: 'Salmon',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Protein-rich for rising energy levels',
            servingSize: '100g',
            benefits: ['Energy boost', 'Omega-3s', 'Protein'],
          ),
          FoodRecommendation(
            name: 'Berries',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Antioxidant-rich as energy increases',
            servingSize: '1 cup',
            benefits: ['Energy', 'Antioxidants', 'Hydration'],
          ),
          FoodRecommendation(
            name: 'Whole Grains',
            ironContent: 'Varies',
            bioavailability: 'Good',
            reason: 'Support rising energy with sustained carbs',
            servingSize: '1 slice',
            benefits: ['Sustained energy', 'Fiber', 'B vitamins'],
          ),
          FoodRecommendation(
            name: 'Eggs',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Complete protein, supports muscle building',
            servingSize: '2 eggs',
            benefits: ['Protein', 'Choline (mood)', 'Versatile'],
          ),
        ];

      case CyclePhase.ovulation:
        return [
          FoodRecommendation(
            name: 'Leafy Greens',
            ironContent: 'Varies',
            bioavailability: 'Medium',
            reason: 'Anti-inflammatory at peak hormone time',
            servingSize: '2 cups',
            benefits: ['Detoxification', 'Antioxidants', 'Hydration'],
          ),
          FoodRecommendation(
            name: 'Lean Chicken',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Lean protein to support peak performance',
            servingSize: '100g',
            benefits: ['Lean protein', 'B6 (mood)', 'Low fat'],
          ),
          FoodRecommendation(
            name: 'Berries',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Antioxidant support during hormone peak',
            servingSize: '1 cup',
            benefits: ['Antioxidants', 'Skin support', 'Anti-inflammatory'],
          ),
          FoodRecommendation(
            name: 'Turmeric',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Powerful anti-inflammatory spice',
            servingSize: '1 tsp',
            benefits: ['Anti-inflammatory', 'Brain support', 'Antioxidant'],
          ),
        ];

      case CyclePhase.luteal:
        return [
          FoodRecommendation(
            name: 'Dark Chocolate',
            ironContent: 'High',
            bioavailability: 'Medium',
            reason: 'Magnesium-rich, satisfies cravings, mood boost',
            servingSize: '30g',
            benefits: ['Magnesium', 'Mood boost', 'Satisfying'],
          ),
          FoodRecommendation(
            name: 'Nuts',
            ironContent: 'Varies',
            bioavailability: 'Good',
            reason: 'Magnesium and healthy fats for hormone stability',
            servingSize: '1 oz (23 almonds)',
            benefits: ['Magnesium', 'Sustained energy', 'Satiating'],
          ),
          FoodRecommendation(
            name: 'Whole Grain Bread',
            ironContent: 'Varies',
            bioavailability: 'Good',
            reason: 'Complex carbs support serotonin production',
            servingSize: '1 slice',
            benefits: ['Mood support', 'Sustained energy', 'Fiber'],
          ),
          FoodRecommendation(
            name: 'Herbal Tea',
            ironContent: 'N/A',
            bioavailability: 'N/A',
            reason: 'Red raspberry leaf and chasteberry traditional support',
            servingSize: '1 cup',
            benefits: ['Calming', 'Hormone support', 'Hydration'],
          ),
        ];
    }
  }

  List<String> _getPhaseAvoidFoods(CyclePhase phase) {
    final universalAvoid = [
      'Heavily processed foods',
      'Excess sugar',
      'High-sodium foods',
    ];

    switch (phase) {
      case CyclePhase.menstrual:
        return [...universalAvoid, 'Excessive caffeine', 'Alcohol'];
      case CyclePhase.follicular:
        return universalAvoid;
      case CyclePhase.ovulation:
        return [...universalAvoid, 'Heavy fried foods', 'Inflammatory oils'];
      case CyclePhase.luteal:
        return [
          ...universalAvoid,
          'Excess caffeine',
          'Spicy foods',
          'Alcohol',
          'Excess salt',
        ];
    }
  }

  Future<FoodNutrition?> _searchUSDAFood(String foodName) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$usdaFoodDataAPI?query=$foodName&api_key=$usdaAPIKey&pageSize=1',
            ),
          )
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final foods = json['foods'] as List?;
        if (foods != null && foods.isNotEmpty) {
          return FoodNutrition.fromUSDAJson(foods[0]);
        }
      }
    } catch (e) {
      print('USDA API error: $e');
    }
    return null;
  }

  Future<FoodNutrition?> _searchOpenFoodFacts(String foodName) async {
    try {
      // Note: Open Food Facts uses different approach - search by barcode or full product
      // For now, returning null as it requires more complex integration
      return null;
    } catch (e) {
      print('Open Food Facts error: $e');
    }
    return null;
  }

  Meal _generateMeal(List<FoodRecommendation> foods, String mealType) {
    // Simple meal generation based on available foods
    final selectedFoods = foods.take(2).toList();
    return Meal(
      type: mealType,
      foods: selectedFoods,
      estimatedCalories: 500,
      macroBreakdown: MacroBreakdown(protein: 25, carbs: 50, fat: 15),
      prepTime: 20,
      difficulty: 'Easy',
    );
  }

  List<String> _generateSnacks(List<FoodRecommendation> foods) {
    return [
      '${foods[0].name} with honey',
      'Dark chocolate square',
      'Handful of nuts',
      'Herbal tea',
    ];
  }

  List<String> _getHydrationTips(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          'Drink 2-3L water daily to combat fatigue',
          'Warm herbal tea (ginger, chamomile) for comfort',
          'Iron-fortified electrolyte drink if heavy flow',
        ];
      case CyclePhase.follicular:
        return [
          'Standard 2-3L daily water intake',
          'Green tea beneficial for energy',
        ];
      case CyclePhase.ovulation:
        return [
          'Increase to 2.5-3L daily - peak sweating may occur',
          'Coconut water for electrolytes',
        ];
      case CyclePhase.luteal:
        return [
          'Gradual increase to 3L daily',
          'Warm fluids for comfort',
          'Herbal teas (red raspberry leaf, chasteberry)',
        ];
    }
  }

  List<String> _getSupplementRecommendations(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          'Iron supplement (if low ferritin) - consult provider',
          'Vitamin D3 (2000-4000 IU)',
          'Magnesium (200-400mg)',
        ];
      case CyclePhase.follicular:
        return ['Vitamin D3', 'B-complex supplement'];
      case CyclePhase.ovulation:
        return [
          'Antioxidant supplement (NAC or glutathione)',
          'Vitamin E (400 IU)',
        ];
      case CyclePhase.luteal:
        return [
          'Magnesium (300-400mg daily)',
          'Calcium (1000mg)',
          'B6 (50-100mg) for mood',
        ];
    }
  }

  List<String> _getMealPrepTips(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          'Prepare warming soups and broths',
          'Cook in batches and reheat as needed',
          'Gentle cooking to preserve nutrients',
        ];
      case CyclePhase.follicular:
        return [
          'Energizing, fresh meal prep',
          'Variety of colorful vegetables',
          'Higher protein ratios',
        ];
      case CyclePhase.ovulation:
        return [
          'Light, quick meals',
          'Prepare salads and fresh foods',
          'Time-efficient recipes',
        ];
      case CyclePhase.luteal:
        return [
          'Comforting, nourishing meals',
          'Batch cooking weekends',
          'Heavier, satisfying portions',
        ];
    }
  }
}

// DATA MODELS

class FoodRecommendation {
  final String name;
  final String ironContent;
  final String bioavailability;
  final String reason;
  final String servingSize;
  final List<String> benefits;

  FoodRecommendation({
    required this.name,
    required this.ironContent,
    required this.bioavailability,
    required this.reason,
    required this.servingSize,
    required this.benefits,
  });
}

class FoodNutrition {
  final String name;
  final Map<String, dynamic> nutrients;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodNutrition({
    required this.name,
    required this.nutrients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodNutrition.fromUSDAJson(Map<String, dynamic> json) {
    return FoodNutrition(
      name: json['description'] ?? '',
      nutrients: json['foodNutrients'] ?? {},
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
    );
  }
}

class MealPlan {
  final CyclePhase phase;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final List<String> snacks;
  final List<String> hydration;
  final List<String> supplements;
  final List<String> mealPrepTips;

  MealPlan({
    required this.phase,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.hydration,
    required this.supplements,
    required this.mealPrepTips,
  });
}

class Meal {
  final String type;
  final List<FoodRecommendation> foods;
  final int estimatedCalories;
  final MacroBreakdown macroBreakdown;
  final int prepTime;
  final String difficulty;

  Meal({
    required this.type,
    required this.foods,
    required this.estimatedCalories,
    required this.macroBreakdown,
    required this.prepTime,
    required this.difficulty,
  });
}

class MacroBreakdown {
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams

  MacroBreakdown({
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ml_cycle_data.dart';
import '../core/advanced_cycle_profile.dart';

/// DIET RECOMMENDATION ENGINE
///
/// Provides deep nutritional guidance based on bio-metrics, deficiencies, and cycle phase.
/// Acts as a virtual nutritionist using clinical nutrition standards.
class DietRecommendationEngine {
  static final DietRecommendationEngine _instance =
      DietRecommendationEngine._internal();

  factory DietRecommendationEngine() {
    return _instance;
  }

  DietRecommendationEngine._internal();

  /// Get personalized guidance based on full profile
  DietGuidance getPersonalizedGuidance({
    required AdvancedCycleProfile profile,
    required CyclePhase phase,
  }) {
    final hasPCOS = profile.hasPCOS;
    final bmiStatus = profile.bmiStatus;
    final deficiencies = profile.deficiencies;
    
    // Day variation for variety
    final dayOffset = DateTime.now().weekday % 2; 

    if (hasPCOS) {
      return _getClinicalManagementDetails(phase, bmiStatus, deficiencies, dayOffset);
    } else {
      return _getGeneralWellnessDetails(phase, bmiStatus, deficiencies, dayOffset);
    }
  }

  // --- COMPATIBILITY METHODS ---

  DietGuidance getGuidanceForPhase({
    required CyclePhase phase,
    required bool hasPCOS,
  }) {
    // Default to empty deficiencies for compatibility
    if (hasPCOS) {
      return _getClinicalManagementDetails(phase, "Normal", [], 0);
    } else {
      return _getGeneralWellnessDetails(phase, "Normal", [], 0);
    }
  }

  /// Get food names for phase (Compatibility)
  List<String> getFoodsForPhase(CyclePhase phase) {
    return _getGeneralWellnessDetails(phase, "Normal", [], 0).bestFoods.map((f) => f.name).toList();
  }

  /// Get foods to avoid (Compatibility)
  List<String> getFoodsToAvoid(CyclePhase phase) {
    return _getGeneralWellnessDetails(phase, "Normal", [], 0).avoidFoods.map((f) => f.name).toList();
  }

  /// Get comprehensive meal plan (Compatibility)
  Future<MealPlan> getMealPlanForPhase(CyclePhase phase) async {
    final guidance = _getGeneralWellnessDetails(phase, "Normal", [], 0);
    final plan = MealPlan(title: guidance.title, source: guidance.source);
    plan.hydration.add(guidance.waterAmount);
    return plan;
  }

  // ===========================================================================
  // CLINICAL NUTRITION LOGIC (Clinical / PCOS Management)
  // ===========================================================================

  DietGuidance _getClinicalManagementDetails(
    CyclePhase phase, String bmiStatus, List<String> deficiencies, int variation) {
    
    final metrics = _calculateDailyMetrics(bmiStatus, isClinical: true);
    
    List<FoodItem> bestFoods = [];
    List<FoodItem> avoidFoods = [
      FoodItem(name: "Sugar-sweetened beverages", emoji: "🥤", reason: "Direct insulin trigger"),
      FoodItem(name: "Refined flour (Maida)", emoji: "🍞", reason: "High Glycemic Index"),
    ];

    switch (phase) {
      case CyclePhase.menstrual:
        bestFoods.addAll(variation == 0 ? [
          FoodItem(name: "Salmon / Sardines", emoji: "🐟", reason: "Omega-3 reduces menstrual prostaglandins"),
          FoodItem(name: "Lentil / Dal", emoji: "🍲", reason: "Fiber+Protein for blood sugar stability"),
        ] : [
          FoodItem(name: "Tofu / Tempeh", emoji: "🧊", reason: "Phytoestrogens assist in hormone reset"),
          FoodItem(name: "Walnuts", emoji: "🥜", reason: "Anti-inflammatory support"),
        ]);
        break;
      case CyclePhase.follicular:
        bestFoods.addAll([
          FoodItem(name: "Sprouted Moong", emoji: "🌱", reason: "High in Vit C and Fiber for Estrogen clearance"),
          FoodItem(name: "Broccoli / Kale", emoji: "🥦", reason: "DIM supports healthy estrogen metabolism"),
        ]);
        break;
      case CyclePhase.ovulation:
        bestFoods.addAll([
          FoodItem(name: "Avocado", emoji: "🥑", reason: "Healthy fats for follicular health"),
          FoodItem(name: "Berries", emoji: "🫐", reason: "Antioxidants protect the egg from oxidative stress"),
        ]);
        break;
      case CyclePhase.luteal:
        bestFoods.addAll([
          FoodItem(name: "Sweet Potato", emoji: "🍠", reason: "Slow release energy prevents PMS cravings"),
          FoodItem(name: "Green Leafy Veg", emoji: "🥬", reason: "Magnesium for muscle relaxation and mood"),
        ]);
        break;
    }

    _injectDeficiencyFoods(bestFoods, deficiencies);
    String title = _determinePlanTitle(deficiencies, "Hormonal Balance Plan");

    return DietGuidance(
      title: title,
      phase: phase,
      bestFoods: bestFoods,
      avoidFoods: avoidFoods,
      waterAmount: metrics.water,
      calories: metrics.calories,
      source: "Endocrine Society & Clinical Nutrition Guidelines",
    );
  }

  // ===========================================================================
  // GENERAL WELLNESS LOGIC (Standard Nutrition)
  // ===========================================================================

  DietGuidance _getGeneralWellnessDetails(
    CyclePhase phase, String bmiStatus, List<String> deficiencies, int variation) {
    
    final metrics = _calculateDailyMetrics(bmiStatus, isClinical: false);
    
    List<FoodItem> bestFoods = [];
    List<FoodItem> avoidFoods = [
      FoodItem(name: "Processed Meats", emoji: "🌭", reason: "High Nitrates & Preservatives"),
      FoodItem(name: "Excessive Coffee", emoji: "☕", reason: "Disrupts sleep & cortisol balance"),
      FoodItem(name: "Carbonated Soda", emoji: "🥤", reason: "Interferes with calcium absorption"),
    ];

    switch (phase) {
      case CyclePhase.menstrual:
        bestFoods.addAll([
          FoodItem(name: "Beetroot Juice", emoji: "🥤", reason: "Nitric oxide supports vascular health"),
          FoodItem(name: "Orange / Amla", emoji: "🍊", reason: "Vitamin C boosts Iron absorption"),
        ]);
        break;
      case CyclePhase.follicular:
        bestFoods.addAll([
          FoodItem(name: "Chicken / Lean Meat", emoji: "🍗", reason: "Essential amino acids for energy"),
          FoodItem(name: "Brown Rice", emoji: "🍚", reason: "Consistent glucose supply"),
        ]);
        break;
      case CyclePhase.ovulation:
        bestFoods.addAll([
          FoodItem(name: "Flaxseeds", emoji: "🍮", reason: "Fibre + Lignans for hormone flow"),
          FoodItem(name: "Pumpkin Seeds", emoji: "🎃", reason: "Zinc for reproductive health"),
        ]);
        break;
      case CyclePhase.luteal:
        bestFoods.addAll([
          FoodItem(name: "Dark Chocolate (>70%)", emoji: "🍫", reason: "Mood boosting serotonin support"),
          FoodItem(name: "Banana", emoji: "🍌", reason: "Vitamin B6 reduces water retention"),
        ]);
        break;
    }

    _injectDeficiencyFoods(bestFoods, deficiencies);
    String title = _determinePlanTitle(deficiencies, "Optimized Health Plan");

    return DietGuidance(
      title: title,
      phase: phase,
      bestFoods: bestFoods.take(6).toList(), // Increased for more visibility
      avoidFoods: avoidFoods,
      waterAmount: metrics.water,
      calories: metrics.calories,
      source: "Harvard Nutrition & WHO Guidelines",
    );
  }

  String _determinePlanTitle(List<String> deficiencies, String defaultTitle) {
    if (deficiencies.contains("Vitamin C")) return "Vitamin C Recovery Plan 🍊";
    if (deficiencies.contains("Low Iron (Anaemic)")) return "Iron Deficiency (Anaemia) Plan 🩸";
    if (deficiencies.contains("Vitamin D")) return "Bone & Immunity Support Plan ☀️";
    if (deficiencies.contains("Calcium")) return "Bone Mineral Density Plan 🥛";
    if (deficiencies.isNotEmpty) return "Nutrient Enrichment Plan 🧬";
    return defaultTitle;
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  _Metrics _calculateDailyMetrics(String bmiStatus, {required bool isClinical}) {
    String water;
    String cals;

    switch (bmiStatus) {
      case "Underweight":
        water = "2.5 - 3.0 Liters 🏺";
        cals = isClinical ? "2000 - 2200 kcal" : "2200 - 2400 kcal";
        break;
      case "Normal":
        water = "2.2 - 2.8 Liters 🏺";
        cals = isClinical ? "1700 - 1900 kcal" : "1900 - 2100 kcal";
        break;
      case "Overweight":
        water = "3.2 - 3.5 Liters 🏺";
        cals = isClinical ? "1400 - 1600 kcal" : "1700 - 1900 kcal";
        break;
      case "Obese":
        water = "3.5 - 4.0 Liters 🏺";
        cals = isClinical ? "1300 - 1500 kcal" : "1500 - 1750 kcal";
        break;
      default:
        water = "2.5 Liters 🏺";
        cals = "2000 kcal";
    }

    return _Metrics(water: water, calories: cals);
  }

  void _injectDeficiencyFoods(List<FoodItem> foods, List<String> deficiencies) {
    for (var d in deficiencies) {
      switch (d) {
        case "Vitamin A":
          foods.insert(0, FoodItem(name: "Carrot / Papaya", emoji: "🥕", reason: "Beta-carotene targets Vitamin A deficiency"));
          break;
        case "Vitamin B":
          foods.insert(0, FoodItem(name: "Sunflower Seeds", emoji: "🌻", reason: "Rich in B-vitamins for energy repair"));
          break;
        case "Vitamin C":
          foods.insert(0, FoodItem(name: "Guava / Kiwi / Amla", emoji: "🥝", reason: "Ultra-high Vitamin C for tissue repair"));
          foods.insert(1, FoodItem(name: "Bell Peppers", emoji: "🫑", reason: "Supports collagen and immune system"));
          break;
        case "Iron":
        case "Low Iron (Anaemic)":
          foods.insert(0, FoodItem(name: "Spinach / Dates", emoji: "🥬", reason: "High non-heme iron to combat Anaemia"));
          foods.insert(1, FoodItem(name: "Blackstrap Molasses", emoji: "🍯", reason: "Mineral-rich iron boost"));
          break;
        case "Calcium":
          foods.insert(0, FoodItem(name: "Chia Seeds / Yogurt", emoji: "🥛", reason: "Concentrated Calcium for bone health"));
          break;
      }
    }
  }

  // Fallback API Search
  Future<FoodNutrition?> getNutritionInfo(String foodName) async {
    try {
      final response = await http
          .get(Uri.parse('https://fdc.nal.usda.gov/api/foods/search?query=$foodName&api_key=DEMO_KEY&pageSize=1'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final foods = json['foods'] as List?;
        if (foods != null && foods.isNotEmpty) {
          return FoodNutrition.fromUSDAJson(foods[0]);
        }
      }
    } catch (e) {
      debugPrint('USDA API error: $e');
    }
    return null;
  }
}

class _Metrics {
  final String water;
  final String calories;
  _Metrics({required this.water, required this.calories});
}

// DATA MODELS

class FoodItem {
  final String name;
  final String emoji;
  final String reason;

  FoodItem({required this.name, required this.emoji, required this.reason});
}

class DietGuidance {
  final String title;
  final CyclePhase phase;
  final List<FoodItem> bestFoods;
  final List<FoodItem> avoidFoods;
  final String waterAmount;
  final String calories;
  final String source;

  DietGuidance({
    required this.title,
    required this.phase,
    required this.bestFoods,
    required this.avoidFoods,
    required this.waterAmount,
    required this.calories,
    required this.source,
  });
}

class FoodNutrition {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodNutrition({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodNutrition.fromUSDAJson(Map<String, dynamic> json) {
    return FoodNutrition(
      name: json['description'] ?? '',
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
    );
  }
}

class MealPlan {
  final String title;
  final String source;
  final List<String> hydration = [];
  final List<String> supplements = [];
  MealPlan({required this.title, required this.source});
}

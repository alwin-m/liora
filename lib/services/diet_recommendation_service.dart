import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ml_cycle_data.dart';
import '../core/advanced_cycle_profile.dart';
import '../core/cycle_session.dart';

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
    int? dayInPhase,
  }) {
    final region = profile.region;
    final hasPCOS = profile.hasPCOS;
    final bmiStatus = profile.bmiStatus;
    final deficiencies = profile.deficiencies;
    
    // Variation based on phase day
    final dayOffset = dayInPhase ?? (DateTime.now().day % 3); 

    return _getRegionalGuidance(phase, region, hasPCOS, bmiStatus, deficiencies, dayOffset);
  }

  // --- COMPATIBILITY METHODS ---

  DietGuidance getGuidanceForPhase({
    required CyclePhase phase,
    required bool hasPCOS,
  }) {
    if (CycleSession.isInitialized) {
      final p = CycleSession.profile;
      return _getRegionalGuidance(phase, p.region, hasPCOS, p.bmiStatus, p.deficiencies, 0);
    }
    return _getRegionalGuidance(phase, "Global", hasPCOS, "Normal", [], 0);
  }

  /// Get food names for phase (Compatibility)
  List<String> getFoodsForPhase(CyclePhase phase) {
    if (CycleSession.isInitialized) {
      final p = CycleSession.profile;
      return _getRegionalGuidance(phase, p.region, p.hasPCOS, p.bmiStatus, p.deficiencies, 0).bestFoods.map((f) => f.name).toList();
    }
    return _getRegionalGuidance(phase, "Global", false, "Normal", [], 0).bestFoods.map((f) => f.name).toList();
  }

  /// Get foods to avoid (Compatibility)
  List<String> getFoodsToAvoid(CyclePhase phase) {
    if (CycleSession.isInitialized) {
      final p = CycleSession.profile;
      return _getRegionalGuidance(phase, p.region, p.hasPCOS, p.bmiStatus, p.deficiencies, 0).avoidFoods.map((f) => f.name).toList();
    }
    return _getRegionalGuidance(phase, "Global", false, "Normal", [], 0).avoidFoods.map((f) => f.name).toList();
  }

  /// Get comprehensive meal plan (Compatibility)
  Future<MealPlan> getMealPlanForPhase(CyclePhase phase) async {
    final guidance = CycleSession.isInitialized 
      ? _getRegionalGuidance(phase, CycleSession.profile.region, CycleSession.profile.hasPCOS, CycleSession.profile.bmiStatus, CycleSession.profile.deficiencies, 0)
      : _getRegionalGuidance(phase, "Global", false, "Normal", [], 0);
    final plan = MealPlan(title: guidance.title, source: guidance.source);
    plan.hydration.add(guidance.waterAmount);
    return plan;
  }

  // ===========================================================================
  // REGIONAL GUIDANCE LOGIC
  // ===========================================================================

  DietGuidance _getRegionalGuidance(
    CyclePhase phase, String region, bool hasPCOS, String bmiStatus, List<String> deficiencies, int dayOffset) {
    
    final metrics = _calculateDailyMetrics(bmiStatus, isClinical: hasPCOS);
    List<FoodItem> bestFoods = [];
    List<FoodItem> avoidFoods = [];

    // 1. Regional Base Foods
    switch (region) {
      case "Kerala":
        bestFoods.addAll(_getKeralaFoods(phase, dayOffset));
        avoidFoods.addAll([
          FoodItem(name: "Excessive Green Chili", emoji: "🌶️", reason: "Increases internal heat; can worsen cramps"),
          FoodItem(name: "Strong Garam Masala", emoji: "🥘", reason: "Can lead to acidity during flow"),
          FoodItem(name: "Highly Refined Sugar", emoji: "🍬", reason: "Bad for insulin, especially in PCOD"),
          FoodItem(name: "Oily Snacks (Fried)", emoji: "🥨", reason: "Pro-inflammatory during period"),
        ]);
        break;
      case "Germany":
        bestFoods.addAll(_getGermanFoods(phase, dayOffset));
        avoidFoods.addAll([
          FoodItem(name: "Heavy Sausages", emoji: "🌭", reason: "High saturated fat and nitrates"),
          FoodItem(name: "Beer / Alcohol", emoji: "🍺", reason: "Disrupts estrogen detoxification"),
        ]);
        break;
      case "USA":
        bestFoods.addAll(_getUSAFoods(phase, dayOffset));
        avoidFoods.addAll([
          FoodItem(name: "Ultra-processed snacks", emoji: "🥨", reason: "Disturbs hormonal signaling"),
          FoodItem(name: "Corn Syrup", emoji: "🌽", reason: "High fructose is linked to PCOS worsening"),
        ]);
        break;
      default:
        bestFoods.addAll(_getGlobalFoods(phase, dayOffset));
    }

    // 2. PCOS / Clinical Adjustments
    if (hasPCOS) {
      bestFoods.insert(0, FoodItem(name: "Spearmint & Ginger Tea", emoji: "🍵", reason: "Anti-androgen + Pain relief combo"));
      avoidFoods.add(FoodItem(name: "High GI Foods", emoji: "🍞", reason: "Critical for insulin resistance management"));
    }

    // 3. Deficiency Injections
    _injectDeficiencyFoods(bestFoods, deficiencies);

    return DietGuidance(
      title: _determinePlanTitle(deficiencies, "$region ${hasPCOS ? 'Clinical' : 'Wellness'} Plan - Day $dayOffset"),
      phase: phase,
      bestFoods: bestFoods,
      avoidFoods: avoidFoods,
      waterAmount: metrics.water,
      calories: metrics.calories,
      source: region == "Kerala" ? "Ayurvedic + Kerala Dietary Traditions" : "Harvard Health & Local Guidelines",
    );
  }

  // ===========================================================================
  // REGIONAL FOOD PROVIDERS
  // ===========================================================================

  // ===========================================================================
  // REGIONAL FOOD PROVIDERS
  // ===========================================================================

  List<FoodItem> _getKeralaFoods(CyclePhase phase, int day) {
    if (phase == CyclePhase.menstrual) {
      // 7-DAY DETAILED KERALA MENSTRUAL PLAN
      switch (day % 7) {
        case 1:
          return [
            FoodItem(name: "Appam & Veg Stew", emoji: "🥘", reason: "Light coconut-based stew is gentle on digeston during flow"),
            FoodItem(name: "Rice & Sardine (Mathi) Curry", emoji: "🐟", reason: "Rich in Omega-3 to actively reduce menstrual cramps"),
            FoodItem(name: "Jeeraka Vellam (Cumin water)", emoji: "🏺", reason: "Traditional aid for bloating and gas relief"),
          ];
        case 2:
          return [
            FoodItem(name: "Ragi Puttu & Cherupayaru", emoji: "🥥", reason: "Ragi (Finger Millet) is world-renowned for Iron recovery"),
            FoodItem(name: "Brown Rice & Moru Curry", emoji: "🍛", reason: "Probiotics in buttermilk help hormonal balance"),
            FoodItem(name: "Turmeric Milk (Manjal Pal)", emoji: "🥛", reason: "Strong anti-inflammatory to soothe pelvic pain"),
          ];
        case 3:
          return [
            FoodItem(name: "Idli & Sambar (with Drumsticks)", emoji: "🥞", reason: "Drumsticks are high in Calcium & Iron minerals"),
            FoodItem(name: "Beetroot Thoran & Egg Roast", emoji: "🥚", reason: "Vitamin B12 and folate for new blood cell production"),
            FoodItem(name: "Tender Coconut Water", emoji: "🥥", reason: "Electrolytes to prevent period-related headaches"),
          ];
        case 4:
          return [
            FoodItem(name: "Wheat Puttu & Kadala Curry", emoji: "🫘", reason: "Zinc in chickpeas supports skin health during flow"),
            FoodItem(name: "Kappa & Fish Curry (Kudampuli)", emoji: "🐠", reason: "Malabar Tamarind (Kudampuli) boosts metabolism"),
            FoodItem(name: "Pazham Puzhingiyathu (Steam Banana)", emoji: "🍌", reason: "High Potassium reduces uterine muscle contractions"),
          ];
        case 5:
          return [
            FoodItem(name: "Uppumavu with Carrots", emoji: "🍲", reason: "Gentle fiber supports healthy estrogen clearout"),
            FoodItem(name: "Rice, Dal & Avial", emoji: "🥗", reason: "Diverse vegetables provide vitamins A, C, and E"),
            FoodItem(name: "Fenugreek (Uluva) Kanji", emoji: "🥣", reason: "Cools the body and supports uterine recovery"),
          ];
        case 6:
          return [
            FoodItem(name: "Idiyappam & Egg Curry", emoji: "🥚", reason: "Light protein for tissue repair and strength"),
            FoodItem(name: "Rice & Pavakka Fry", emoji: "🥒", reason: "Bittergourd purifies blood and balances insulin"),
            FoodItem(name: "Jaggery & Roasted Gram", emoji: "🥜", reason: "Concentrated Iron to replenish blood loss"),
          ];
        case 0:
        default:
          return [
            FoodItem(name: "Dosa & Coconut Chutney", emoji: "🥞", reason: "Easy to digest carbs for the final flow day"),
            FoodItem(name: "Mackerel Fry & Rice", emoji: "🐠", reason: "Rich in Vitamin D and high-quality protein"),
            FoodItem(name: "Papaya", emoji: "🥭", reason: "Natural enzymes support the clearing of uterus"),
          ];
      }
    }

    // Wellness Phases for Kerala
    switch (phase) {
      case CyclePhase.follicular:
        return day % 2 == 0 
          ? [FoodItem(name: "Idiyappam & Stew", emoji: "🌫️", reason: "Light energy for rising estrogen levels")]
          : [FoodItem(name: "Pathiri & Chicken Curry", emoji: "🥘", reason: "Lean protein for lean tissue building")];
      case CyclePhase.ovulation:
        return [
          FoodItem(name: "Rice & Sambar", emoji: "🍛", reason: "Balanced minerals for peak hormonal energy"),
          FoodItem(name: "Nendran Banana", emoji: "🍌", reason: "Antioxidants for egg health support"),
        ];
      case CyclePhase.luteal:
        return day % 2 == 0
          ? [FoodItem(name: "Ela Ada (Jaggery & Rice)", emoji: "🍃", reason: "Healthy complex carbs for luteal hunger")]
          : [FoodItem(name: "Wheat Dosa", emoji: "🥞", reason: "Higher fiber to prevent pre-period bloating")];
      default:
        return [];
    }
  }

  List<FoodItem> _getGermanFoods(CyclePhase phase, int day) {
    if (phase == CyclePhase.menstrual) {
      return day % 2 == 0 
        ? [FoodItem(name: "Lentil Soup (Linseneintopf)", emoji: "🍲", reason: "Classic iron-rich comforting meal")]
        : [FoodItem(name: "Rye Bread with Boiled Egg", emoji: "🍞", reason: "Full range of B-vitamins for energy")];
    }
    switch (phase) {
      case CyclePhase.follicular:
        return [FoodItem(name: "Sauerkraut & Potatoes", emoji: "🥔", reason: "Probiotics clear excess hormones")];
      case CyclePhase.ovulation:
        return [FoodItem(name: "Muesli with Berries", emoji: "🥣", reason: "Antioxidant boost for ovulation")];
      case CyclePhase.luteal:
        return [
          FoodItem(name: "Quark with Flaxseeds", emoji: "🍦", reason: "Progesterone support + Omega-3s"),
          FoodItem(name: "Dark Chocolate (>70%)", emoji: "🍫", reason: "Magnesium to ease PMS tension"),
        ];
      default: return [];
    }
  }

  List<FoodItem> _getUSAFoods(CyclePhase phase, int day) {
    if (phase == CyclePhase.menstrual) {
      return day % 2 == 0 
        ? [FoodItem(name: "Grilled Salmon & Spinach", emoji: "🍣", reason: "Omega-3 and Iron combo for pain and recovery")]
        : [FoodItem(name: "Oatmeal with Walnuts", emoji: "🥣", reason: "B-vitamins and magnesium for mood")];
    }
    switch (phase) {
      case CyclePhase.follicular:
        return [FoodItem(name: "Avocado Toast on Whole Wheat", emoji: "🥑", reason: "Healthy fats for follicular growth")];
      case CyclePhase.ovulation:
        return [FoodItem(name: "Mixed Green Salad with Seeds", emoji: "🥗", reason: "Zinc and minerals for peak health")];
      case CyclePhase.luteal:
        return [
          FoodItem(name: "Roasted Sweet Potatoes", emoji: "🍠", reason: "Complex carbs stabilize luteal mood"),
          FoodItem(name: "Almonds & Dark Chocolate", emoji: "🍫", reason: "Magnesium reduces pre-period cramps"),
        ];
      default: return [];
    }
  }

  List<FoodItem> _getGlobalFoods(CyclePhase phase, int day) {
    return _getUSAFoods(phase, day); // Fallback
  }

  /// Get the clinical focus of the current phase
  String getPhaseFocus(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Iron & B-Vitamin Replenishment 🩸";
      case CyclePhase.follicular: return "Nutrient-Dense Building & Recovery 🌱";
      case CyclePhase.ovulation: return "Antioxidant Support & Mineral Balance ✨";
      case CyclePhase.luteal: return "Magnesium & Complex Carb Stability 🌙";
    }
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
        water = "2.8 - 3.2 L 🏺";
        cals = isClinical ? "2000 - 2200 kcal" : "2200 - 2400 kcal";
        break;
      case "Normal":
        water = "2.5 - 3.0 L 🏺";
        cals = isClinical ? "1700 - 1920 kcal" : "1900 - 2100 kcal";
        break;
      case "Overweight":
        water = "3.2 - 3.8 L 🏺";
        cals = isClinical ? "1400 - 1650 kcal" : "1700 - 1900 kcal";
        break;
      case "Obese":
        water = "3.5 - 4.2 L 🏺";
        cals = isClinical ? "1300 - 1500 kcal" : "1500 - 1750 kcal";
        break;
      default:
        water = "2.5 L 🏺";
        cals = "2000 kcal";
    }

    return _Metrics(water: water, calories: cals);
  }

  void _injectDeficiencyFoods(List<FoodItem> foods, List<String> deficiencies) {
    for (var d in deficiencies) {
      switch (d) {
        case "Vitamin A":
          foods.insert(0, FoodItem(name: "Carrot / Papaya / Mango", emoji: "🥭", reason: "Rich in Vitamin A for visual and skin health"));
          break;
        case "Vitamin B":
          foods.insert(0, FoodItem(name: "Sunflower Seeds / Whole Grains", emoji: "🌻", reason: "B-vitamins support cellular energy"));
          break;
        case "Vitamin C":
          foods.insert(0, FoodItem(name: "Guava / Amla / Kiwi", emoji: "🥝", reason: "Superior Vitamin C for iron uptake"));
          break;
        case "Vitamin D":
          foods.insert(0, FoodItem(name: "Cod Liver Oil / Mushrooms", emoji: "🍄", reason: "Vitamin D for hormonal precursor support"));
          break;
        case "Iron":
        case "Low Iron (Anaemic)":
          foods.insert(0, FoodItem(name: "Spinach / Dates / Jaggery", emoji: "🍯", reason: "Combatting iron-depletion from flow"));
          break;
        case "Calcium":
          foods.insert(0, FoodItem(name: "Yogurt / Seaweed", emoji: "🥛", reason: "Bone mineral density support"));
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

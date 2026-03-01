# 🏗 LIORA ML Architecture Reference

Complete technical specification for the TensorFlow Lite ML system integrated into LIORA.

---

## 📐 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         LIORA Flutter App                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────┐        ┌──────────────────────────────┐  │
│  │   User Interface     │        │   Data Input Screens         │  │
│  ├──────────────────────┤        ├──────────────────────────────┤  │
│  │ - Calendar Screen    │◄──────►│ - Bleeding Tracker           │  │
│  │ - AI Insights Panel  │        │ - Symptom Logger             │  │
│  │ - Health Dashboard   │        │ - Mood & Energy             │  │
│  └──────────────────────┘        │ - Health Habits              │  │
│           ▲                       └──────────────────────────────┘  │
│           │                                  │                      │
│           │                                  ▼                      │
│           │                       ┌──────────────────────────────┐  │
│           │                       │   CycleProvider              │  │
│           │                       │ (State Management)           │  │
│           │                       ├──────────────────────────────┤  │
│           │                       │ - lastPeriodDate             │  │
│           │                       │ - estimatedCycleLength       │  │
│           │                       │ - cycleHistory[]             │  │
│           └──────────────────────►│ - predictCycleWithML()       │  │
│                                   │ - logBleedingData()          │  │
│                                   │ - logSymptom()               │  │
│                                   │ - logMood()                  │  │
│                                   │ - logHealthData()            │  │
│                                   └──────────────────────────────┘  │
│                                              ▲                      │
│                                              │                      │
│           ┌─────────────────────────────────┼────────────────┐     │
│           │                                  │                │     │
│           ▼                                  ▼                ▼     │
│  ┌─────────────────────┐    ┌──────────────────────┐  ┌──────────┐ │
│  │ MLInferenceService  │    │DietRecommendation    │  │AIService │  │
│  ├─────────────────────┤    │Service               │  ├──────────┤  │
│  │ - initialize()      │    ├──────────────────────┤  │(Cloud/   │  │
│  │ - predictCycle()    │    │ -getFoodsForPhase()  │  │Local AI) │  │
│  │ - updatePersonal    │    │ -getNutritionInfo()  │  └──────────┘  │
│  │  Model()            │    │ -getMealPlanForPhase │                │
│  │ - _normalizeFeatures│    │ -getIronRichFoods()  │                │
│  │ - _runInference()   │    │ -etc.                │                │
│  └─────────────────────┘    └──────────────────────┘                │
│           │                           │                             │
└───────────┼───────────────────────────┼─────────────────────────────┘
            │                           │
            │                    ┌──────┴──────┐
            │                    │ (Free APIs) │
            │                    ├─────────────┤
            │                    │ USDA Food   │
            │                    │ Open Food   │
            │                    │ Facts       │
            │                    └─────────────┘
            │
     ┌──────┴────────┐
     │  TensorFlow   │
     │  Lite Model   │
     ├───────────────┤
     │ .tflite file  │
     │ (<20MB)       │
     │ Quantized     │
     │ CPU-optimized │
     └───────────────┘
```

---

## 🔄 Data Flow: Prediction Pipeline

```
1. USER LOGS DATA
   ├─ Logs bleeding data (BleedingTrackerScreen)
   ├─ Logs symptoms (SymptomTrackerScreen)
   ├─ Logs mood/energy (MoodEnergyScreen)
   └─ Logs health habits (HealthHabitsScreen)
        │
        ▼
2. STATE UPDATE
   └─ CycleProvider receives & stores data
        │
        ▼
3. BUILD ML DATA MODEL
   └─ Convert CycleProvider data → CycleMLDataModel
        │
        ├─ lastPeriodStart, lastPeriodEnd
        ├─ cycleLength, periodLength
        ├─ bleedingPattern[]
        ├─ symptomHistory[]
        ├─ moodHistory[]
        ├─ healthHistory[]
        └─ temperatureData[]
        │
        ▼
4. EXTRACT FEATURES
   ├─ Calculate CycleDerivedFeatures
   │  ├─ cycleRegularity (0-1)
   │  ├─ bleedingIntensityVariance (0-1)
   │  ├─ symptomClusteringScore (0-1)
   │  ├─ moodVariation (0-1)
   │  ├─ energyVariation (0-1)
   │  ├─ stressImpactScore (0-1)
   │  ├─ historicalAccuracy (0-1)
   │  ├─ ovulationConsistency (0-1)
   │  ├─ cycleLengthStdDev (0-1)
   │  └─ symptomFrequency (map)
   │
   ├─ Normalize to 0-1 range:
   │  ├─ cycleLength norm: (length - 21) / 14
   │  ├─ periodLength norm: (length - 3) / 4
   │  └─ ...8 more features
   │
   └─ Result: 10-dimensional vector
        │
        ▼
5. APPLY PERSONAL WEIGHTS
   └─ Multiply features by PersonalModelWeights
      (learned from previous predictions)
        │
        ▼
6. RUN ML INFERENCE
   ├─ Load TensorFlow Lite interpreter
   ├─ Pass 10-dim feature vector as input
   ├─ Execute neural network
   └─ Receive outputs:
      ├─ period_date_offset (0-1 normalized days)
      ├─ confidence_score (0-1)
      ├─ phase_logits (4-dim softmax probabilities)
      └─ ovulation_probability (0-1)
        │
        ▼
7. POST-PROCESS PREDICTIONS
   ├─ Convert period_date_offset → calendar date
   ├─ Round confidence to 2 decimals
   ├─ Map phase_logits to CyclePhase (argmax)
   ├─ Generate phase-specific details
   │  ├─ CyclePhaseInfo
   │  ├─ PredictedBleedingInfo
   │  └─ OvulationPrediction
   ├─ Create human-readable insights
   ├─ Identify influencing factors
   └─ Generate personalized recommendations
        │
        ▼
8. PACKAGE RESULT
   └─ MLCyclePrediction object containing:
      ├─ nextPeriodDate
      ├─ confidenceScore
      ├─ phaseInfo (with all details)
      ├─ bleedingInfo
      ├─ ovulationInfo
      ├─ insightSummary
      ├─ influencingFactors[]
      ├─ personalizedRecommendations[]
      └─ predictionTimestamp
        │
        ▼
9. DISPLAY RESULTS
   ├─ Show CycleAIInsightsPanel (bottom sheet)
   ├─ Display in Calendar (color-coded days)
   ├─ Update Dashboard with predictions
   └─ Show diet recommendations (async FutureBuilder)
        │
        ▼
10. STORE & LEARN
    ├─ Cache prediction in SharedPreferences
    ├─ Store in local SQLite database
    └─ When user confirms period:
       └─ Run updatePersonalModel() to improve weights
```

---

## 📦 Data Model Hierarchy

```
CycleMLDataModel (ROOT)
├─ lastPeriodStart: DateTime
├─ lastPeriodEnd: DateTime
├─ cycleLength: int (days)
├─ periodLength: int (days)
│
├─ bleedingPattern: List<BleedingDay>
│  ├─ date: DateTime
│  ├─ intensity: IntensityLevel (enum)
│  │  ├─ light
│  │  ├─ medium
│  │  ├─ heavy
│  │  └─ spotting
│  ├─ color: BloodColor (enum)
│  │  ├─ brightRed
│  │  ├─ darkRed
│  │  ├─ brown
│  │  └─ pink
│  ├─ clots: bool
│  └─ spotValue: int (1-5)
│
├─ symptomHistory: List<SymptomEntry>
│  ├─ date: DateTime
│  └─ symptoms: List<CycleSymptomWithIntensity>
│     ├─ symptom: CycleSymptom (enum - 15 types)
│     │  ├─ cramps
│     │  ├─ bloating
│     │  ├─ headache
│     │  ├─ fatigue
│     │  ├─ breastTenderness
│     │  ├─ moodSwings
│     │  ├─ acne
│     │  ├─ nausea
│     │  ├─ backPain
│     │  ├─ constipation
│     │  ├─ diarrhea
│     │  ├─ cravings
│     │  ├─ waterRetention
│     │  ├─ concentrationDifficulty
│     │  └─ jointPain
│     └─ intensity: int (1-10)
│
├─ moodHistory: List<MoodEntry>
│  ├─ date: DateTime
│  ├─ moodScore: int (1-10)
│  ├─ moodCategory: MoodCategory (enum)
│  │  ├─ happy
│  │  ├─ sad
│  │  ├─ anxious
│  │  ├─ irritable
│  │  ├─ calm
│  │  ├─ energetic
│  │  └─ neutral
│  ├─ energyLevel: int (1-10)
│  ├─ libido: int (1-10)
│  └─ emotionalState: List<String> (keywords)
│
├─ healthHistory: List<HealthEntry>
│  ├─ date: DateTime
│  ├─ sleepHours: double
│  ├─ sleepQuality: int (1-10)
│  ├─ stressLevel: int (1-10)
│  ├─ diet: String (text description)
│  ├─ waterIntake: int (cups)
│  ├─ exerciseDuration: int (minutes)
│  └─ exerciseType: String
│
├─ temperatureData: List<TemperatureEntry>
│  ├─ date: DateTime
│  ├─ basalBodyTemperature: double (°C)
│  └─ temperatureIndex: int (1-3)
│
├─ derivedFeatures: CycleDerivedFeatures
│  ├─ cycleRegularity: double (0-1)
│  ├─ bleedingIntensityVariance: double (0-1)
│  ├─ symptomClusteringScore: double (0-1)
│  ├─ moodVariation: double (0-1)
│  ├─ energyVariation: double (0-1)
│  ├─ stressImpactScore: double (0-1)
│  ├─ historicalAccuracy: double (0-1)
│  ├─ ovulationConsistency: double (0-1)
│  ├─ cycleLengthStdDev: double (0-1)
│  └─ symptomFrequency: Map<CycleSymptom, double>
│
└─ personalBaseline: PersonalBaseline
   ├─ baselineCycleLength: int
   ├─ baselinePeriodLength: int
   ├─ typicalOvulationDay: int
   ├─ typicalBleedingIntensity: IntensityLevel
   ├─ commonPMSSymptoms: List<CycleSymptom>
   ├─ baselineEnergy: double (1-10 avg)
   ├─ baselineMood: double (1-10 avg)
   └─ cyclesTracked: int
```

---

## 🧠 Neural Network Architecture

```
INPUT LAYER (10 features)
    ├─ cycleLength (normalized 0-1)
    ├─ periodLength (normalized 0-1)
    ├─ bleedingIntensityVariance
    ├─ cycleRegularity
    ├─ symptomClusteringScore
    ├─ moodVariation
    ├─ energyVariation
    ├─ stressImpactScore
    ├─ ovulationConsistency
    └─ historicalAccuracy
         │
         ▼
DENSE LAYER 1 (64 neurons)
    ├─ Activation: ReLU
    ├─ Regularization: L2 (0.001)
    └─ Batch Normalization
         │ Dropout (0.3)
         │
         ▼
DENSE LAYER 2 (32 neurons)
    ├─ Activation: ReLU
    ├─ Regularization: L2 (0.001)
    └─ Batch Normalization
         │ Dropout (0.2)
         │
         ▼
DENSE LAYER 3 (16 neurons)
    ├─ Activation: ReLU
    └─ Dropout (0.1)
         │
         ▼
MULTI-TASK OUTPUT LAYER
    ├─ OUTPUT 1: period_date_offset
    │  └─ 1 neuron, Sigmoid activation (0-1 normalized days)
    │
    ├─ OUTPUT 2: confidence_score
    │  └─ 1 neuron, Sigmoid activation (0-1)
    │
    ├─ OUTPUT 3: phase_logits
    │  └─ 4 neurons, Softmax activation (probabilities for 4 phases)
    │
    └─ OUTPUT 4: ovulation_probability
       └─ 1 neuron, Sigmoid activation (0-1)

LOSS FUNCTION (Weighted Multi-Task)
    ├─ period_date: MSE (weight: 0.4)
    ├─ confidence: MSE (weight: 0.3)
    ├─ phase: Categorical Cross-Entropy (weight: 0.2)
    └─ ovulation: Binary Cross-Entropy (weight: 0.1)

OPTIMIZER: Adam (lr=0.001)
BATCH SIZE: 32
EPOCHS: 50
EARLY STOPPING: Patience=10

MODEL SIZE (After Quantization)
    Original: ~2.4 MB (float32)
    Quantized: 0.6-0.8 MB (int8)
    Compression: ~70%
```

---

## 🔌 API Specifications

### MLInferenceService API

```dart
class MLInferenceService {
  // Initialize service with TensorFlow Lite model
  Future<void> initialize() async

  // Main prediction method
  Future<MLCyclePrediction?> predictCycle(
    CycleMLDataModel userData
  ) async

  // Feature normalization (private)
  List<double> _normalizeFeatures(CycleMLDataModel data)

  // Apply personal learned weights (private)
  List<double> _applyPersonalWeights(List<double> features)

  // Execute TensorFlow Lite inference (private)
  Map<String, dynamic> _runInference(List<double> normalizedFeatures)

  // Convert raw ML outputs to prediction object (private)
  MLCyclePrediction _postProcessPrediction(Map<String, dynamic> rawOutput)

  // Update personal model weights based on user confirmation
  Future<void> updatePersonalModel(DateTime confirmedPeriodDate) async

  // Generate phase-specific information (private)
  CyclePhaseInfo _generatePhaseInfo(
    CyclePhase phase,
    int dayInPhase,
    double confidence
  )

  // Predict bleeding characteristics (private)
  PredictedBleedingInfo _predictBleeding()

  // Predict ovulation window (private)
  OvulationPrediction _predictOvulation()

  // Identify top influencing factors (private)
  List<String> _identifyInfluencingFactors()

  // Fallback deterministic prediction (private)
  MLCyclePrediction _fallbackPrediction()
}
```

**Example Usage:**

```dart
// Initialize
final mlService = MLInferenceService();
await mlService.initialize();

// Build data model
final mlData = CycleMLDataModel(
  lastPeriodStart: DateTime(2024, 1, 15),
  lastPeriodEnd: DateTime(2024, 1, 20),
  cycleLength: 28,
  periodLength: 5,
  bleedingPattern: [...], // populated with user data
  symptomHistory: [...],
  moodHistory: [...],
  healthHistory: [...],
  temperatureData: [],
);

// Get prediction
final prediction = await mlService.predictCycle(mlData);

print('Next period: ${prediction?.nextPeriodDate}');
print('Confidence: ${prediction?.confidenceScore}');
print('Phase: ${prediction?.phaseInfo.phase}');

// Update model when user confirms
await mlService.updatePersonalModel(DateTime(2024, 2, 12));
```

---

### DietRecommendationService API

```dart
class DietRecommendationService {
  // Get foods recommended for specific phase
  List<FoodRecommendation> getFoodsForPhase(CyclePhase phase)

  // Get nutrition info for food (calls USDA/Open Food Facts API)
  Future<FoodNutrition?> getNutritionInfo(String foodName) async

  // Get complete meal plan (breakfast/lunch/dinner/snacks)
  Future<MealPlan> getMealPlanForPhase(CyclePhase phase) async

  // Get iron-rich foods (for menstrual phase)
  List<FoodRecommendation> getIronRichFoods()

  // Get magnesium-rich foods (for luteal phase)
  List<FoodRecommendation> getMagnesiumRichFoods()

  // Get omega-3 foods (for all phases)
  List<FoodRecommendation> getOmega3Foods()

  // Helper methods (private)
  List<String> _getPhaseOptimalFoods(CyclePhase)
  List<String> _getPhaseAvoidFoods(CyclePhase)
  List<String> _getHydrationTips(CyclePhase)
  List<String> _getSupplementRecommendations(CyclePhase)
  List<String> _getMealPrepTips(CyclePhase)
}
```

**Example Usage:**

```dart
final dietService = DietRecommendationService();

// Get foods for follicular phase
final foods = dietService.getFoodsForPhase(CyclePhase.follicular);
print(foods[0].name); // "Salmon"
print(foods[0].iron); // Iron content

// Get meal plan (async)
final mealPlan = await dietService.getMealPlanForPhase(
  CyclePhase.ovulation
);
print(mealPlan.breakfast); // Meal details
print(mealPlan.hydrationTips); // ["Drink plenty of water..."]

// Get nutrition info from API
final nutrition = await dietService.getNutritionInfo("spinach");
print(nutrition?.nutrients); // Full nutrition facts
```

---

## 🔐 Data Privacy & Security

### On-Device Processing

✅ **All ML inference happens locally**
- TensorFlow Lite model runs on device CPU
- No prediction data sent to cloud
- No API calls for health data

### Encryption

```dart
// Sensitive health data encrypted at rest
class EncryptionManager {
  static const _encryptionKey = 'LIORA_HEALTH_KEY_v1';
  
  // Encrypts before storage
  static Future<String> encryptHealthData(String plaintext) async {
    final encrypter = Encrypter(
      algorithm: AES(Key.fromUtf8(_encryptionKey)),
      mode: GCM(Padding.pkcs7),
    );
    return encrypter.encrypt(plaintext, iv: IV.fromSecureRandom(16)).base64;
  }

  // Decrypts when needed
  static Future<String> decryptHealthData(String encrypted) async {
    // ... decryption logic ...
  }
}
```

### Platform-Specific Security

**iOS:**
```dart
// Use iOS Keychain via flutter_secure_storage
final storage = FlutterSecureStorage();
await storage.write(key: 'ml_weights', value: weightsJson);
```

**Android:**
```dart
// Use Android Keystore via flutter_secure_storage
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    keyCipherAlgorithm: KeyProperties.KEY_ALGORITHM_AES,
    storageEncryption: true,
  ),
);
```

---

## 📊 Output Specifications

### MLCyclePrediction Object

```dart
class MLCyclePrediction {
  final DateTime nextPeriodDate;           // Predicted next period start
  final double confidenceScore;             // 0.0 - 1.0 confidence
  final CyclePhaseInfo phaseInfo;          // Current & future phase details
  final PredictedBleedingInfo? bleedingInfo; // For menstrual phase
  final OvulationPrediction? ovulationInfo; // If applicable
  final String insightSummary;             // Human-readable insight
  final List<String> influencingFactors;   // Top factors affecting prediction
  final List<String> personalizedRecommendations; // AI-generated advice
  final DateTime predictionTimestamp;      // When prediction was made
}

class CyclePhaseInfo {
  final CyclePhase phase;                  // 0=Menstrual, 1=Follicular, 2=Ovulation, 3=Luteal
  final DateTime estimatedStartDate;
  final DateTime estimatedEndDate;
  final int dayInPhase;
  final double confidenceScore;
  final String hormonalExplanation;        // "Estrogen rising..."
  final String bodyChangesExplanation;     // Physical changes
  final List<String> expectedSymptoms;     // What to expect
  final List<String> recommendedFoods;     // Phase-specific foods
  final List<String> foodsToAvoid;         // Contraindicated foods
}

class PredictedBleedingInfo {
  final IntensityLevel predictedIntensity;
  final BloodColor mostLikelyColor;
  final bool likelyHasClots;
  final String ironRecommendation;         // "Eat spinach, beef, lentils..."
  final int suggestedIronMg;                // Daily iron mg target
}

class OvulationPrediction {
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;       // 19 days before period
  final DateTime fertileWindowEnd;         // 10 days before period
  final double ovulationConfidence;
  final bool isHighFertility;
}
```

---

## 🎯 Performance Targets

| Metric | Target | Measure |
|--------|--------|---------|
| **Inference Speed** | <1000ms | Device latency |
| **Model Accuracy** | >75% | Period prediction within ±3 days |
| **Confidence Calibration** | <5% error | Confidence score reliability |
| **Model Size** | <20MB | Mobile storage |
| **Memory Usage** | <50MB | Runtime RAM |
| **Battery Impact** | <1% per day | From ML operations |
| **Startup Time** | <2000ms | App init with ML |

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] Feature normalization returns 0-1 values
- [ ] ML data model serialization/deserialization
- [ ] Personal weight updates
- [ ] Fallback prediction generation
- [ ] Diet recommendation accuracy

### Integration Tests
- [ ] Full pipeline: data → prediction → UI
- [ ] Model loading from assets
- [ ] Cache persistence
- [ ] Error handling

### User Acceptance Tests
- [ ] Predictions match user expectations
- [ ] UI displays insights clearly
- [ ] Confidence scores calibrate correctly
- [ ] Diet recommendations are relevant
- [ ] No data loss between sessions

---

## 🚀 Deployment Workflow

```
1. DEVELOPMENT
   ├─ python train_cycle_model.py
   └─ Output: models/cycle_model_quantized.tflite
       │
       ▼
2. INTEGRATION
   ├─ cp to assets/ml_models/cycle_model.tflite
   ├─ Update pubspec.yaml
   └─ flutter pub get
       │
       ▼
3. TESTING
   ├─ Unit tests: flutter test
   ├─ Integration tests
   ├─ Device testing (hot reload)
   └─ User acceptance testing
       │
       ▼
4. STAGING
   ├─ Build APK: flutter build apk
   ├─ Build APP: flutter build app-bundle
   ├─ Test on real devices
   └─ Firebase TestLab testing
       │
       ▼
5. PRODUCTION
   ├─ Code review & approval
   ├─ Submit to App Store & Play Store
   ├─ Monitor Crashlytics
   └─ Collect user feedback
```

---

## 📈 Monitoring & Metrics

```dart
class PredictionMetrics {
  static void logPrediction({
    required double confidence,
    required int daysToActualPeriod,
    required String phase,
  }) {
    // Firebase Analytics tracking
    FirebaseAnalytics.instance.logEvent(
      name: 'ml_prediction',
      parameters: {
        'confidence': confidence,
        'accuracy_range': daysToActualPeriod.abs(),
        'phase': phase,
        'timestamp': DateTime.now().toString(),
      },
    );
  }

  static void logModelUpdate() {
    FirebaseAnalytics.instance.logEvent(
      name: 'ml_model_update',
      parameters: {
        'timestamp': DateTime.now().toString(),
      },
    );
  }
}
```

---

**Document Status:** ✅ Complete Reference Guide
**Version:** 1.0
**Last Updated:** 2024

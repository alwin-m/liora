# ✅ LIORA ML System - Quick Start Checklist

Quick reference checklist for implementing the complete ML system.

---

## 📋 Phase 1: Setup (30 minutes)

- [ ] **Create asset directories**
  ```bash
  mkdir -p assets/ml_models
  mkdir -p assets/data
  ```

- [ ] **Update pubspec.yaml**
  - [ ] Add `tflite_flutter: ^0.10.0`
  - [ ] Add `sqflite: ^2.3.0`
  - [ ] Add `encrypt: ^5.0.0`
  - [ ] Add `path_provider: ^2.1.0`
  - [ ] Add `assets:` section with:
    - `assets/`
    - `assets/ml_models/`
    - `assets/data/`
  - [ ] Run `flutter pub get`

- [ ] **Verify files exist in lib/**
  - [ ] `models/ml_cycle_data.dart` ✓ (already created)
  - [ ] `services/ml_inference_service.dart` ✓ (already created)
  - [ ] `services/diet_recommendation_service.dart` ✓ (already created)
  - [ ] `Screens/cycle_ai_insights_panel.dart` ✓ (already created)

---

## 📊 Phase 2: Model Training (45 minutes)

- [ ] **Install Python dependencies**
  ```bash
  pip install tensorflow numpy pandas scikit-learn
  ```

- [ ] **Run training script**
  ```bash
  python train_cycle_model.py \
    --data-path ./data \
    --output-path ./models \
    --epochs 50
  ```

- [ ] **Verify output**
  - [ ] Check `models/cycle_model_quantized.tflite` exists
  - [ ] File size should be 0.6-0.8 MB

- [ ] **Copy model to assets**
  ```bash
  cp models/cycle_model_quantized.tflite \
    assets/ml_models/cycle_model.tflite
  ```

---

## 🔧 Phase 3: Core Integration (60 minutes)

### 3A: Update main.dart

- [ ] Import ML services:
  ```dart
  import 'services/ml_inference_service.dart';
  import 'services/diet_recommendation_service.dart';
  ```

- [ ] Initialize ML services before runApp():
  ```dart
  final mlInferenceService = MLInferenceService();
  final dietService = DietRecommendationService();
  await mlInferenceService.initialize();
  ```

- [ ] Add to MultiProvider:
  ```dart
  Provider<MLInferenceService>(
    create: (_) => mlInferenceService,
  ),
  Provider<DietRecommendationService>(
    create: (_) => dietService,
  ),
  ```

### 3B: Enhance CycleProvider

- [ ] Add fields:
  ```dart
  late MLInferenceService _mlService;
  MLCyclePrediction? _latestPrediction;
  ```

- [ ] Add method `setMLService()`:
  ```dart
  void setMLService(MLInferenceService service) {
    _mlService = service;
  }
  ```

- [ ] Add method `predictCycleWithML()`:
  ```dart
  Future<MLCyclePrediction?> predictCycleWithML() async {
    final mlDataModel = _buildMLDataModel();
    _latestPrediction = await _mlService.predictCycle(mlDataModel);
    notifyListeners();
    return _latestPrediction;
  }
  ```

- [ ] Add methods for data logging:
  - [ ] `logBleedingData(BleedingDay)`
  - [ ] `logSymptom(SymptomEntry)`
  - [ ] `logMood(MoodEntry)`
  - [ ] `logHealthData(HealthEntry)`

### 3C: Update Calendar Screen

- [ ] Import required services:
  ```dart
  import 'package:provider/provider.dart';
  import '../../Screens/cycle_ai_insights_panel.dart';
  ```

- [ ] In `onDaySelected` callback, add:
  ```dart
  final mlService = context.read<MLInferenceService>();
  final prediction = await mlService.predictCycle(mlDataModel);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => CycleAIInsightsPanel(
      selectedDate: selectedDay,
      prediction: prediction,
      phaseInfo: prediction.phaseInfo,
      isToday: selectedDay.isToday,
    ),
  );
  ```

---

## 📱 Phase 4: Data Input Screens (90 minutes)

Create 4 new screens for health data input:

### 4A: Bleeding Tracker
- [ ] Create `lib/Screens/bleeding_tracker_screen.dart`
- [ ] Components:
  - [ ] Intensity selector (light/medium/heavy/spotting)
  - [ ] Color picker (bright red/dark red/brown/pink)
  - [ ] Clots checkbox
  - [ ] Save button → `cycleProvider.logBleedingData()`

### 4B: Symptom Logger
- [ ] Create `lib/Screens/symptom_tracker_screen.dart`
- [ ] Components:
  - [ ] Checkbox list (15 cycle symptoms)
  - [ ] Intensity slider (1-10) for each selected symptom
  - [ ] Save button → `cycleProvider.logSymptom()`

### 4C: Mood & Energy
- [ ] Create `lib/Screens/mood_energy_screen.dart`
- [ ] Components:
  - [ ] Mood slider (1-10)
  - [ ] Energy slider (1-10)
  - [ ] Libido slider (1-10)
  - [ ] Mood category dropdown
  - [ ] Save button → `cycleProvider.logMood()`

### 4D: Health Habits
- [ ] Create `lib/Screens/health_habits_screen.dart`
- [ ] Components:
  - [ ] Sleep hours slider
  - [ ] Sleep quality slider
  - [ ] Stress level slider
  - [ ] Water intake counter
  - [ ] Exercise duration slider
  - [ ] Exercise type text field
  - [ ] Diet notes text area
  - [ ] Save button → `cycleProvider.logHealthData()`

---

## 🎨 Phase 5: UI Updates (60 minutes)

### 5A: Add Navigation to Data Screens

- [ ] Update home screen with buttons to open:
  - [ ] "Log Bleeding" → BleedingTrackerScreen
  - [ ] "Log Symptoms" → SymptomTrackerScreen
  - [ ] "Log Mood" → MoodEnergyScreen
  - [ ] "Log Health" → HealthHabitsScreen

### 5B: Enhance Dashboard

- [ ] Display latest ML prediction
- [ ] Show next period date (with confidence)
- [ ] Show current phase
- [ ] Quick access to insights panel

### 5C: Calendar Color Coding

- [ ] Color days by predicted phase:
  - [ ] Menstrual: Red (#FF0000)
  - [ ] Follicular: Orange (#FF9800)
  - [ ] Ovulation: Yellow (#FFEB3B)
  - [ ] Luteal: Indigo (#3F51B5)

---

## 🧪 Phase 6: Testing (60 minutes)

### 6A: Unit Tests
- [ ] Create `test/ml_inference_service_test.dart`
- [ ] Test:
  - [ ] Feature normalization (0-1 range)
  - [ ] ML data model building
  - [ ] Fallback prediction
  - [ ] Model weight updates

**Run:** `flutter test test/ml_inference_service_test.dart -v`

### 6B: Manual Testing
- [ ] Run app: `flutter run`
- [ ] Verify ML service initializes (check logs for ✓ markers)
- [ ] Click calendar day → should show insights panel
- [ ] Log bleeding data → verify saved
- [ ] Log symptom → verify saved
- [ ] Check diet recommendations show up
- [ ] Verify predictions appear with confidence scores

### 6C: Device Testing
- [ ] Test on iOS device
- [ ] Test on Android device
- [ ] Check inference speed (<1s)
- [ ] Monitor battery usage
- [ ] Check memory usage (should stay <50MB)

---

## 🚀 Phase 7: Optimization (30 minutes)

- [ ] **Performance profiling**
  ```bash
  flutter run --profile
  ```
  Check timeline for:
  - [ ] Inference time <1000ms
  - [ ] No memory leaks
  - [ ] Smooth UI transitions

- [ ] **Build optimizations**
  - [ ] Enable code shrinking (Android)
  - [ ] Enable bitcode (iOS)
  - [ ] Remove unused dependencies

- [ ] **Asset optimization**
  - [ ] Compress model further if needed
  - [ ] Remove debug symbols
  - [ ] Test with production build

- [ ] **Network optimization** (for API calls)
  ```dart
  const Duration timeout = Duration(seconds: 5);
  ```

---

## 📦 Phase 8: Deployment (90 minutes)

### 8A: Android Build
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Or for App Bundle (Play Store):
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 8B: iOS Build
```bash
flutter build ios --release
# Output: build/ios/Release-iphoneos/

# Or use Xcode:
open ios/Runner.xcworkspace
# Archive in Xcode, then upload to App Store
```

### 8C: Pre-Release Checklist
- [ ] Test on real devices (iOS & Android)
- [ ] Check all data flows work end-to-end
- [ ] Verify no sensitive data in logs
- [ ] Test with slowest device available
- [ ] Check for crashes in Crashlytics
- [ ] Complete privacy policy (mention ML on-device)
- [ ] Update README with ML capabilities
- [ ] Get user feedback from beta testers

### 8D: Release
- [ ] Version bump in pubspec.yaml
- [ ] Generate release notes
- [ ] Submit to App Store Connect (iOS)
- [ ] Submit to Google Play Console (Android)
- [ ] Monitor Crashlytics for errors
- [ ] Respond to user reviews

---

## 🔍 Phase 9: Post-Launch Monitoring

### Metrics to Track
- [ ] Daily active users
- [ ] Prediction accuracy (track user confirmations)
- [ ] Average confidence scores
- [ ] Model update frequency
- [ ] Crash rate (via Crashlytics)
- [ ] Average session duration

### Logging Setup
```dart
// Firebase Analytics events
FirebaseAnalytics.instance.logEvent(
  name: 'ml_prediction',
  parameters: {
    'confidence': prediction.confidenceScore,
    'phase': prediction.phaseInfo.phase.name,
  },
);
```

### A/B Testing (Optional)
- [ ] Test different feature orderings
- [ ] Test recommendation formats
- [ ] Test notification timing
- [ ] Measure engagement metrics

---

## 🐛 Troubleshooting Quick Reference

### Common Issues

| Issue | Solution |
|-------|----------|
| **TensorFlow Lite model not found** | Verify `assets/ml_models/cycle_model.tflite` exists and `pubspec.yaml` includes `assets/ml_models/` |
| **Inference takes >1 second** | Ensure model is quantized (int8). Check that device isn't running other heavy processes |
| **Predictions seem random** | Verify training data quality. Check feature normalization. Collect more user data for personalization |
| **App crashes on startup** | Check ML service initialization in main.dart. Verify all imports are correct |
| **Memory usage high** | Ensure interpreter disposal. Check for circular references. Profile with DevTools |
| **Diet API calls timeout** | Increase timeout in `diet_recommendation_service.dart`. Add fallback static data |
| **NotificationError with Provider** | Ensure `MLInferenceService` is provided in `main.dart` MultiProvider |

---

## 📚 File Structure After Completion

```
lioraa/
├── lib/
│   ├── main.dart (UPDATED - ML initialization)
│   ├── models/
│   │   ├── ml_cycle_data.dart ✓ (CREATED)
│   │   ├── cycle_data.dart (existing)
│   │   └── ...
│   ├── services/
│   │   ├── ml_inference_service.dart ✓ (CREATED)
│   │   ├── diet_recommendation_service.dart ✓ (CREATED)
│   │   ├── ai_service.dart (existing)
│   │   └── ...
│   ├── Screens/
│   │   ├── cycle_ai_insights_panel.dart ✓ (CREATED)
│   │   ├── bleeding_tracker_screen.dart (NEW)
│   │   ├── symptom_tracker_screen.dart (NEW)
│   │   ├── mood_energy_screen.dart (NEW)
│   │   ├── health_habits_screen.dart (NEW)
│   │   └── ...
│   ├── home/
│   │   ├── calendar_screen.dart (UPDATED - ML integration)
│   │   └── ...
│   ├── providers/
│   │   ├── cycle_provider.dart (UPDATED - ML methods)
│   │   └── ...
│   └── ...
├── assets/
│   ├── ml_models/
│   │   └── cycle_model.tflite (NEW - TensorFlow Lite model)
│   ├── data/
│   └── ...
├── test/
│   ├── ml_inference_service_test.dart (NEW)
│   └── ...
├── pubspec.yaml (UPDATED - new dependencies)
├── train_cycle_model.py (NEW - Python training script)
├── ML_INTEGRATION_SETUP.md (NEW - detailed setup guide)
├── ML_ARCHITECTURE_REFERENCE.md (NEW - architecture docs)
├── ML_QUICKSTART_CHECKLIST.md (NEW - this file)
└── ...
```

---

## ⏱ Estimated Timeline

| Phase | Duration | Difficulty |
|-------|----------|------------|
| 1. Setup | 30 min | Easy |
| 2. Model Training | 45 min | Medium |
| 3. Core Integration | 60 min | Medium |
| 4. Data Input Screens | 90 min | Medium-Hard |
| 5. UI Updates | 60 min | Easy-Medium |
| 6. Testing | 60 min | Medium |
| 7. Optimization | 30 min | Hard |
| 8. Deployment | 90 min | Hard |
| 9. Monitoring | Ongoing | Easy |
| **TOTAL** | **~465 min** | **~7.5 hours** |

---

## 💡 Pro Tips

1. **Start with Phase 3** - Get basic integration working first
2. **Use hot reload** - Flutter's hot reload makes iteration fast
3. **Test incrementally** - Don't wait until the end to test
4. **Mock the model** - Return dummy predictions until real model is ready
5. **Gather feedback early** - Beta test with real users ASAP
6. **Monitor metrics** - Track prediction accuracy from day 1
7. **Log everything** - Use Firebase Analytics to understand usage patterns
8. **Privacy first** - Always remind users that health data stays on device

---

## 🎯 Success Criteria

- [ ] App starts without errors
- [ ] ML service initializes successfully
- [ ] Calendar day click → shows insights panel
- [ ] Users can log all health data types
- [ ] Predictions appear with confidence scores
- [ ] Diet recommendations load and display
- [ ] All features work offline
- [ ] No health data leaves device
- [ ] Inference completes in <1 second
- [ ] App rating >4.5 stars on stores

---

## 📞 Support Resources

- **TensorFlow Lite:** https://www.tensorflow.org/lite
- **Flutter Provider:** https://pub.dev/packages/provider
- **Flutter Secure Storage:** https://pub.dev/packages/flutter_secure_storage
- **Firebase:** https://firebase.google.com/docs/flutter/setup
- **USDA FoodData Central API:** https://fdc.nal.usda.gov

---

**Checklist Status:** Ready to implement
**Last Updated:** 2024
**Next Step:** Start Phase 1 Setup

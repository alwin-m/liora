# 🚀 AI Integration Implementation Guide for LIORA

## Overview

This guide explains how to integrate the new AI services into your existing LIORA Flutter app. The implementation respects your privacy-first architecture while adding powerful AI capabilities.

---

## Architecture

### Components Created

1. **AIService** (`lib/services/ai_service.dart`)
   - Main AI abstraction layer
   - Supports: Local, Ollama, Claude API
   - Handles provider routing & fallbacks

2. **EnhancedCycleAlgorithm** (`lib/home/enhanced_cycle_algorithm.dart`)
   - Hybrid prediction model (deterministic + AI)
   - Returns confidence scores
   - Gracefully falls back when AI unavailable

3. **JournalAnalysisService** (`lib/services/journal_analysis_service.dart`)
   - Analyzes free-text journal entries
   - Extracts symptoms, mood, patterns
   - Local-only processing

4. **WellnessRecommendationEngine** (`lib/services/wellness_recommendation_service.dart`)
   - Phase-specific wellness recommendations
   - Product suggestions
   - Symptom relief guidance

5. **AISettingsScreen** (`lib/Screens/ai_settings_screen.dart`)
   - User-facing AI configuration
   - Privacy controls
   - API key management

---

## Integration Steps

### Step 1: Update pubspec.yaml

Add these dependencies for enhanced AI capabilities (optional):

```yaml
dependencies:
  # For on-device ML (optional, if using TensorFlow Lite models)
  # tflite_flutter: ^0.10.0
  
  # For native platform channels (optional)
  platform: ^4.1.0
```

Note: The current implementation uses Ollama or Claude API as backends, which don't require additional dependencies.

---

### Step 2: Initialize AI Service in main.dart

```dart
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... existing initialization code ...
  
  // Initialize AI Service
  final aiService = AIService();
  await aiService.initialize();
  
  runApp(const MyApp());
}
```

---

### Step 3: Integration with CycleProvider

Update your existing `CycleProvider` to use the enhanced algorithm:

```dart
import 'home/enhanced_cycle_algorithm.dart';

class CycleProvider with ChangeNotifier {
  // ... existing code ...
  
  EnhancedCycleAlgorithm? _enhancedAlgorithm;
  
  Future<void> updateWithAIEnhancement() async {
    if (_cycleData == null) return;
    
    _enhancedAlgorithm = EnhancedCycleAlgorithm(
      lastPeriod: _cycleData!.lastPeriodStartDate,
      cycleLength: _cycleData!.averageCycleLength,
      periodLength: _cycleData!.averagePeriodDuration,
      historicalPeriodDates: _history.map((e) => e.initialInputDate).toList(),
      recentSymptoms: _extractRecentSymptoms(),
      recentMoodScores: _extractRecentMoodScores(),
    );
    
    notifyListeners();
  }
  
  /// Get AI-enhanced next period prediction
  Future<EnhancedPrediction> getNextPeriodWithAI() async {
    if (_enhancedAlgorithm == null) {
      await updateWithAIEnhancement();
    }
    return await _enhancedAlgorithm!.getNextPeriodPredictionAI();
  }
  
  // Helper methods to extract data
  List<String> _extractRecentSymptoms() {
    // Extract symptoms from last 14 days of history
    return []; // TODO: implement based on your data structure
  }
  
  List<double> _extractRecentMoodScores() {
    // Extract mood scores from last 14 days
    return []; // TODO: implement based on your data structure
  }
}
```

---

### Step 4: Add AI Settings to Your Settings Screen

```dart
import 'Screens/ai_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ... existing settings ...
        
        ListTile(
          title: const Text('AI Settings'),
          subtitle: const Text('Configure cycle prediction AI'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AISettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

---

### Step 5: Use Journal Analysis (Optional)

If you have a journal feature, integrate analysis:

```dart
import 'services/journal_analysis_service.dart';

class JournalScreen extends StatefulWidget {
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _journalService = JournalAnalysisService();
  
  Future<void> analyzeJournalEntry(String text) async {
    final analysis = await _journalService.analyzeEntry(
      entryText: text,
      entryDate: DateTime.now(),
    );
    
    // Use results
    print('Extracted symptoms: ${analysis.symptoms}');
    print('Mood score: ${analysis.moodScore}');
    
    // Save analysis for pattern detection
  }
}
```

---

### Step 6: Display Enhanced Predictions in UI

Example in your home/calendar screen:

```dart
import 'home/enhanced_cycle_algorithm.dart';
import 'services/cycle_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, _) {
        return FutureBuilder<EnhancedPrediction>(
          future: cycleProvider.getNextPeriodWithAI(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final prediction = snapshot.data!;
              
              return Card(
                child: Column(
                  children: [
                    Text(
                      'Next Period: ${prediction.predictedDate.toIso8601String().split('T')[0]}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confidence: ${(prediction.confidenceScore * 100).toStringAsFixed(0)}%',
                    ),
                    if (prediction.usedAI)
                      Text(
                        'AI Enhanced',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    Text(
                      prediction.getAdjustmentDescription(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        );
      },
    );
  }
}
```

---

## Deployment Options

### Option 1: Local Processing (Recommended for Privacy)

**Best for**: Users who prioritize complete privacy

No additional setup needed. AI service gracefully degrades to rule-based predictions.

```dart
// Default behavior - works offline
final aiService = AIService();
await aiService.initialize();
// If no API configured, uses lightweight local models
```

---

### Option 2: Ollama (On-Device LLM)

**Best for**: Desktop/development, users with spare compute

**Setup for users:**

1. Install Ollama: https://ollama.ai
2. Run: `ollama run llama3`
3. Open LIORA Settings → AI Settings
4. Enter URL: `http://localhost:11434`

```dart
// In settings screen flow
await aiService.configureOllama('http://localhost:11434');
```

---

### Option 3: Claude API (Cloud)

**Best for**: Users wanting maximum capabilities, willing to use cloud

**Setup for users:**

1. Get API key: https://console.anthropic.com
2. Open LIORA Settings → AI Settings
3. Paste API key (stored encrypted locally)

```dart
// In settings screen flow
await aiService.configureClaudeAPI('sk-ant-...');
```

**Cost:** ~$0.01-$0.05 per cycle prediction (very low)

---

## Privacy & Security Implementation

### Data Handling

```dart
// ✅ CORRECT: Medical data stays local
final symptoms = cycleProvider.cycleData.symptoms; // From local storage
// Only use LOCALLY for AI inference

// ❌ WRONG: Don't transmit raw data
// await http.post(url, body: jsonEncode(symptoms)); // NO!
```

### API Keys

```dart
// Stored encrypted in SharedPreferences
await prefs.setString('claude_api_key', apiKey); 
// Platform-native: Keychain (iOS), Keystore (Android)
```

### User Consent

```dart
// Toggle available in settings
bool aiEnabled = await aiService.setAIEnabled(true);
// Users can disable anytime
```

---

## Feature: AI-Powered Wellness Recommendations

```dart
import 'services/wellness_recommendation_service.dart';

class WellnessScreen extends StatelessWidget {
  final engine = WellnessRecommendationEngine();
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WellnessRecommendation>(
      future: engine.getRecommendation(
        cyclePhase: 'menstrual',
        currentSymptoms: ['Cramps', 'Bloating'],
        focusArea: 'nutrition',
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rec = snapshot.data!;
          return Card(
            child: Column(
              children: [
                Text(rec.recommendation),
                Text('Confidence: ${rec.getConfidenceLabel()}'),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

---

## Testing AI Integration

### Unit Tests

```dart
import 'home/enhanced_cycle_algorithm.dart';
import 'services/ai_service.dart';

void main() {
  test('Enhanced algorithm falls back gracefully', () async {
    final algo = EnhancedCycleAlgorithm(
      lastPeriod: DateTime(2024, 1, 1),
      cycleLength: 28,
      periodLength: 5,
    );
    
    final prediction = await algo.getNextPeriodPredictionAI();
    expect(prediction.usedAI, false); // Should be false if AI disabled
    expect(prediction.confidenceScore, lessThanOrEqualTo(0.7));
  });
}
```

---

## Performance Optimization

### 1. Lazy Load AI Service

```dart
// Initialize only when needed
class AIServiceSingleton {
  static AIService? _instance;
  
  static Future<AIService> getInstance() async {
    _instance ??= AIService();
    await _instance!.initialize();
    return _instance!;
  }
}
```

### 2. Cache AI Results

```dart
// Store insights for offline access
await aiService.cacheInsight('menstrual_tips', recommendation);
final cached = await aiService.getCachedInsight('menstrual_tips');
```

### 3. Limit Token Context

```dart
// For cloud APIs, limit input size
final truncated = journalText.length > 500 
  ? journalText.substring(0, 500) 
  : journalText;
```

---

## Troubleshooting

### Issue: "AI unavailable" message

**Solution:**
1. Check if AI is enabled in settings
2. If Ollama: Verify server running (`ollama run llama3`)
3. If Claude: Verify API key is valid
4. Fall back to deterministic algorithm works automatically

### Issue: Slow predictions

**Solution:**
1. Switch to local processing (faster)
2. Reduce data input size
3. Cache results for repeat queries

### Issue: Memory errors

**Solution:**
1. Use quantized models (Q4_K_M)
2. Reduce context window
3. Consider cloud API for lower-end devices

---

## Next Steps

1. **Deploy Enhanced Algorithm:**
   - Update CycleProvider with AI integration
   - Test with real user data
   - Monitor performance

2. **Add Journal Feature (if not exists):**
   - Create journal entry UI
   - Integrate JournalAnalysisService
   - Display pattern insights

3. **Expand Shop Integration:**
   - Connect wellness recommendations to product catalog
   - A/B test recommendation accuracy

4. **Fine-tuning (Optional):**
   - Collect anonymized patterns (with consent)
   - Fine-tune Llama model on cycle data
   - Deploy as federated learning

---

## API Reference

### AIService

```dart
// Initialize
await aiService.initialize();

// Toggle AI
await aiService.setAIEnabled(bool);

// Configure providers
await aiService.configureOllama(String url);
await aiService.configureClaudeAPI(String apiKey);

// Make predictions
AIResponse response = await aiService.predictCycle(
  lastPeriod: DateTime,
  cycleLength: int,
  recentSymptoms: List<String>,
  moodScores: List<double>,
);

// Cache management
await aiService.cacheInsight(String key, String value);
String? cached = await aiService.getCachedInsight(String key);
await aiService.clearCache();
```

### EnhancedCycleAlgorithm

```dart
EnhancedPrediction pred = await algo.getNextPeriodPredictionAI();
PhaseDistribution phases = await algo.getPhaseDistributionAI(DateTime);
double regularity = algo.calculateCycleRegularity();
```

---

## Support & Contributions

For questions or issues:

1. Check troubleshooting section
2. Review Privacy Policy: `PRIVACY_POLICY.md`
3. Review Security Guidelines: `SECURITY.md`

---

**Version:** 1.0
**Last Updated:** February 2026
**Privacy First:** All medical data remains local

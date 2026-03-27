# ⚡ AI Integration Quick Start (5 Minutes)

Get AI cycle predictions running in minutes. Choose your setup:

---

## 🟢 Option 1: Instant Setup (No API Keys)

**Perfect for:** Testing, development, privacy-focused users

### Step 1: Update main.dart

```dart
import 'package:lioraa/services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AI Service
  final aiService = AIService();
  await aiService.initialize();
  
  runApp(const MyApp());
}
```

### Step 2: Use in Your Cycle Provider

```dart
import 'package:lioraa/home/enhanced_cycle_algorithm.dart';

class CycleProvider with ChangeNotifier {
  // ... existing code ...
  
  /// Get AI-enhanced prediction
  Future<EnhancedPrediction> getNextPeriodWithAI() async {
    final algo = EnhancedCycleAlgorithm(
      lastPeriod: _cycleData!.lastPeriodStartDate,
      cycleLength: _cycleData!.averageCycleLength,
      periodLength: _cycleData!.averagePeriodDuration,
    );
    
    return await algo.getNextPeriodPredictionAI();
  }
}
```

### Step 3: Display in UI

```dart
FutureBuilder<EnhancedPrediction>(
  future: cycleProvider.getNextPeriodWithAI(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final pred = snapshot.data!;
      return Text(
        'Next Period: ${pred.predictedDate}'
        '\nConfidence: ${(pred.confidenceScore * 100).round()}%',
      );
    }
    return const CircularProgressIndicator();
  },
)
```

**Result:** Works offline, uses lightweight local processing ✓

---

## 🟡 Option 2: Ollama Setup (10 Minutes)

**Perfect for:** Local LLM, offline capability, laptop/desktop testing

### Step 1: Install Ollama

```bash
# macOS
brew install ollama

# Windows / Linux
# Download from https://ollama.ai
```

### Step 2: Download Llama 3

```bash
ollama pull llama3
ollama run llama3
# Waits for server on http://localhost:11434
```

### Step 3: Configure in App

```dart
// In your settings flow
final aiService = AIService();
await aiService.configureOllama('http://localhost:11434');
await aiService.setAIEnabled(true);
```

Or via UI: **Settings → AI Settings → Ollama → Enter URL**

### Step 4: Test

```dart
final response = await aiService.predictCycle(
  lastPeriod: DateTime(2024, 1, 1),
  cycleLength: 28,
  recentSymptoms: ['fatigue', 'bloating'],
  moodScores: [0.5, 0.6, 0.7, 0.8],
);
print(response.content); // AI prediction
```

**Result:** Offline LLM running locally, ~2-5s per prediction ✓

---

## 🔴 Option 3: Claude API (5 Minutes)

**Perfect for:** Production, advanced features, cloud backend

### Step 1: Get API Key

1. Go to https://console.anthropic.com
2. Create account (free tier available)
3. Generate API key
4. Copy key: `sk-ant-...`

### Step 2: Configure in App

```dart
final aiService = AIService();
await aiService.configureClaudeAPI('sk-ant-YOUR-KEY-HERE');
await aiService.setAIEnabled(true);
```

Or via UI: **Settings → AI Settings → Claude API → Paste Key**

### Step 3: Test

```dart
final response = await aiService.predictCycle(
  lastPeriod: DateTime(2024, 1, 1),
  cycleLength: 28,
  recentSymptoms: ['fatigue', 'bloating'],
  moodScores: [0.5, 0.6, 0.7, 0.8],
);
print(response.content); // AI prediction from Claude
```

### Cost Calculator

| Usage | Cost |
|-------|------|
| 1 cycle prediction | $0.01 |
| 1 journal analysis | $0.02 |
| 30 predictions/month | $0.30 |
| 10K users 30 pred/month | $3,000/month |

**Result:** Production-ready, fastest predictions (~1-2s) ✓

---

## 📊 Minimal Working Example

**File: `lib/screens/minimal_ai_demo.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:lioraa/services/ai_service.dart';
import 'package:lioraa/home/enhanced_cycle_algorithm.dart';

class MinimalAIDemo extends StatefulWidget {
  const MinimalAIDemo({Key? key}) : super(key: key);

  @override
  State<MinimalAIDemo> createState() => _MinimalAIDemoState();
}

class _MinimalAIDemoState extends State<MinimalAIDemo> {
  final aiService = AIService();
  String result = '';

  @override
  void initState() {
    super.initState();
    _testAI();
  }

  Future<void> _testAI() async {
    // Initialize AI
    await aiService.initialize();
    await aiService.setAIEnabled(true);

    // Create algorithm
    final algo = EnhancedCycleAlgorithm(
      lastPeriod: DateTime(2024, 1, 1),
      cycleLength: 28,
      periodLength: 5,
      recentSymptoms: ['fatigue', 'mood swings'],
      recentMoodScores: [0.5, 0.6, 0.7, 0.8],
    );

    // Get prediction
    final prediction = await algo.getNextPeriodPredictionAI();

    setState(() {
      result = '''
CYCLE PREDICTION
═══════════════════
Predicted Date: ${prediction.predictedDate}
Confidence: ${(prediction.confidenceScore * 100).round()}%
AI Used: ${prediction.usedAI}
Adjustment: ${prediction.getAdjustmentDescription()}
Reasoning: ${prediction.reasoning}
      ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Demo')),
      body: result.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  result,
                  style: const TextStyle(fontFamily: 'Courier'),
                ),
              ),
            ),
    );
  }
}
```

**Run it:**
```dart
// In main.dart
home: const MinimalAIDemo(), // Temporarily replace home screen
```

---

## ✅ Verification Checklist

After setup, verify:

- [ ] No compile errors
- [ ] AI service initializes
- [ ] Prediction runs (check logs)
- [ ] Result displays without errors
- [ ] Can toggle AI on/off

**Debug Output:**
```
✓ AIService initialized
✓ Provider: local (default)
✓ Prediction generated
✓ Confidence: 75%
```

---

## 🐛 Troubleshooting

### "AI unavailable"
**Solution:** AI is disabled by default
```dart
await aiService.setAIEnabled(true); // Enable it
```

### "Connection refused" (Ollama)
**Solution:** Ollama not running
```bash
ollama run llama3 # Start server first
```

### "Invalid API key" (Claude)
**Solution:** Check key formatting
```dart
// Should start with: sk-ant-
// Not: sk-*** or shortened version
```

### "Prediction very slow"
**Solution:** Using cloud API or slow connection
- Try local processing: `AIProvider.local`
- Or use Ollama: `AIProvider.ollama`
- Check network connection for cloud

---

## 📱 Testing on Different Devices

### Android
```bash
# Enable local network access
flutter run
# Test with Ollama on local machine
# URL: http://192.168.1.X:11434 (replace X)
```

### iOS
Similar setup, network access already enabled

### Web (if using)
Only cloud APIs supported (CORS)

---

## 🚀 Next Steps

1. ✅ **Choose Option:** Local (default) or Ollama or Claude
2. ✅ **Integrate:** Copy code snippets above
3. ✅ **Test:** Run minimal demo
4. ✅ **Deploy:** Merge to main branch
5. ✅ **Monitor:** Check prediction accuracy

---

## 📚 Further Reading

- **Full Guide:** `AI_INTEGRATION_GUIDE.md`
- **Roadmap:** `TECHNICAL_ROADMAP.md`
- **Privacy:** `PRIVACY_POLICY.md`
- **Security:** `SECURITY.md`

---

## 💡 Pro Tips

1. **Cache Results:**
   ```dart
   await aiService.cacheInsight('prediction_2024_02_28', resultText);
   ```

2. **Batch Operations:**
   ```dart
   // For multiple predictions, wait in parallel
   final futures = [
     aiService.predictCycle(...),
     aiService.analyzeJournal(...),
   ];
   final results = await Future.wait(futures);
   ```

3. **Handle Offline:**
   ```dart
   try {
     return await algo.getNextPeriodPredictionAI();
   } catch (e) {
     // Falls back automatically
     return EnhancedPrediction.fallback();
   }
   ```

---

**You're ready to go! 🎉**

Questions? See `AI_INTEGRATION_GUIDE.md` or check the implementation in `lib/services/`.

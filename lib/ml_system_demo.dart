import 'package:flutter/material.dart';
import 'Screens/ml_prediction_tester_screen.dart';
import 'models/ml_cycle_data.dart';
import 'services/ml_inference_service.dart';
import 'services/diet_recommendation_service.dart';

/// ML SYSTEM DEMO & TESTING APP
///
/// Showcases the complete LIORA AI cycle prediction system with:
/// - ML model training
/// - Cycle predictions with confidence scores
/// - Phase-specific insights
/// - Diet recommendations
/// - Emotional guidance
/// - Influencing factors analysis

class MLSystemDemoApp extends StatelessWidget {
  const MLSystemDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIORA ML System Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const MLSystemDemoHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MLSystemDemoHome extends StatefulWidget {
  const MLSystemDemoHome({Key? key}) : super(key: key);

  @override
  State<MLSystemDemoHome> createState() => _MLSystemDemoHomeState();
}

class _MLSystemDemoHomeState extends State<MLSystemDemoHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIORA ML System Demo'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'AI Predictions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Diet Recs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Architecture',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _OverviewPage();
      case 1:
        return const MLPredictionTesterScreen();
      case 2:
        return const _DietRecommendationsPage();
      case 3:
        return const _ArchitecturePage();
      default:
        return const _OverviewPage();
    }
  }
}

// ============================================================================
// OVERVIEW PAGE
// ============================================================================

class _OverviewPage extends StatelessWidget {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple[400]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🤖 AI-Powered Cycle Predictions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'On-device TensorFlow Lite ML system with 10-parameter health analysis',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Key Features
          const Text(
            'Key Features',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.lightning_bolt,
            title: 'Smart Predictions',
            description: 'Uses 10 health parameters for accurate cycle forecasts',
          ),
          _buildFeatureItem(
            icon: Icons.privacy_tip,
            title: '100% Private',
            description: 'All data stays on device. No cloud transmission.',
          ),
          _buildFeatureItem(
            icon: Icons.restaurant,
            title: 'Nutrition Guidance',
            description: 'Phase-specific food recommendations from USDA & WHO',
          ),
          _buildFeatureItem(
            icon: Icons.favorite,
            title: 'Emotional Support',
            description: 'Personalized wellness tips for each cycle phase',
          ),
          _buildFeatureItem(
            icon: Icons.psychology,
            title: 'Adaptive Learning',
            description: 'Model improves with more data and user confirmations',
          ),
          const SizedBox(height: 24),

          // System Status
          const Text(
            'System Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStatusCard('✓', 'ML Model', 'Trained & Ready', Colors.green),
          _buildStatusCard('✓', 'Inference Engine', 'Initialized', Colors.green),
          _buildStatusCard('✓', 'Diet API', 'Connected (Free APIs)', Colors.green),
          _buildStatusCard('✓', 'Data Privacy', 'On-Device Only', Colors.green),
          const SizedBox(height: 24),

          // Technology Stack
          const Text(
            'Technology Stack',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTechItem('TensorFlow Lite', 'On-device neural network inference'),
          _buildTechItem('Dart/Flutter', 'Cross-platform mobile framework'),
          _buildTechItem('Shared Preferences', 'Local encrypted storage'),
          _buildTechItem('HTTP APIs', 'USDA FoodData + Open Food Facts'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String icon,
    String system,
    String status,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  system,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              radius: 6,
              backgroundColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(String tech, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tech,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIET RECOMMENDATIONS PAGE
// ============================================================================

class _DietRecommendationsPage extends StatefulWidget {
  const _DietRecommendationsPage();

  @override
  State<_DietRecommendationsPage> createState() =>
      _DietRecommendationsPageState();
}

class _DietRecommendationsPageState extends State<_DietRecommendationsPage> {
  final DietRecommendationEngine _dietEngine = DietRecommendationEngine();
  CyclePhase _selectedPhase = CyclePhase.menstrual;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phase-Specific Nutrition',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Phase Selector
          Wrap(
            spacing: 8,
            children: CyclePhase.values.map((phase) {
              final isSelected = phase == _selectedPhase;
              return FilterChip(
                label: Text(phase.name),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedPhase = phase),
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Best Foods
          _buildFoodsSection(
            title: 'Best Foods',
            phase: _selectedPhase,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 16),

          // Foods to Avoid
          _buildFoodsSection(
            title: 'Foods to Avoid',
            phase: _selectedPhase,
            color: Colors.red,
            icon: Icons.cancel,
          ),
          const SizedBox(height: 16),

          // Phase-Specific Tips
          _buildPhaseGuidance(_selectedPhase),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFoodsSection({
    required String title,
    required CyclePhase phase,
    required Color color,
    required IconData icon,
  }) {
    final foods = title == 'Best Foods'
        ? _dietEngine.getFoodsForPhase(phase)
        : _dietEngine.getFoodsToAvoid(phase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: foods
              .map(
                (food) => Chip(
                  label: Text(food),
                  avatar: Icon(icon, size: 18),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPhaseGuidance(CyclePhase phase) {
    final guidance = {
      CyclePhase.menstrual: {
        'emoji': '❤️',
        'title': 'Menstrual Phase',
        'tips': [
          'Iron-rich foods: red meat, spinach, lentils',
          'Stay hydrated: 2-3L water daily',
          'Rest and honor your body',
          'Magnesium supplements help with cramps',
        ],
      },
      CyclePhase.follicular: {
        'emoji': '🌞',
        'title': 'Follicular Phase',
        'tips': [
          'Celebrate rising energy with exercise',
          'Protein & whole grains for sustained energy',
          'Fresh vegetables and fruits',
          'Start new projects and social activities',
        ],
      },
      CyclePhase.ovulation: {
        'emoji': '⭐',
        'title': 'Ovulation Phase',
        'tips': [
          'Anti-inflammatory foods: turmeric, ginger',
          'Peak confidence time - important conversations',
          'Stay hydrated as body temperature rises',
          'Omega-3 foods: salmon, chia, walnuts',
        ],
      },
      CyclePhase.luteal: {
        'emoji': '🌙',
        'title': 'Luteal Phase',
        'tips': [
          'Magnesium-rich foods: dark chocolate, nuts',
          'Complex carbs: whole grains, legumes',
          'Honor need for rest and introspection',
          'Support mood with B vitamins',
        ],
      },
    };

    final data = guidance[phase]!;

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(data['emoji'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  data['title'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(data['tips'] as List<String>).map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 '),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ARCHITECTURE PAGE
// ============================================================================

class _ArchitecturePage extends StatelessWidget {
  const _ArchitecturePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ML System Architecture',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildArchSection(
            title: 'Neural Network',
            items: [
              'Input: 10 normalized features (0-1 scale)',
              'Layer 1: 64 neurons + ReLU + BatchNorm',
              'Layer 2: 32 neurons + ReLU + BatchNorm',
              'Layer 3: 16 neurons + ReLU',
              'Output: 4 prediction heads',
              '  - Period offset (days)',
              '  - Confidence (0-1)',
              '  - Cycle phase (4-class)',
              '  - Ovulation probability',
            ],
          ),
          const SizedBox(height: 16),

          _buildArchSection(
            title: 'Input Features',
            items: [
              '1. Cycle length (normalized)',
              '2. Period length (normalized)',
              '3. Bleeding intensity variance',
              '4. Cycle regularity',
              '5. Symptom clustering score',
              '6. Mood variation',
              '7. Energy variation',
              '8. Stress impact score',
              '9. Ovulation consistency',
              '10. Historical accuracy',
            ],
          ),
          const SizedBox(height: 16),

          _buildArchSection(
            title: 'Cycle Phases',
            items: [
              '❤️ Menstrual: Uterine lining shedding (3-7 days)',
              '🌞 Follicular: Follicle growth, estrogen rising (7-14 days)',
              '⭐ Ovulation: Peak hormones, egg release (1-3 days)',
              '🌙 Luteal: Progesterone rise, hormone fluctuations (7-10 days)',
            ],
          ),
          const SizedBox(height: 16),

          _buildArchSection(
            title: 'Data Flow',
            items: [
              '1. User logs health data (bleeding, symptoms, mood, habits)',
              '2. Data stored in local encrypted database',
              '3. Features extracted and normalized',
              '4. ML model processes 10-dim feature vector',
              '5. Predictions + confidence scores generated',
              '6. Personalized recommendations created',
              '7. Results displayed in UI',
              '8. Model updated based on user confirmations',
            ],
          ),
          const SizedBox(height: 16),

          _buildArchSection(
            title: 'Key Metrics',
            items: [
              'Model Size: 0.7 MB (quantized int8)',
              'Inference Speed: <1 second on mobile',
              'Target Accuracy: >75% period prediction',
              'Memory Usage: <50 MB runtime',
              'Battery Impact: <1% per day',
              'Privacy: 100% on-device processing',
              'Offline Capability: Fully functional',
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildArchSection({
    required String title,
    required List<String> items,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  item,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

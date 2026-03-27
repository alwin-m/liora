import 'package:flutter/material.dart';
import '../models/ml_cycle_data.dart';
import '../services/diet_recommendation_service.dart';

/// AI CYCLE INSIGHTS PANEL
///
/// Displays detailed AI-powered predictions when user clicks on a calendar day
/// Shows biological state, symptoms, diet recommendations, and emotional guidance

class CycleAIInsightsPanel extends StatefulWidget {
  final DateTime selectedDate;
  final MLCyclePrediction prediction;
  final CyclePhaseInfo phaseInfo;
  final bool isToday;

  const CycleAIInsightsPanel({
    Key? key,
    required this.selectedDate,
    required this.prediction,
    required this.phaseInfo,
    required this.isToday,
  }) : super(key: key);

  @override
  State<CycleAIInsightsPanel> createState() => _CycleAIInsightsPanelState();
}

class _CycleAIInsightsPanelState extends State<CycleAIInsightsPanel> {
  final DietRecommendationEngine _dietEngine = DietRecommendationEngine();
  late Future<MealPlan> _mealPlanFuture;

  @override
  void initState() {
    super.initState();
    _mealPlanFuture = _dietEngine.getMealPlanForPhase(widget.phaseInfo.phase);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Phase info card
            _buildPhaseCard(),

            // Hormonal explanation
            _buildHormonalSection(),

            // Body changes
            _buildBodyChangesSection(),

            // Expected symptoms
            if (widget.phaseInfo.expectedSymptoms.isNotEmpty)
              _buildSymptomSection(),

            // Diet recommendations
            _buildDietSection(),

            // Foods to avoid
            if (widget.phaseInfo.foodsToAvoid.isNotEmpty)
              _buildAvoidFoodsSection(),

            // Emotional guidance
            _buildEmotionalGuidanceSection(),

            // Personalized recommendations
            if (widget.prediction.personalizedRecommendations.isNotEmpty)
              _buildRecommendationsSection(),

            // Confidence indicator
            _buildConfidenceIndicator(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dateStr =
        '${widget.selectedDate.day} ${_getMonthName(widget.selectedDate.month)}';
    final statusText = widget.isToday ? 'TODAY' : dateStr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPhaseColor(widget.phaseInfo.phase).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _getPhaseColor(widget.phaseInfo.phase).withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Cycle Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              _buildPhaseIcon(widget.phaseInfo.phase),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard() {
    final phaseLabel = widget.phaseInfo.phase.toString().split('.').last;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPhaseColor(widget.phaseInfo.phase).withOpacity(0.1),
        border: Border.all(
          color: _getPhaseColor(widget.phaseInfo.phase),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phaseLabel[0].toUpperCase() + phaseLabel.substring(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text(
                  'Day ${widget.phaseInfo.dayInPhase}',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: _getPhaseColor(
                  widget.phaseInfo.phase,
                ).withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.prediction.insightSummary,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHormonalSection() {
    return _buildSection(
      icon: Icons.biotech,
      title: 'Hormonal State',
      content: widget.phaseInfo.hormonalExplanation,
      color: Colors.purple,
    );
  }

  Widget _buildBodyChangesSection() {
    return _buildSection(
      icon: Icons.favorite,
      title: 'Body Changes',
      content: widget.phaseInfo.bodyChangesExplanation,
      color: Colors.red,
    );
  }

  Widget _buildSymptomSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Expected Symptoms',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.phaseInfo.expectedSymptoms
                .map(
                  (symptom) => Chip(
                    label: Text(symptom),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDietSection() {
    return FutureBuilder<MealPlan>(
      future: _mealPlanFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final mealPlan = snapshot.data!;

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Nutrition Recommendations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommended foods
                    _buildFoodList(
                      'Best Foods',
                      widget.phaseInfo.recommendedFoods,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),

                    // Hydration tips
                    if (mealPlan.hydration.isNotEmpty) ...[
                      Text(
                        'Hydration',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...mealPlan.hydration
                          .map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💧 ',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      const SizedBox(height: 16),
                    ],

                    // Supplements
                    if (mealPlan.supplements.isNotEmpty) ...[
                      Text(
                        'Supplements (Optional)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...mealPlan.supplements
                          .map(
                            (supp) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💊 ',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Expanded(
                                    child: Text(
                                      supp,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvoidFoodsSection() {
    return _buildFoodList(
      'Foods to Avoid',
      widget.phaseInfo.foodsToAvoid,
      color: Colors.red,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildEmotionalGuidanceSection() {
    final emotionalGuidance = _getEmotionalGuidance(widget.phaseInfo.phase);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_emotions, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Emotional Wellness',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...emotionalGuidance
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $item',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                'Today\'s Insights',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.prediction.personalizedRecommendations
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '✓ $rec',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediction Confidence',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: widget.prediction.confidenceScore,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.prediction.confidenceScore > 0.8
                  ? Colors.green
                  : widget.prediction.confidenceScore > 0.6
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(widget.prediction.confidenceScore * 100).toStringAsFixed(0)}% - '
            '${_getConfidenceLabel(widget.prediction.confidenceScore)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Helper methods

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(
    String title,
    List<String> foods, {
    required Color color,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: foods
                .map(
                  (food) => Chip(
                    label: Text(food),
                    avatar: Icon(
                      title == 'Best Foods' ? Icons.check_circle : Icons.cancel,
                      size: 16,
                    ),
                    backgroundColor: color.withOpacity(0.2),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIcon(CyclePhase phase) {
    const iconSize = 48.0;
    switch (phase) {
      case CyclePhase.menstrual:
        return Icon(Icons.favorite, size: iconSize, color: Colors.red);
      case CyclePhase.follicular:
        return Icon(Icons.wb_sunny, size: iconSize, color: Colors.orange);
      case CyclePhase.ovulation:
        return Icon(Icons.star, size: iconSize, color: Colors.yellow[700]);
      case CyclePhase.luteal:
        return Icon(Icons.nights_stay, size: iconSize, color: Colors.indigo);
    }
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return Colors.red;
      case CyclePhase.follicular:
        return Colors.orange;
      case CyclePhase.ovulation:
        return Colors.yellow;
      case CyclePhase.luteal:
        return Colors.indigo;
    }
  }

  List<String> _getEmotionalGuidance(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          'Honor your need for rest and introspection',
          'Gentle self-compassion is important now',
          'Consider solo activities or quiet time',
          'Avoid major decisions or confrontations',
        ];
      case CyclePhase.follicular:
        return [
          'Embrace your rising energy and optimism',
          'Great time to start new projects',
          'Schedule social activities and networking',
          'Channel confidence into new challenges',
        ];
      case CyclePhase.ovulation:
        return [
          'Peak confidence and charisma - embrace it!',
          'Excellent time for important conversations',
          'Schedule presentations or negotiations',
          'Enjoy your highest social energy',
        ];
      case CyclePhase.luteal:
        return [
          'Practice introspection and self-care',
          'Perfectionist tendencies may peak - be kind to yourself',
          'Exercise with lower intensity if preferred',
          'Journal to process thoughts and emotions',
        ];
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getConfidenceLabel(double score) {
    if (score > 0.85) return 'Very High';
    if (score > 0.70) return 'High';
    if (score > 0.55) return 'Moderate';
    return 'Low';
  }
}

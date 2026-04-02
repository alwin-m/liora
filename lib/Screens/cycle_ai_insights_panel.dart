import 'package:flutter/material.dart';
import '../models/ml_cycle_data.dart';
import '../services/diet_recommendation_service.dart';
import '../core/cycle_session.dart';

/// AI CYCLE INSIGHTS PANEL
///
/// Enhanced, Minimalist & Optimized UI for Menstrual Health Nutrition
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
  late DietGuidance _guidance;
  bool _isLoadingDiet = true;
  String _statusMessage = "Optimizing Plan...";
  String? _errorReason;

  @override
  void initState() {
    super.initState();
    _loadDietGuidance();
  }

  Future<void> _loadDietGuidance() async {
    // Artificial delay for premium skeleton feel
    await Future.delayed(const Duration(milliseconds: 1200));
    
    try {
      if (CycleSession.isInitialized) {
        _guidance = _dietEngine.getPersonalizedGuidance(
          profile: CycleSession.profile,
          phase: widget.phaseInfo.phase,
          dayInPhase: widget.phaseInfo.dayInPhase,
        );
        _statusMessage = "System Secure: Online";
      } else {
        throw Exception("Session Offline: Using Global Fallback");
      }
    } catch (e) {
      _errorReason = e.toString().replaceFirst("Exception: ", "");
      _guidance = _dietEngine.getGuidanceForPhase(
        phase: widget.phaseInfo.phase,
        hasPCOS: false,
      );
      _statusMessage = "System Note: Offline Mode";
      
      // Delay error popup slightly for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showErrorReasoning(_errorReason!);
      });
    }

    if (mounted) {
      setState(() => _isLoadingDiet = false);
    }
  }

  void _showErrorReasoning(String reason) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 12),
                const Text("Reasoning Model", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Our AI encountered a limitation while gathering real-time data.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "ISSUE: $reason",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("CONTINUE IN CACHED MODE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDiet) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: _buildSkeleton(),
      );
    }

    final phaseColor = _getPhaseColor(widget.phaseInfo.phase);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 0),
            ],
          ),
          child: Stack(
            children: [
              ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 14),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  _buildSuperHeader(),
                  
                  _buildPhaseFocusCard(phaseColor),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("DAILY NUTRITION"),
                        _buildEnhancedDietCard(),
                        const SizedBox(height: 32),
                        
                        _buildSectionTitle("BIOLOGICAL STATE"),
                        _buildMinimalInfoCard(
                          Icons.biotech_rounded, 
                          "Hormonal State", 
                          widget.phaseInfo.hormonalExplanation, 
                          Colors.purple.shade400
                        ),
                        const SizedBox(height: 16),
                        _buildMinimalInfoCard(
                          Icons.favorite_rounded, 
                          "Body Changes", 
                          widget.phaseInfo.bodyChangesExplanation, 
                          Colors.red.shade400
                        ),
                        const SizedBox(height: 32),

                        if (widget.phaseInfo.expectedSymptoms.isNotEmpty) ...[
                          _buildSectionTitle("SYMPTOMS WATCH"),
                          _buildSymptomGrid(),
                          const SizedBox(height: 32),
                        ],

                        _buildSectionTitle("EMOTIONAL WELLNESS"),
                        _buildMinimalInfoCard(
                          Icons.self_improvement_rounded, 
                          "Mindfulness", 
                          _getEmotionalGuidance(widget.phaseInfo.phase).join(". "), 
                          Colors.blue.shade400
                        ),
                        const SizedBox(height: 40),

                        _buildConfidenceFooter(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),

              // Back/Close Button - Pixel Perfect Alignment
              Positioned(
                top: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.blueGrey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 140, height: 28, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8))),
                ],
              ),
              Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14))),
            ],
          ),
          const SizedBox(height: 40),
          Container(width: double.infinity, height: 140, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(30))),
          const SizedBox(height: 32),
          Container(width: 120, height: 14, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 250, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(30))),
        ],
      ),
    );
  }

  Widget _buildSuperHeader() {
    final dateStr = '${widget.selectedDate.day} ${_getMonthName(widget.selectedDate.month)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Text(
                    widget.isToday ? 'Today\'s Insights' : dateStr,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusMessage.contains("Online") ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusMessage.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 0.5,
                        color: _statusMessage.contains("Online") ? Colors.green.shade700 : Colors.orange.shade700
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Liora Health',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEEF2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: const Color(0xFFE67598), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseFocusCard(Color color) {
    final focus = _dietEngine.getPhaseFocus(widget.phaseInfo.phase);
    final phaseLabel = widget.phaseInfo.phase.toString().split('.').last.toUpperCase();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(phaseLabel, style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
              const Spacer(),
              Text('DAY ${widget.phaseInfo.dayInPhase}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            focus,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Text(
            widget.prediction.insightSummary,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildEnhancedDietCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          // Metrics Row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withOpacity(0.5),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circularMetric(Icons.water_drop_rounded, _guidance.waterAmount.split(" ").first, "WATER", Colors.blue),
                Container(width: 1, height: 30, color: Colors.green.shade100),
                _circularMetric(Icons.local_fire_department_rounded, _guidance.calories.split(" ").first, "KCALS", Colors.orange),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Suggested for You Today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ..._guidance.bestFoods.map((f) => _buildFoodTile(f, true)),
                
                if (_guidance.avoidFoods.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  const Text("Foods to Avoid", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  const SizedBox(height: 16),
                  ..._guidance.avoidFoods.map((f) => _buildFoodTile(f, false)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularMetric(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFoodTile(FoodItem food, bool isBest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isBest ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(food.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isBest ? Colors.black87 : Colors.redAccent)),
                const SizedBox(height: 4),
                Text(food.reason, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalInfoCard(IconData icon, String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(content, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.phaseInfo.expectedSymptoms.map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
      )).toList(),
    );
  }

  Widget _buildConfidenceFooter() {
    final score = (widget.prediction.confidenceScore * 100).toInt();
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: widget.prediction.confidenceScore,
            strokeWidth: 3,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Confidence", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("$score% accurate for your profile", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return const Color(0xFFE67598);
      case CyclePhase.follicular: return const Color(0xFF5CC091);
      case CyclePhase.ovulation: return const Color(0xFFFDBF44);
      case CyclePhase.luteal: return const Color(0xFF6B8AE6);
    }
  }

  List<String> _getEmotionalGuidance(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return ['Honor rest', 'Self-compassion', 'Solo quiet time'];
      case CyclePhase.follicular: return ['Creativity', 'Social networking', 'New starts'];
      case CyclePhase.ovulation: return ['Peak charisma', 'Important talks', 'High energy'];
      case CyclePhase.luteal: return ['Self-care rituals', 'Gentle movement', 'Journaling'];
    }
  }

  String _getMonthName(int month) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
}

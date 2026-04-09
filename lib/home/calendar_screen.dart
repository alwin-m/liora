import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../widgets/cycle_history_sheet.dart';
import '../services/diet_recommendation_service.dart';
import '../models/ml_cycle_data.dart';
import '../widgets/personalized_diet_sheet.dart';
import '../Screens/cycle_ai_insights_panel.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  CycleAlgorithm get algo => CycleSession.algorithm;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cycle Calendar",
          style: TextStyle(
            color: Color(0xFFE67598),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history,
                color: Color(0xFFE67598)),
            onPressed: _showHistorySheet,
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined,
                color: Color(0xFFE67598)),
            onPressed: _editPeriodDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _calendarCard(),
            const SizedBox(height: 10),
            _selectedDayInsight(),
            const SizedBox(height: 20),
            _dietInfoPanel(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= CALENDAR =================

  Widget _calendarCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: TableCalendar(
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          rowHeight: 48,
          selectedDayPredicate: (d) => isSameDay(d, selectedDay),
          onDaySelected: (s, f) {
            setState(() {
              selectedDay = s;
              focusedDay = f;
            });
            _showDayPopup(s);
          },
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d)),
            todayBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), today: true),
            selectedBuilder: (_, d, __) =>
                _dayBox(d, algo.getType(d), selected: true),
          ),
        ),
      ),
    );
  }

  Widget _dayBox(DateTime day, DayType type,
      {bool selected = false, bool today = false}) {
    Color color = Colors.transparent;

    if (type == DayType.period) {
      color = const Color(0xFFFFE0E6);
    } else if (type == DayType.fertile) {
      color = const Color(0xFFDFF6DD);
    } else if (type == DayType.ovulation) {
      color = const Color(0xFFE8E0F8);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(
                color: const Color(0xFFE67598), width: 1.5)
            : today
                ? Border.all(
                    color: Colors.deepOrangeAccent.withOpacity(0.5),
                    width: 1.5)
                : null,
      ),
      alignment: Alignment.center,
      child: Text(
        "${day.day}",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= BIG INSIGHT CARD =================

  Widget _selectedDayInsight() {
    final type = algo.getType(selectedDay);

    String title;
    String desc;
    Color g1;
    Color g2;

    switch (type) {
      case DayType.period:
        title = "Period Phase";
        desc =
            "Your menstrual phase. Take rest and honor your body.";
        g1 = const Color(0xFFFF9AA2);
        g2 = const Color(0xFFFFB7C5);
        break;

      case DayType.fertile:
        title = "Fertile Window";
        desc =
            "These are your high fertility days. Your body is prepping for ovulation.";
        g1 = const Color(0xFF81C784);
        g2 = const Color(0xFFA5D6A7);
        break;

      case DayType.ovulation:
        title = "Ovulation Day 🌟";
        desc =
            "Peak fertility day of your cycle. Hormone levels are at their highest.";
        g1 = const Color(0xFFB39DDB);
        g2 = const Color(0xFFD1C4E9);
        break;

      default:
        title = "Luteal Phase";
        desc =
            "Post-ovulation balance. Focus on nutrition and mental wellness.";
        g1 = const Color(0xFFF8BBD0);
        g2 = const Color(0xFFFCE4EC);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [g1, g2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: g1.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Date: ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DIET INFO PANEL =================

  Widget _dietInfoPanel() {
    final type = algo.getType(selectedDay);
    CyclePhase phase;

    switch (type) {
      case DayType.period:
        phase = CyclePhase.menstrual;
        break;
      case DayType.fertile:
        phase = CyclePhase.follicular;
        break;
      case DayType.ovulation:
        phase = CyclePhase.ovulation;
        break;
      default:
        phase = CyclePhase.luteal;
    }

    final guidance = DietRecommendationEngine()
        .getPersonalizedGuidance(profile: algo.profile, phase: phase);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade50.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, 
                color: Color(0xFFE67598), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  guidance.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PersonalizedDietSheet(onUpdated: _refresh),
                  );
                },
                icon: const Icon(Icons.tune_rounded, color: Color(0xFFE67598), size: 20),
                tooltip: "Personalize",
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // BMI Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Status: ", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  algo.profile.bmiStatus,
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: algo.profile.bmiStatus == "Normal" ? Colors.green : Colors.orange),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Best Foods Section
          const Text("Recommended for you", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: guidance.bestFoods.map((food) => _foodChip(food, true)).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Avoid Section
          const Text("Better to avoid", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: guidance.avoidFoods.map((food) => _foodChip(food, false)).toList(),
          ),
          
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 20),
          
          // Hydration & Calories (WITH OVERFLOW FIX)
          Row(
            children: [
              Expanded(child: _metricTile(Icons.water_drop_rounded, "Liters", guidance.waterAmount)),
              const SizedBox(width: 12),
              Expanded(child: _metricTile(Icons.local_fire_department_rounded, "Kcal Goal", guidance.calories)),
            ],
          ),

          const SizedBox(height: 24),
          
          // Source
          Center(
            child: Column(
              children: [
                Text(
                  "Tailored for your age (${algo.profile.age}) and BMI",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 10, color: Colors.green.shade300),
                    const SizedBox(width: 4),
                    Text(
                      "Source: ${guidance.source}",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodChip(FoodItem food, bool positive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFF1F8E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: positive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(food.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            food.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: positive ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFE67598)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  // ================= HISTORY SHEET =================

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30)),
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color:
                    Colors.white.withOpacity(0.9),
                child: CycleHistorySheet(
                  history: CycleSession.history,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= EDIT PERIOD =================

  Future<void> _editPeriodDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      await CycleSession.addCycleRecord(picked);

      setState(() {
        selectedDay = picked;
        focusedDay = picked;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Cycle updated successfully"),
        ),
      );
    }
  }

  // ================= AI INSIGHTS POPUP =================

  void _showDayPopup(DateTime date) {
    final type = algo.getType(date);
    CyclePhase phase;
    switch (type) {
      case DayType.period: phase = CyclePhase.menstrual; break;
      case DayType.fertile: phase = CyclePhase.follicular; break;
      case DayType.ovulation: phase = CyclePhase.ovulation; break;
      default: phase = CyclePhase.luteal;
    }

    int dayInPhase = 1;
    if (type == DayType.period) {
      final records = CycleSession.history;
      if (records.isNotEmpty) {
        final last = records.first;
        dayInPhase = date.difference(last.startDate).inDays + 1;
        if (dayInPhase < 1) dayInPhase = 1;
        if (dayInPhase > 7) dayInPhase = 7;
      }
    }

    final phaseInfo = CyclePhaseInfo(
      phase: phase,
      dayInPhase: dayInPhase,
      confidenceScore: 0.94,
      estimatedStartDate: date.subtract(Duration(days: dayInPhase - 1)),
      estimatedEndDate: date.add(const Duration(days: 4)),
      hormonalExplanation: _getHormonalExplanation(phase),
      bodyChangesExplanation: _getBodyChangesExplanation(phase),
      expectedSymptoms: _getExpectedSymptoms(phase),
      recommendedFoods: [],
      foodsToAvoid: [],
    );

    final prediction = MLCyclePrediction(
      nextPeriodDate: algo.getNextPeriodDate(),
      confidenceScore: 0.94,
      phaseInfo: phaseInfo,
      insightSummary: _getInsightSummary(phase),
      personalizedRecommendations: _getRecommendations(phase),
      influencingFactors: ["Cycle Regularity", "Historical Trends"],
      predictionTimestamp: DateTime.now(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CycleAIInsightsPanel(
        selectedDate: date,
        prediction: prediction,
        phaseInfo: phaseInfo,
        isToday: isSameDay(date, DateTime.now()),
      ),
    );
  }

  String _getHormonalExplanation(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Estrogen and progesterone are at their lowest levels as the lining sheds.";
      case CyclePhase.follicular: return "Estrogen is steadily rising to prepare a new follicle in the ovary.";
      case CyclePhase.ovulation: return "Hormonal peak reached! LH and estrogen are driving peak fertility.";
      case CyclePhase.luteal: return "Progesterone is now dominant, preparing the body for the next potential cycle.";
    }
  }

  String _getBodyChangesExplanation(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Core temperature is low, and your uterine muscles are actively recovering.";
      case CyclePhase.follicular: return "Energy and physical resilience are increasing as estrogen builds up.";
      case CyclePhase.ovulation: return "You may experience clearer complexion and a peak in overall physical awareness.";
      case CyclePhase.luteal: return "A slight shift in metabolic rate often leads to increased appetite and lower energy.";
    }
  }

  List<String> _getExpectedSymptoms(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return ["Cramps", "Lower Energy", "Bloating"];
      case CyclePhase.follicular: return ["Fresh Energy", "Clearer Skin"];
      case CyclePhase.ovulation: return ["Peak Vitality", "Confidence Boost"];
      case CyclePhase.luteal: return ["Water Retention", "Food Cravings"];
    }
  }

  String _getInsightSummary(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Prioritize rest. This is your body's phase of deep renewal and recovery.";
      case CyclePhase.follicular: return "Your most productive phase! A perfect time to start projects or focus on growth.";
      case CyclePhase.ovulation: return "You are at your peak. Your confidence and sociability are likely at their height.";
      case CyclePhase.luteal: return "Turn inward. Focus on self-care, mindfulness, and keeping a steady nutrition pace.";
    }
  }

  List<String> _getRecommendations(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return ["Gentle stretching only", "Warm, iron-rich meals"];
      case CyclePhase.follicular: return ["High-impact exercise", "Social networking"];
      case CyclePhase.ovulation: return ["Important meetings", "Intense cardio"];
      case CyclePhase.luteal: return ["Yoga & Meditation", "Magnesium supplements"];
    }
  }
}
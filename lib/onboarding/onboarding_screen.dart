import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/advanced_cycle_profile.dart';
import '../core/cycle_session.dart';
import '../core/app_theme.dart';

class OnboardingQuestionsScreen extends StatefulWidget {
  const OnboardingQuestionsScreen({super.key});

  @override
  State<OnboardingQuestionsScreen> createState() =>
      _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState
    extends State<OnboardingQuestionsScreen> {
  final PageController _controller = PageController();
  int step = 0;

  // ================= BASIC =================
  DateTime? lastPeriodDate;
  int age = 25;
  int cycleLength = 28;
  int periodLength = 5;

  // ================= LIFESTYLE =================
  int stressLevel = 0;
  int sleepHours = 7;
  int waterIntake = 2;
  int exerciseFrequency = 2;

  // ================= HEALTH =================
  bool isRegular = true;
  bool hasPCOS = false;
  bool hasThyroid = false;
  bool heavyFlow = false;
  bool severePain = false;

  // =======================================================

  void _next() {
    if (step < 6) {
      setState(() => step++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _back() {
    if (step > 0) {
      setState(() => step--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    if (lastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select last period date")),
      );
      return;
    }

    int sleepQuality = sleepHours < 6 ? 0 : (sleepHours >= 7 ? 2 : 1);
    int exerciseLevel =
        exerciseFrequency < 2 ? 0 : (exerciseFrequency >= 3 ? 2 : 1);
    int bmiCategory = 1;
    int flowIntensity = heavyFlow ? 2 : 1;
    int painLevel = severePain ? 2 : (stressLevel >= 2 ? 1 : 0);
    int pmsSeverity = waterIntake < 2 ? 1 : 0;

    final profile = AdvancedCycleProfile(
      lastPeriodDate: lastPeriodDate!,
      averageCycleLength: cycleLength,
      averagePeriodLength: periodLength,
      age: age,
      isRegularCycle: isRegular,
      stressLevel: stressLevel,
      painLevel: painLevel,
      pmsSeverity: pmsSeverity,
      flowIntensity: flowIntensity,
      ovulationSymptoms: false,
      sleepQuality: sleepQuality,
      exerciseLevel: exerciseLevel,
      bmiCategory: bmiCategory,
      hasPCOS: hasPCOS,
      hasThyroid: hasThyroid,
      onHormonalMedication: false,
      recentlyPregnant: false,
      breastfeeding: false,
    );

    await CycleSession.saveToLocalStorage(profile);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _progressBar(),
              const SizedBox(height: 30),
              SizedBox(
                height: 420,
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _dateStep(),
                    _numberSlider("Your Age?", age, 10, 50,
                        (v) => age = v),
                    _numberSlider("Cycle Length (days)?",
                        cycleLength, 21, 40,
                        (v) => cycleLength = v),
                    _numberSlider("Period Length (days)?",
                        periodLength, 3, 10,
                        (v) => periodLength = v),
                    _lifestyleStep(),
                    _healthStep(),
                    _finishStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================
  // UI COMPONENTS
  // =======================================================

  Widget _progressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: (step + 1) / 7,
        minHeight: 8,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation(LioraColors.primary),
      ),
    );
  }

  Widget _stepLayout(String title, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : LioraColors.catBlack,
          ),
        ),
        const SizedBox(height: 28),
        body,
        const Spacer(),
        _primaryButton(step == 6 ? "Finish" : "Next"),
        TextButton(
          onPressed: _back,
          style: TextButton.styleFrom(foregroundColor: LioraColors.textMuted),
          child: const Text("Back"),
        ),
      ],
    );
  }

  Widget _numberSlider(
    String title,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return _stepLayout(
      title,
      Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: LioraColors.primary,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: LioraColors.primary,
              overlayColor: LioraColors.primary.withOpacity(0.2),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              value: value.toDouble(),
              onChanged: (v) =>
                  setState(() => onChanged(v.toInt())),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  Widget _dateStep() {
    return _stepLayout(
      "When did your last period start?",
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            initialDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => lastPeriodDate = picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lastPeriodDate == null
                    ? "Select Date"
                    : "${lastPeriodDate!.day}/${lastPeriodDate!.month}/${lastPeriodDate!.year}",
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today, color: LioraColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lifestyleStep() {
    return _stepLayout(
      "Lifestyle",
      Column(
        children: [
          _switchTile("High Stress?", stressLevel == 2,
              (v) => setState(() => stressLevel = v ? 2 : 0)),
          _switchTile("Sleep < 6 hours?", sleepHours < 6,
              (v) => setState(() => sleepHours = v ? 5 : 7)),
          _switchTile("Low Water Intake?", waterIntake < 2,
              (v) => setState(() => waterIntake = v ? 1 : 3)),
          _switchTile("Rare Exercise?", exerciseFrequency < 2,
              (v) => setState(() => exerciseFrequency = v ? 1 : 3)),
        ],
      ),
    );
  }

  Widget _healthStep() {
    return _stepLayout(
      "Health Conditions",
      Column(
        children: [
          _switchTile("Irregular Cycles?", !isRegular,
              (v) => setState(() => isRegular = !v)),
          _switchTile("PCOS?", hasPCOS,
              (v) => setState(() => hasPCOS = v)),
          _switchTile("Thyroid?", hasThyroid,
              (v) => setState(() => hasThyroid = v)),
          _switchTile("Heavy Flow?", heavyFlow,
              (v) => setState(() => heavyFlow = v)),
          _switchTile("Severe Pain?", severePain,
              (v) => setState(() => severePain = v)),
        ],
      ),
    );
  }

  Widget _finishStep() {
    return Column(
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 64, color: LioraColors.primary),
        const SizedBox(height: 16),
        const Text(
          "You're all set ✨",
          style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 30),
        _primaryButton("Start Tracking"),
      ],
    );
  }

  Widget _switchTile(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeThumbColor: LioraColors.primary,
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: LioraColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
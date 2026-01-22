import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../core/cycle_session.dart';
import '../home/cycle_algorithm.dart';
import '../core/cycle_state.dart';
import '../core/cycle_state_manager.dart';

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

  DateTime? dateOfBirth;
  DateTime? lastPeriodDate;
  int cycleLength = 28;
  int periodLength = 5;

  String flowLevel = "Medium";
  String cycleRegularity = "Regular";
  String pmsLevel = "Mild";

  int get age {
    if (dateOfBirth == null) return 0;
    final today = DateTime.now();
    int years = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month &&
            today.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  void _next() {
    if (step < 7) {
      setState(() => step++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ SAVE ONBOARDING DATA TO STATE MANAGER
      _saveOnboardingData();
    }
  }

  /// Save onboarding data to persistent state
  Future<void> _saveOnboardingData() async {
    // Create initial CycleState from onboarding inputs
    final initialState = CycleState(
      bleedingState: BleedingState.noActiveBleeding,
      defaultCycleLength: cycleLength,
      defaultBleedingLength: periodLength,
      averageCycleLength: cycleLength,
      averageBleedingLength: periodLength,
    );

    // If user provided last period date, add it as first confirmed cycle
    if (lastPeriodDate != null) {
      initialState.markPeriodStart(lastPeriodDate!);
      // Immediately mark it as stopped to finalize it
      final periodEnd = lastPeriodDate!.add(Duration(days: periodLength - 1));
      initialState.markPeriodStop(periodEnd);
    }

    // Save to manager (persists to device)
    final manager = CycleStateManager.instance;
    await manager.updateState(initialState);

    // Also update deprecated CycleSession for backward compatibility
    CycleSession.algorithm = CycleAlgorithm(
      lastPeriod: lastPeriodDate ?? DateTime.now(),
      cycleLength: cycleLength,
      periodLength: periodLength,
    );

    // Navigate to home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _back() {
    if (step > 0) {
      setState(() => step--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: (step + 1) / 8,
                color: const Color(0xFFE67598),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 360,
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _dobStep(),
                    _lastPeriodStep(),
                    _cycleLengthStep(),
                    _periodLengthStep(),
                    _flowStep(),
                    _regularityStep(),
                    _pmsStep(),
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

  // STEP 0 — DOB
  Widget _dobStep() {
    return Column(
      children: [
        const Text(
          "Let's know about you in 13 seconds 💗",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          "We'll ask just a few simple questions to personalize your cycle calendar.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        _datePickerBox(
          label: "Date of Birth",
          date: dateOfBirth,
          onPick: (d) => setState(() => dateOfBirth = d),
        ),

        const SizedBox(height: 16),

        if (dateOfBirth != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("So, you're $age years old 🌸"),
          ),

        const Spacer(),
        _primaryButton("Let's go", enabled: dateOfBirth != null),
        TextButton(onPressed: _next, child: const Text("Skip for now")),
      ],
    );
  }

  // STEP 1 — LAST PERIOD
  Widget _lastPeriodStep() => _simpleStep(
        "When did your last menstrual cycle start?",
        _datePickerBox(
          label: "Last Menstrual Cycle Start Date",
          date: lastPeriodDate,
          onPick: (d) => setState(() => lastPeriodDate = d),
        ),
      );

  Widget _cycleLengthStep() => _simpleStep(
        "About how many days are there between your cycles?",
        _pillWrap([21, 24, 27, 28, 30, 32], cycleLength,
            (v) => setState(() => cycleLength = v)),
      );

  Widget _periodLengthStep() => _simpleStep(
        "How long do your periods usually last?",
        _pillWrap([2, 3, 4, 5, 6, 7, 8, 9, 10], periodLength,
            (v) => setState(() => periodLength = v)),
      );

  Widget _flowStep() => _simpleStep(
        "How heavy is your flow usually?",
        _stringWrap(["Light", "Medium", "Heavy"], flowLevel,
            (v) => setState(() => flowLevel = v)),
      );

  Widget _regularityStep() => _simpleStep(
        "Are your cycles usually regular?",
        _stringWrap(["Very regular", "Mostly regular", "Irregular"],
            cycleRegularity, (v) => setState(() => cycleRegularity = v)),
      );

  Widget _pmsStep() => _simpleStep(
        "Do you usually get PMS symptoms?",
        _stringWrap(["None", "Mild", "Moderate", "Severe"], pmsLevel,
            (v) => setState(() => pmsLevel = v)),
      );

  Widget _finishStep() => Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFF4C7D8),
            child: Icon(Icons.check, color: Color(0xFFE67598), size: 32),
          ),
          const SizedBox(height: 16),
          const Text("You're all set ✨",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _primaryButton("Explore Your Calendar"),
        ],
      );

  // UI HELPERS

  Widget _simpleStep(String title, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        body,
        const Spacer(),
        _primaryButton("Let's go"),
        _secondaryButton("Go back", _back),
      ],
    );
  }

  Widget _datePickerBox({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPick,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null
                ? label
                : "${date.day}/${date.month}/${date.year}"),
            const Icon(Icons.calendar_today, color: Color(0xFFE67598)),
          ],
        ),
      ),
    );
  }

  Widget _pillWrap(
      List<int> values, int selected, ValueChanged<int> onSelect) {
    return Wrap(
      spacing: 8,
      children: values
          .map((v) => _pill("$v", selected == v, () => onSelect(v)))
          .toList(),
    );
  }

  Widget _stringWrap(
      List<String> values, String selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 8,
      children: values
          .map((v) => _pill(v, selected == v, () => onSelect(v)))
          .toList(),
    );
  }

  Widget _pill(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE67598) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _primaryButton(String text, {bool enabled = true}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? _next : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE67598),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(text));
  }
}


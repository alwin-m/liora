import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../services/cycle_provider.dart';
import '../home/home_screen.dart';
import '../core/app_theme.dart';

class OnboardingQuestionsScreen extends StatefulWidget {
  const OnboardingQuestionsScreen({super.key});

  @override
  State<OnboardingQuestionsScreen> createState() =>
      _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState extends State<OnboardingQuestionsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int step = 0;

  DateTime? dateOfBirth;
  DateTime? lastPeriodDate;
  int cycleLength = 28;
  int periodLength = 5;

  String flowLevel = "Medium";
  String cycleRegularity = "Regular";
  String pmsLevel = "Mild";

  late final AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: LioraTheme.durationMedium,
    );
    _updateProgressAnimation();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updateProgressAnimation() {
    final oldValue =
        _progressController.isAnimating || _progressController.isCompleted
        ? _progressAnim.value
        : step / 8;
    _progressAnim = Tween<double>(begin: oldValue, end: (step + 1) / 8).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: LioraTheme.curveStandard,
      ),
    );
    _progressController.forward(from: 0);
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final today = DateTime.now();
    int years = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  Future<void> _next() async {
    if (step < 7) {
      setState(() => step++);
      _updateProgressAnimation();
      _controller.nextPage(
        duration: LioraTheme.durationMedium,
        curve: LioraTheme.curveStandard,
      );
    } else {
      final provider = Provider.of<CycleProvider>(context, listen: false);
      await provider.updateCycleData(
        lastPeriodStartDate: lastPeriodDate ?? DateTime.now(),
        averageCycleLength: cycleLength,
        averagePeriodDuration: periodLength,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  void _back() {
    if (step > 0) {
      setState(() => step--);
      _updateProgressAnimation();
      _controller.previousPage(
        duration: LioraTheme.durationMedium,
        curve: LioraTheme.curveStandard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.scrim.withAlpha(120),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(LioraTheme.space16),
          padding: const EdgeInsets.all(LioraTheme.space24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(LioraTheme.radiusSheet),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withAlpha(30),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated progress bar
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(LioraTheme.radiusSmall),
                  child: LinearProgressIndicator(
                    value: _progressAnim.value,
                    minHeight: 4,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: LioraTheme.space24),

              SizedBox(
                height: 360,
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _dobStep(cs),
                    _lastPeriodStep(cs),
                    _cycleLengthStep(cs),
                    _periodLengthStep(cs),
                    _flowStep(cs),
                    _regularityStep(cs),
                    _pmsStep(cs),
                    _finishStep(cs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Steps ─────────────────────────────────────────────────────

  Widget _dobStep(ColorScheme cs) {
    return Column(
      children: [
        Text(
          "Let's know about you in 13 seconds 💗",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LioraTheme.space8),
        Text(
          "We'll ask just a few simple questions to personalize your cycle calendar.",
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurface.withAlpha(160)),
        ),
        const SizedBox(height: LioraTheme.space24),
        _datePickerBox(
          cs: cs,
          label: "Date of Birth",
          date: dateOfBirth,
          onPick: (d) => setState(() => dateOfBirth = d),
        ),
        const SizedBox(height: LioraTheme.space16),
        if (dateOfBirth != null)
          AnimatedOpacity(
            opacity: dateOfBirth != null ? 1.0 : 0.0,
            duration: LioraTheme.durationMedium,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LioraTheme.space16,
                vertical: LioraTheme.space8,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
              ),
              child: Text(
                "So, you're $age years old 🌸",
                style: TextStyle(color: cs.onPrimaryContainer),
              ),
            ),
          ),
        const Spacer(),
        _primaryButton("Let's go", cs, enabled: dateOfBirth != null),
        TextButton(onPressed: _next, child: const Text("Skip for now")),
      ],
    );
  }

  Widget _lastPeriodStep(ColorScheme cs) => _simpleStep(
    cs,
    "When did your last menstrual cycle start?",
    _datePickerBox(
      cs: cs,
      label: "Last Menstrual Cycle Start Date",
      date: lastPeriodDate,
      onPick: (d) => setState(() => lastPeriodDate = d),
    ),
  );

  Widget _cycleLengthStep(ColorScheme cs) => _simpleStep(
    cs,
    "About how many days are there between your cycles?",
    _pillWrap(
      cs,
      [21, 24, 27, 28, 30, 32],
      cycleLength,
      (v) => setState(() => cycleLength = v),
    ),
  );

  Widget _periodLengthStep(ColorScheme cs) => _simpleStep(
    cs,
    "How long do your periods usually last?",
    _pillWrap(
      cs,
      [2, 3, 4, 5, 6, 7, 8, 9, 10],
      periodLength,
      (v) => setState(() => periodLength = v),
    ),
  );

  Widget _flowStep(ColorScheme cs) => _simpleStep(
    cs,
    "How heavy is your flow usually?",
    _stringWrap(
      cs,
      ["Light", "Medium", "Heavy"],
      flowLevel,
      (v) => setState(() => flowLevel = v),
    ),
  );

  Widget _regularityStep(ColorScheme cs) => _simpleStep(
    cs,
    "Are your cycles usually regular?",
    _stringWrap(
      cs,
      ["Very regular", "Mostly regular", "Irregular"],
      cycleRegularity,
      (v) => setState(() => cycleRegularity = v),
    ),
  );

  Widget _pmsStep(ColorScheme cs) => _simpleStep(
    cs,
    "Do you usually get PMS symptoms?",
    _stringWrap(
      cs,
      ["None", "Mild", "Moderate", "Severe"],
      pmsLevel,
      (v) => setState(() => pmsLevel = v),
    ),
  );

  Widget _finishStep(ColorScheme cs) => Column(
    children: [
      const SizedBox(height: LioraTheme.space24),
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, color: cs.primary, size: 32),
      ),
      const SizedBox(height: LioraTheme.space16),
      Text(
        "You're all set ✨",
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: LioraTheme.space32),
      _primaryButton("Explore Your Calendar", cs),
    ],
  );

  // ── UI Helpers ────────────────────────────────────────────────

  Widget _simpleStep(ColorScheme cs, String title, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: LioraTheme.space24),
        body,
        const Spacer(),
        _primaryButton("Let's go", cs),
        _secondaryButton("Go back", _back),
      ],
    );
  }

  Widget _datePickerBox({
    required ColorScheme cs,
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
      child: AnimatedContainer(
        duration: LioraTheme.durationFast,
        padding: const EdgeInsets.all(LioraTheme.space16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(100),
          border: Border.all(
            color: date != null ? cs.primary.withAlpha(120) : cs.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(LioraTheme.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : "${date.day}/${date.month}/${date.year}",
              style: TextStyle(
                color: date == null
                    ? cs.onSurface.withAlpha(140)
                    : cs.onSurface,
              ),
            ),
            Icon(Icons.calendar_today_rounded, color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _pillWrap(
    ColorScheme cs,
    List<int> values,
    int selected,
    ValueChanged<int> onSelect,
  ) {
    return Wrap(
      spacing: LioraTheme.space8,
      runSpacing: LioraTheme.space8,
      children: values
          .map((v) => _pill(cs, "$v", selected == v, () => onSelect(v)))
          .toList(),
    );
  }

  Widget _stringWrap(
    ColorScheme cs,
    List<String> values,
    String selected,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: LioraTheme.space8,
      runSpacing: LioraTheme.space8,
      children: values
          .map((v) => _pill(cs, v, selected == v, () => onSelect(v)))
          .toList(),
    );
  }

  Widget _pill(ColorScheme cs, String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: LioraTheme.durationFast,
        curve: LioraTheme.curveStandard,
        padding: const EdgeInsets.symmetric(
          horizontal: LioraTheme.space16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary
              : cs.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
          border: selected
              ? null
              : Border.all(color: cs.outlineVariant.withAlpha(80)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(String text, ColorScheme cs, {bool enabled = true}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? _next : null,
        child: Text(text),
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(text));
  }
}

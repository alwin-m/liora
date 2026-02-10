import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/liora_theme.dart';
import 'onboarding_step.dart';

/// Cycle/Period length selector step
class CycleLengthStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String unit;

  const CycleLengthStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      title: title,
      subtitle: subtitle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Value display
          _buildValueDisplay(context),

          const SizedBox(height: LioraSpacing.xl),

          // Slider
          _buildSlider(context),

          const SizedBox(height: LioraSpacing.lg),

          // Quick select buttons
          _buildQuickSelect(),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LioraSpacing.xl,
        vertical: LioraSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LioraColors.primaryPink, LioraColors.accentRose],
        ),
        borderRadius: BorderRadius.circular(LioraRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: LioraColors.accentRose.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: LioraTextStyles.h1.copyWith(
              fontSize: 64,
              color: LioraColors.deepRose,
            ),
          ),
          Text(
            unit,
            style: LioraTextStyles.label.copyWith(
              color: LioraColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: LioraColors.accentRose,
          inactiveTrackColor: LioraColors.divider,
          thumbColor: LioraColors.deepRose,
          overlayColor: LioraColors.accentRose.withOpacity(0.2),
          trackHeight: 6,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
        ),
        child: Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (newValue) {
            HapticFeedback.selectionClick();
            onChanged(newValue.round());
          },
        ),
      ),
    );
  }

  Widget _buildQuickSelect() {
    // Show relevant quick select options based on context
    final options = _getQuickSelectOptions();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((option) {
        final isSelected = value == option;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(option);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: LioraSpacing.md,
                vertical: LioraSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? LioraColors.accentRose : Colors.transparent,
                borderRadius: BorderRadius.circular(LioraRadius.round),
                border: Border.all(
                  color:
                      isSelected ? LioraColors.accentRose : LioraColors.divider,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$option',
                style: LioraTextStyles.label.copyWith(
                  color: isSelected ? Colors.white : LioraColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<int> _getQuickSelectOptions() {
    // Provide common values based on the range
    if (min >= 21 && max <= 40) {
      // Cycle length options
      return [25, 28, 30, 32];
    } else if (min >= 2 && max <= 10) {
      // Period length options
      return [3, 4, 5, 6, 7];
    }
    return [];
  }
}

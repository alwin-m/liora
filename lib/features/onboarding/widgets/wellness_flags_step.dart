import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/liora_theme.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_step.dart';

/// Wellness flags selection step
class WellnessFlagsStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> selectedFlags;
  final ValueChanged<String> onFlagToggled;

  const WellnessFlagsStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedFlags,
    required this.onFlagToggled,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      title: title,
      subtitle: subtitle,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: LioraSpacing.sm,
          runSpacing: LioraSpacing.sm,
          alignment: WrapAlignment.center,
          children: WellnessFlags.all.map((flag) {
            final isSelected = selectedFlags.contains(flag.id);

            return _buildFlagChip(flag, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFlagChip(WellnessFlagData flag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFlagToggled(flag.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: LioraSpacing.md,
          vertical: LioraSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [LioraColors.accentRose, LioraColors.deepRose],
                )
              : null,
          color: isSelected ? null : LioraColors.inputBackground,
          borderRadius: BorderRadius.circular(LioraRadius.round),
          border: isSelected
              ? null
              : Border.all(color: LioraColors.inputBorder, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: LioraColors.accentRose.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              flag.label,
              style: LioraTextStyles.label.copyWith(
                color: isSelected ? Colors.white : LioraColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

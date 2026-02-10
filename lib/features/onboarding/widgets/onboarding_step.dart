import 'package:flutter/material.dart';
import '../../../core/theme/liora_theme.dart';

/// Base widget for onboarding steps
class OnboardingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const OnboardingStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: LioraSpacing.lg),

          // Title
          Text(
            title,
            style: LioraTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: LioraTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: LioraSpacing.xl),

          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

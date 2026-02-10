import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/liora_theme.dart';
import '../../../core/engine/prediction_engine.dart';
import '../../cycle/providers/cycle_provider.dart';

/// Cycle status card showing current cycle phase and countdown
class CycleStatusCard extends StatelessWidget {
  const CycleStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final state = provider.cycleState;

        if (!state.hasData) {
          return _buildNoDataCard();
        }

        return _buildStatusCard(state);
      },
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(LioraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, LioraColors.primaryPink],
        ),
        borderRadius: BorderRadius.circular(LioraRadius.xxl),
        boxShadow: LioraShadows.card,
      ),
      child: Column(
        children: [
          const Text(
            '🌱',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: LioraSpacing.md),
          Text(
            'Welcome to LIORA',
            style: LioraTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your period to see predictions',
            style: LioraTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(CycleState state) {
    return Container(
      padding: const EdgeInsets.all(LioraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, LioraColors.primaryPink],
        ),
        borderRadius: BorderRadius.circular(LioraRadius.xxl),
        boxShadow: LioraShadows.card,
      ),
      child: Column(
        children: [
          // Phase emoji and title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.currentPhase.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${state.currentCycleDay}',
                    style: LioraTextStyles.h2.copyWith(
                      color: LioraColors.deepRose,
                    ),
                  ),
                  Text(
                    '${state.currentPhase.displayName} Phase',
                    style: LioraTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: LioraSpacing.lg),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  LioraColors.divider,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: LioraSpacing.lg),

          // Period countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                label: 'Next Period',
                value: state.daysUntilNextPeriod > 0
                    ? '${state.daysUntilNextPeriod} days'
                    : 'Today',
                icon: Icons.calendar_today_rounded,
              ),
              _buildInfoItem(
                label: 'Cycle Length',
                value: '${state.predictedCycleLength} days',
                icon: Icons.loop_rounded,
              ),
              _buildInfoItem(
                label: 'Confidence',
                value: state.confidenceText,
                icon: Icons.insights_rounded,
              ),
            ],
          ),

          // Phase description
          if (state.currentPhase != CyclePhase.menstrual) ...[
            const SizedBox(height: LioraSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LioraSpacing.md,
                vertical: LioraSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: LioraColors.inputBackground,
                borderRadius: BorderRadius.circular(LioraRadius.round),
              ),
              child: Text(
                state.currentPhase.description,
                style: LioraTextStyles.labelSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: LioraColors.accentRose,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: LioraTextStyles.label.copyWith(
            color: LioraColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: LioraTextStyles.bodySmall,
        ),
      ],
    );
  }
}

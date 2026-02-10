import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/liora_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/date_picker_step.dart';
import '../widgets/cycle_length_step.dart';
import '../widgets/wellness_flags_step.dart';
import '../../home/screens/home_screen.dart';

/// Onboarding Screen - AirPods-Style First-Time Flow
///
/// Features:
/// - Bottom sheet modal style
/// - One question per screen
/// - Soft progress indicator
/// - Skip allowed for optional steps
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LioraColors.primaryGradient,
        ),
        child: Stack(
          children: [
            // Background decoration
            _buildBackgroundDecoration(),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0,
                        MediaQuery.of(context).size.height *
                            0.3 *
                            _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Header with logo
                    _buildHeader(),

                    const SizedBox(height: 20),

                    // Onboarding card (AirPods style)
                    Expanded(
                      child: _buildOnboardingCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              LioraColors.accentRose.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LioraSpacing.lg,
        vertical: LioraSpacing.md,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: LioraShadows.soft,
            ),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIORA',
                style: LioraTextStyles.h3.copyWith(
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Let\'s get to know you',
                style: LioraTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingCard() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(LioraRadius.xxl),
            ),
            boxShadow: [
              BoxShadow(
                color: LioraColors.shadow,
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LioraColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Progress indicator
              _buildProgressIndicator(provider),

              // Step content
              Expanded(
                child: _buildStepContent(provider),
              ),

              // Navigation buttons
              _buildNavigationButtons(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(OnboardingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LioraSpacing.lg,
        vertical: LioraSpacing.md,
      ),
      child: Row(
        children: List.generate(provider.totalSteps, (index) {
          final isActive = index == provider.currentStep;
          final isCompleted = index < provider.currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? LioraColors.deepRose
                    : isCompleted
                        ? LioraColors.accentRose
                        : LioraColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(OnboardingProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(provider.currentStep),
        child: _getStepWidget(provider),
      ),
    );
  }

  Widget _getStepWidget(OnboardingProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return DatePickerStep(
          title: provider.getStepTitle(0),
          subtitle: provider.getStepSubtitle(0),
          selectedDate: provider.dateOfBirth,
          onDateSelected: provider.setDateOfBirth,
          maxDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
          minDate: DateTime.now().subtract(const Duration(days: 365 * 60)),
        );
      case 1:
        return DatePickerStep(
          title: provider.getStepTitle(1),
          subtitle: provider.getStepSubtitle(1),
          selectedDate: provider.lastMenstrualPeriod,
          onDateSelected: provider.setLastMenstrualPeriod,
          maxDate: DateTime.now(),
          minDate: DateTime.now().subtract(const Duration(days: 90)),
        );
      case 2:
        return CycleLengthStep(
          title: provider.getStepTitle(2),
          subtitle: provider.getStepSubtitle(2),
          value: provider.averageCycleLength,
          onChanged: provider.setAverageCycleLength,
          min: 21,
          max: 40,
          unit: 'days',
        );
      case 3:
        return CycleLengthStep(
          title: provider.getStepTitle(3),
          subtitle: provider.getStepSubtitle(3),
          value: provider.averagePeriodLength,
          onChanged: provider.setAveragePeriodLength,
          min: 2,
          max: 10,
          unit: 'days',
        );
      case 4:
        return WellnessFlagsStep(
          title: provider.getStepTitle(4),
          subtitle: provider.getStepSubtitle(4),
          selectedFlags: provider.wellnessFlags,
          onFlagToggled: provider.toggleWellnessFlag,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavigationButtons(OnboardingProvider provider) {
    final isLastStep = provider.currentStep == provider.totalSteps - 1;

    return Padding(
      padding: EdgeInsets.only(
        left: LioraSpacing.lg,
        right: LioraSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + LioraSpacing.lg,
        top: LioraSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          if (provider.currentStep > 0)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: provider.previousStep,
                child: Text(
                  'Back',
                  style: LioraTextStyles.label.copyWith(
                    color: LioraColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            const Spacer(flex: 1),

          const SizedBox(width: LioraSpacing.md),

          // Next/Done button
          Expanded(
            flex: 2,
            child: _buildNextButton(provider, isLastStep),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(OnboardingProvider provider, bool isLastStep) {
    return GestureDetector(
      onTap: () async {
        if (isLastStep) {
          final success = await provider.completeOnboarding();
          if (success && mounted) {
            _goToHome();
          }
        } else {
          provider.nextStep();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: provider.canProceed()
              ? const LinearGradient(
                  colors: [LioraColors.accentRose, LioraColors.deepRose],
                )
              : null,
          color: provider.canProceed() ? null : LioraColors.divider,
          borderRadius: BorderRadius.circular(LioraRadius.large),
          boxShadow: provider.canProceed()
              ? [
                  BoxShadow(
                    color: LioraColors.accentRose.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: provider.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep ? 'Get Started' : 'Continue',
                      style: LioraTextStyles.button.copyWith(
                        color: provider.canProceed()
                            ? Colors.white
                            : LioraColors.textMuted,
                      ),
                    ),
                    if (!isLastStep) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: provider.canProceed()
                            ? Colors.white
                            : LioraColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

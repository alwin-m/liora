import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/liora_theme.dart';
import '../../cycle/providers/cycle_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/cycle_status_card.dart';
import '../widgets/calendar_view.dart';
import '../widgets/day_details_sheet.dart';
import '../widgets/profile_drawer.dart';

/// Home Screen - Main Cycle Tracking Interface
///
/// Features:
/// - Beautiful cycle status card
/// - Interactive calendar view
/// - Day details bottom sheet
/// - Profile drawer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    // Refresh cycle data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showDayDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DayDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LioraColors.primaryGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                HomeHeader(
                  onProfileTap: _openProfileDrawer,
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: LioraSpacing.md),

                        // Cycle Status Card
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
                          child: CycleStatusCard(),
                        ),

                        const SizedBox(height: LioraSpacing.lg),

                        // Calendar View
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: LioraSpacing.md),
                          child: CalendarView(
                            onDaySelected: (date) {
                              context.read<CycleProvider>().selectDate(date);
                              _showDayDetails();
                            },
                          ),
                        ),

                        const SizedBox(height: LioraSpacing.xl),

                        // Legend
                        _buildLegend(),

                        const SizedBox(height: LioraSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating action button for quick period logging
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(LioraSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LioraRadius.large),
          boxShadow: LioraShadows.soft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(LioraColors.periodDay, 'Period'),
            _buildLegendItem(LioraColors.predictedPeriod, 'Predicted'),
            _buildLegendItem(LioraColors.fertileWindow, 'Fertile'),
            _buildLegendItem(LioraColors.ovulationDay, 'Ovulation'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: LioraTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFab() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton.extended(
          onPressed: () => _showQuickLogSheet(),
          backgroundColor: LioraColors.deepRose,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Log Period',
            style: LioraTextStyles.label.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }

  void _showQuickLogSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickLogSheet(
        onPeriodStarted: () async {
          final today = DateTime.now();
          await context.read<CycleProvider>().logPeriodStart(today);
          if (mounted) Navigator.pop(context);
        },
        onPeriodEnded: () async {
          // Mark today as last period day
          final today = DateTime.now();
          await context.read<CycleProvider>().markPeriodDay(today, true);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

class _QuickLogSheet extends StatelessWidget {
  final VoidCallback onPeriodStarted;
  final VoidCallback onPeriodEnded;

  const _QuickLogSheet({
    required this.onPeriodStarted,
    required this.onPeriodEnded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LioraSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LioraRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LioraColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: LioraSpacing.lg),

          Text(
            'Quick Log',
            style: LioraTextStyles.h3,
          ),
          const SizedBox(height: LioraSpacing.lg),

          // Period started button
          _buildOption(
            icon: '🌸',
            title: 'Period Started',
            subtitle: 'Mark today as the start of a new cycle',
            onTap: onPeriodStarted,
          ),

          const SizedBox(height: LioraSpacing.md),

          // Period day button
          _buildOption(
            icon: '💧',
            title: 'Log Period Day',
            subtitle: 'Mark today as a period day',
            onTap: onPeriodEnded,
          ),

          SizedBox(
              height: MediaQuery.of(context).padding.bottom + LioraSpacing.md),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(LioraSpacing.md),
        decoration: BoxDecoration(
          color: LioraColors.inputBackground,
          borderRadius: BorderRadius.circular(LioraRadius.large),
          border: Border.all(color: LioraColors.inputBorder),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: LioraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: LioraTextStyles.label),
                  Text(subtitle, style: LioraTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: LioraColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

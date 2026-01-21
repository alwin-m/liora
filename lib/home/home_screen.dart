import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';
import '../core/components.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeTab(),
      const TrackerScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.surfaceContainerHigh,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.lg,
            vertical: AppTheme.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_filled,
                label: 'Home',
                isActive: _currentIndex == 0,
                onTap: () => _updateIndex(0),
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month,
                label: 'Tracker',
                isActive: _currentIndex == 1,
                onTap: () => _updateIndex(1),
              ),
              _NavItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                label: 'Shop',
                isActive: _currentIndex == 2,
                onTap: () => _updateIndex(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: _currentIndex == 3,
                onTap: () => _updateIndex(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.durationSm,
      vsync: this,
    );
    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1, end: 1.15)
                .animate(_controller),
            child: Icon(
              widget.isActive ? widget.activeIcon : widget.icon,
              color: widget.isActive
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          Text(
            widget.label,
            style: AppTheme.labelMedium.copyWith(
              color: widget.isActive
                  ? AppTheme.primary
                  : AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HOME TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userStream =
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with greeting
            Padding(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: StreamBuilder<DocumentSnapshot>(
                stream: _userStream,
                builder: (context, snapshot) {
                  String name = 'Welcome';
                  if (snapshot.hasData && snapshot.data != null) {
                    name =
                        snapshot.data!['name'] ?? 'Welcome';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $name 👋',
                        style: AppTheme.displayMedium,
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        'How are you feeling today?',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
              child: Column(
                children: [
                  // Cycle status card
                  _CycleStatusCard(),
                  const SizedBox(height: AppTheme.lg),

                  // Quick actions
                  _QuickActionsGrid(),
                  const SizedBox(height: AppTheme.lg),

                  // Insights section
                  _InsightsSection(),
                  const SizedBox(height: AppTheme.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleStatusCard extends StatelessWidget {
  const _CycleStatusCard();

  @override
  Widget build(BuildContext context) {
    return SoftContainer(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Cycle',
            style: AppTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.lg),
          Row(
            children: [
              Expanded(
                child: _CycleInfo(
                  label: 'Current Phase',
                  value: 'Menstrual',
                  icon: Icons.circle,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(width: AppTheme.lg),
              Expanded(
                child: _CycleInfo(
                  label: 'Day in Cycle',
                  value: '3 / 28',
                  icon: Icons.calendar_today_outlined,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.lg),
          ClipRRect(
            borderRadius: AppTheme.roundedSm,
            child: LinearProgressIndicator(
              value: 3 / 28,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CycleInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppTheme.sm),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppTheme.sm),
        Text(
          value,
          style: AppTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.favorite_outline,
                label: 'Log Symptoms',
                onTap: () {
                  showCalmSnackBar(
                    context,
                    message: 'Symptom logging coming soon',
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.mood_outlined,
                label: 'Log Mood',
                onTap: () {
                  showCalmSnackBar(
                    context,
                    message: 'Mood tracking coming soon',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Workouts',
                onTap: () {
                  showCalmSnackBar(
                    context,
                    message: 'Workout tracking coming soon',
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.lightbulb_outline,
                label: 'Insights',
                onTap: () {
                  showCalmSnackBar(
                    context,
                    message: 'Personalized insights coming soon',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: AppTheme.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primary,
            ),
            const SizedBox(height: AppTheme.md),
            Text(
              label,
              style: AppTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Insights',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.md),
        SoftContainer(
          child: Column(
            children: [
              _InsightItem(
                icon: Icons.energy_savings_leaf_outlined,
                title: 'Energy Level',
                description: 'Stay active during your follicular phase',
              ),
              Divider(
                color: AppTheme.surfaceContainerHigh,
                height: AppTheme.lg * 2,
              ),
              _InsightItem(
                icon: Icons.restaurant_outlined,
                title: 'Nutrition Tip',
                description: 'Increase iron intake during menstruation',
              ),
              Divider(
                color: AppTheme.surfaceContainerHigh,
                height: AppTheme.lg * 2,
              ),
              _InsightItem(
                icon: Icons.water_outlined,
                title: 'Wellness',
                description: 'Drink plenty of water and stay hydrated',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InsightItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: AppTheme.roundedMd,
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.xs),
              Text(
                description,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

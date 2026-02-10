import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/liora_theme.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

/// Instagram-style profile drawer
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(LioraRadius.xxl),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LioraColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),

              const SizedBox(height: LioraSpacing.lg),

              // Settings sections
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: 'Notifications',
                        children: [
                          _buildNotificationToggle(context),
                        ],
                      ),
                      const SizedBox(height: LioraSpacing.lg),
                      _buildSection(
                        title: 'Data & Privacy',
                        children: [
                          _buildMenuItem(
                            icon: Icons.download_rounded,
                            title: 'Export Data',
                            subtitle: 'Download your data as JSON',
                            onTap: () => _exportData(context),
                          ),
                          _buildMenuItem(
                            icon: Icons.delete_outline_rounded,
                            title: 'Reset All Data',
                            subtitle: 'Clear all local cycle data',
                            onTap: () => _showResetConfirmation(context),
                            isDestructive: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: LioraSpacing.lg),
                      _buildSection(
                        title: 'About',
                        children: [
                          _buildMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About LIORA',
                            subtitle: 'Version 1.0.0',
                            onTap: () => _showAbout(context),
                          ),
                          _buildMenuItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            subtitle: 'How we protect your data',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Logout button
              _buildLogoutButton(context),

              SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + LioraSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Container(
          padding: const EdgeInsets.all(LioraSpacing.lg),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LioraColors.accentRose, LioraColors.deepRose],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: LioraShadows.soft,
                ),
                child: Center(
                  child: Text(
                    _getInitials(
                        auth.user?.displayName ?? auth.user?.email ?? 'U'),
                    style: LioraTextStyles.h2.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: LioraSpacing.md),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?.displayName ?? 'Welcome',
                      style: LioraTextStyles.h3,
                    ),
                    Text(
                      auth.user?.email ?? '',
                      style: LioraTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Close button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LioraTextStyles.labelSmall.copyWith(
            color: LioraColors.textMuted,
          ),
        ),
        const SizedBox(height: LioraSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LioraRadius.large),
            boxShadow: LioraShadows.soft,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final storage = StorageService.instance;
        bool periodReminder = storage.getPeriodReminderEnabled();
        bool dailyReminder = storage.getDailyReminderEnabled();

        return Column(
          children: [
            SwitchListTile(
              title: Text('Period Reminders', style: LioraTextStyles.label),
              subtitle: Text(
                'Get notified before your period',
                style: LioraTextStyles.bodySmall,
              ),
              value: periodReminder,
              activeColor: LioraColors.deepRose,
              onChanged: (value) async {
                await storage.saveNotificationSettings(periodReminder: value);
                setState(() {});
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: Text('Daily Check-in', style: LioraTextStyles.label),
              subtitle: Text(
                'Reminder to log your day',
                style: LioraTextStyles.bodySmall,
              ),
              value: dailyReminder,
              activeColor: LioraColors.deepRose,
              onChanged: (value) async {
                await storage.saveNotificationSettings(dailyReminder: value);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? LioraColors.error : LioraColors.textSecondary,
      ),
      title: Text(
        title,
        style: LioraTextStyles.label.copyWith(
          color: isDestructive ? Colors.red : LioraColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: LioraTextStyles.bodySmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: LioraColors.textMuted,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: LioraColors.textSecondary,
          side: const BorderSide(color: LioraColors.divider),
          padding: const EdgeInsets.symmetric(vertical: LioraSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LioraRadius.large),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign Out'),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _exportData(BuildContext context) {
    // Export feature - in a real app, would save to file or share
    StorageService.instance.exportData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data export feature coming soon'),
        backgroundColor: LioraColors.accentRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraRadius.medium),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your cycle data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.instance.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data has been reset'),
                    backgroundColor: LioraColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LioraRadius.medium),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'Your data will remain safely stored on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('🌸', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text('LIORA', style: LioraTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Privacy-First Menstrual Wellness Companion',
              style: LioraTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'LIORA exists to care for rhythm, not control it. All your sensitive data stays on your device—never uploaded to any server.',
              style: LioraTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: LioraTextStyles.labelSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

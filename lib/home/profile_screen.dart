import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../core/components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Text(
                'Profile',
                style: AppTheme.displayMedium,
              ),
            ),

            // User info card
            StreamBuilder<DocumentSnapshot>(
              stream: _userStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final name = userData['name'] ?? 'User';
                final email = userData['email'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.lg,
                  ),
                  child: SoftContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Center(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: AppTheme.roundedXl,
                              boxShadow: AppTheme.shadowSm,
                            ),
                            child: Center(
                              child: Text(
                                name[0].toUpperCase(),
                                style: AppTheme.displayLarge.copyWith(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.lg),

                        // Name
                        Center(
                          child: Text(
                            name,
                            style: AppTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: AppTheme.sm),

                        // Email
                        Center(
                          child: Text(
                            email,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.lg),

                        // Edit profile button
                        SizedBox(
                          width: double.infinity,
                          child: MinimalButton(
                            label: 'Edit Profile',
                            onPressed: () {
                              showCalmSnackBar(
                                context,
                                message: 'Edit profile coming soon',
                              );
                            },
                            isSecondary: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppTheme.xl),

            // Settings section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.lg),

                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      showCalmSnackBar(
                        context,
                        message: 'Notification settings coming soon',
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      showCalmSnackBar(
                        context,
                        message: 'Change password coming soon',
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Security',
                    onTap: () {
                      showCalmSnackBar(
                        context,
                        message: 'Privacy settings coming soon',
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      showCalmSnackBar(
                        context,
                        message: 'Help coming soon',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // About section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: AppTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.lg),

                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Liora',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Liora',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Liora. All rights reserved.',
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      showCalmSnackBar(
                        context,
                        message: 'Terms coming soon',
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.gavel_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      showCalmSnackBar(
                        context,
                        message: 'Privacy policy coming soon',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: MinimalButton(
                  label: 'Sign Out',
                  onPressed: () {
                    _handleLogout(context);
                  },
                  isSecondary: true,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.xxl),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.roundedLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_outlined,
                size: 48,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppTheme.lg),
              Text(
                'Sign Out',
                style: AppTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.md),
              Text(
                'Are you sure you want to sign out?',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.xl),
              Row(
                children: [
                  Expanded(
                    child: MinimalButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: AppTheme.lg),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.lg,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: AppTheme.roundedMd,
                        ),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: AppTheme.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftContainer(
        padding: const EdgeInsets.all(AppTheme.lg),
        onTap: onTap,
        child: Row(
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
              child: Text(
                title,
                style: AppTheme.labelLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

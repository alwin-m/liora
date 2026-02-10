import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/liora_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Home screen header with logo and profile button
class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LioraSpacing.lg,
        vertical: LioraSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and title
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: LioraShadows.soft,
                ),
                child: const Center(
                  child: Text('🌸', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIORA',
                    style: LioraTextStyles.h3.copyWith(letterSpacing: 2),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      final greeting = _getGreeting();
                      final name = auth.user?.displayName ?? 'there';
                      return Text(
                        '$greeting, $name',
                        style: LioraTextStyles.bodySmall,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Profile button
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: LioraShadows.soft,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: LioraColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

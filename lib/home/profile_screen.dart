import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:lioraa/Screens/Login_Screen.dart';
import 'package:lioraa/Screens/change_password_screen.dart';
import 'package:lioraa/Screens/my_orders_screen.dart';
import 'package:lioraa/services/cycle_provider.dart';
import 'package:lioraa/core/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'User';
  bool _isLoadingName = true;
  Uint8List? _profileImageBytes;
  static const String _profileImageKey = 'local_profile_image';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadLocalProfileImage();
  }

  Future<void> _loadLocalProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString(_profileImageKey);
    if (base64Image != null) {
      setState(() {
        _profileImageBytes = base64Decode(base64Image);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, base64Image);

      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  void _showAboutLeora() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withAlpha(60),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1.drive(
                Tween(
                  begin: 0.9,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'About Leora',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Leora is a thoughtfully designed women's cycle wellness application developed as a final-year project by the Computer Engineering Department of Government Polytechnic Purapuzha (S6 – Semester 6). Built to address real-world cycle tracking needs with privacy-first local data storage, Leora blends wellness tracking with a refined, minimal shopping experience.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: const Color(0xFF5A5A5A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "A project by the Computer Engineering Department, Government Polytechnic Purapuzha.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF7A7A7A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () =>
                              _launchURL('https://github.com/alwin-m/liora'),
                          child: Text(
                            'GitHub Repository',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: LioraTheme.blushRose,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: LioraTheme.blushRose,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Handle error gracefully
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('name')) {
        if (mounted) {
          setState(() {
            userName = doc['name'];
            _isLoadingName = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingName = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingName = false);
    }
  }

  Future<void> _logout() async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of Liora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(cs),
          _buildProfileHeader(cs),
          _buildCyclePreview(cs),
          _buildSettingsList(cs),
          const SliverToBoxAdapter(child: SizedBox(height: LioraTheme.space48)),
        ],
      ),
    );
  }

  Widget _buildAppBar(ColorScheme cs) {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      title: Text(
        'Profile',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _logout,
          icon: Icon(
            Icons.logout_rounded,
            color: LioraTheme.textSecondary.withAlpha(150),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LioraTheme.space24,
          vertical: 40,
        ),
        child: Column(
          children: [
            // Luxury Profile Image Ring
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LioraTheme.blushRose,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _profileImageBytes != null
                            ? Image.memory(
                                _profileImageBytes!,
                                key: ValueKey(_profileImageBytes.hashCode),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                key: const ValueKey('placeholder'),
                                color: LioraTheme.lavenderMuted.withAlpha(100),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 50,
                                  color: LioraTheme.textSecondary,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: LioraTheme.pureWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: LioraTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LioraTheme.space24),

            // User identity
            _isLoadingName
                ? const SizedBox(
                    width: 80,
                    height: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: LinearProgressIndicator(
                        backgroundColor: LioraTheme.offWhiteWarm,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LioraTheme.lavenderMuted,
                        ),
                      ),
                    ),
                  )
                : Text(
                    userName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: LioraTheme.textPrimary,
                    ),
                  ),
            const SizedBox(height: 4),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? 'wellness@liora.com',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: LioraTheme.textSecondary,
              ),
            ),

            const SizedBox(height: LioraTheme.space20),

            // Privacy Commitment Note
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LioraTheme.space24,
              ),
              child: Column(
                children: [
                  Text(
                    'Local Profile Identity',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: LioraTheme.textSecondary.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your photo stays on this device only. It is never uploaded or stored on any server. Deleting the app removes the photo permanently.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: LioraTheme.textSecondary.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePreview(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Consumer<CycleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.cycleData == null) {
            return const SizedBox.shrink();
          }
          final data = provider.cycleData!;
          final nextStart = data.computedNextPeriodStart;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: LioraTheme.space24),
            padding: const EdgeInsets.all(LioraTheme.space20),
            decoration: BoxDecoration(
              color: LioraTheme.pureWhite,
              borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LioraTheme.sageGreen.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: LioraTheme.sageGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Cycle',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: LioraTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Expected on ${nextStart.day} ${_getMonth(nextStart.month)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: LioraTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: LioraTheme.textSecondary.withAlpha(100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsList(ColorScheme cs) {
    return SliverPadding(
      padding: const EdgeInsets.all(LioraTheme.space24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSectionHeader('Account Settings'),
          _buildSettingItem(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track and manage your wellness kits',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),
          _buildSettingItem(
            icon: Icons.lock_outline_rounded,
            title: 'Security',
            subtitle: 'Change your password and manage sessions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const SizedBox(height: LioraTheme.space12),
          _buildSectionHeader('Preferences'),
          _buildToggleItem(
            icon: Icons.notifications_none_rounded,
            title: 'Cycle Reminders',
            value: true,
            onChanged: (v) {},
          ),
          _buildToggleItem(
            icon: Icons.color_lens_outlined,
            title: 'Dynamic Colors',
            value: true,
            onChanged: (v) {},
          ),
          const SizedBox(height: LioraTheme.space12),
          _buildSectionHeader('Legal'),
          _buildSettingItem(
            icon: Icons.info_outline_rounded,
            title: 'About Leora',
            subtitle: 'Academic Project • S6 Computer Engineering',
            onTap: _showAboutLeora,
          ),
          _buildSettingItem(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            titleColor: cs.error,
            onTap: _confirmDeleteAccount,
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: LioraTheme.space12,
        top: LioraTheme.space8,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: LioraTheme.space12),
      decoration: BoxDecoration(
        color: LioraTheme.pureWhite,
        borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LioraTheme.lavenderMuted.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: titleColor ?? LioraTheme.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: titleColor ?? LioraTheme.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: LioraTheme.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: LioraTheme.textSecondary.withAlpha(100),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: LioraTheme.space12),
      decoration: BoxDecoration(
        color: LioraTheme.pureWhite,
        borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LioraTheme.sageGreen.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: LioraTheme.textPrimary,
            size: 20,
          ),
        ),
        activeColor: LioraTheme.blushRose,
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: LioraTheme.textPrimary,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: TextStyle(color: cs.error)),
        content: const Text(
          'This action is permanent and will delete all your cycle data and history. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please re-login before deleting your account'),
            ),
          );
        }
      }
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

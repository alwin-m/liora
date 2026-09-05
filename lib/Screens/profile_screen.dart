import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/security_service.dart';
import '../core/app_theme.dart';
import 'security_privacy_screen.dart';
import 'change_password_screen.dart';
import 'your_details_screen.dart';
import 'my_orders_screen.dart';
import 'about_screen.dart';
import 'Login_Screen.dart';

/// Profile Screen - Central Hub for User Settings
///
/// Features:
/// - Security & App Lock (PIN, Biometric, Recovery)
/// - Account Management (Change Password)
/// - Personal Information (Name, Address, Phone for autofill)
/// - Orders Management (View, Cancel orders)
/// - App Information (About, Privacy, Terms)
/// - Logout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (_currentUser != null) {
        final doc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (mounted) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF6F9),
        title: const Text(
          "Logout?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "You'll need to log in again to access your account. Your local data will remain encrypted on this device.",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67598),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Security cleanup
        await SecurityService.onUserLogout();

        // Firebase logout
        await _auth.signOut();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Logout error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE67598)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 User Information Card
                  _buildUserHeader(),

                  const SizedBox(height: 40),

                  // 🔐 SECURITY & LOCK SECTION
                  _buildSectionHeader("Security & Protection"),
                  _buildNavigationTile(
                    icon: Icons.lock_person_rounded,
                    title: "Security & App Lock",
                    subtitle: "PIN, Biometric, Recovery",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecurityPrivacyScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🔑 ACCOUNT MANAGEMENT SECTION
                  const SizedBox(height: 32),
                  _buildSectionHeader("Account Management"),
                  _buildNavigationTile(
                    icon: Icons.lock_outline_rounded,
                    title: "Change Password",
                    subtitle: "Update your Liora login password",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNavigationTile(
                    icon: Icons.verified_outlined,
                    title: "Email Verification",
                    subtitle: _currentUser?.emailVerified == true
                        ? "✓ Verified"
                        : "Not verified",
                    onTap: _currentUser?.emailVerified == false
                        ? () => _showVerifyEmailDialog()
                        : null,
                  ),

                  // 👤 PERSONAL INFORMATION SECTION
                  const SizedBox(height: 32),
                  _buildSectionHeader("Personal Information"),
                  _buildNavigationTile(
                    icon: Icons.person_outline_rounded,
                    title: "Your Details",
                    subtitle: "Name, phone, address (for autofill)",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const YourDetailsScreen(),
                      ),
                    ),
                  ),

                  // 📦 SHOPPING SECTION
                  const SizedBox(height: 32),
                  _buildSectionHeader("Shopping"),
                  _buildNavigationTile(
                    icon: Icons.shopping_bag_outlined,
                    title: "My Orders",
                    subtitle: "View and manage your orders",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                    ),
                  ),

                  // ℹ️ APP INFORMATION SECTION
                  const SizedBox(height: 32),
                  _buildSectionHeader("About Liora"),
                  _buildNavigationTile(
                    icon: Icons.info_outline_rounded,
                    title: "About",
                    subtitle: "Version, privacy, terms",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNavigationTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    onTap: () {
                      // Navigate to privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Privacy Policy opens in the About section",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNavigationTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    subtitle: "Terms and conditions",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Terms of Service opens in the About section",
                          ),
                        ),
                      );
                    },
                  ),

                  // 🚪 SESSION SECTION
                  const SizedBox(height: 32),
                  _buildSectionHeader("Session"),
                  _buildNavigationTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ============= WIDGET BUILDERS =============

  Widget _buildUserHeader() {
    final email = _currentUser?.email ?? "Loading...";
    final displayName =
        _userData?['displayName'] ?? _currentUser?.displayName ?? "User";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE67598), Color(0xFFD85F8A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: _currentUser?.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(_currentUser!.photoURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _currentUser?.photoURL == null
                ? const Icon(Icons.person, size: 40, color: Color(0xFFE67598))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.shade50
                    : const Color(0xFFFDF6F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFFE67598),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF6F9),
        title: const Text("Verify Email?"),
        content: const Text(
          "We'll send a verification link to your email. Check your inbox and confirm to verify your account.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("LATER"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _currentUser?.sendEmailVerification();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Verification email sent! Check your inbox.",
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67598),
            ),
            child: const Text("SEND", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

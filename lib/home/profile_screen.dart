import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../core/notification_service.dart';
import '../core/app_settings.dart';
import '../services/connectivity_service.dart';
import '../widgets/status_bottom_sheet.dart';
import '../Screens/Login_Screen.dart';
import '../Screens/your_details_screen.dart';
import '../Screens/change_password_screen.dart';
import '../Screens/security_privacy_screen.dart';
import '../Screens/about_screen.dart';
import '../Screens/my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late CycleAlgorithm algo;
  String userName = "Liora User";
  bool _isLoading = true;
  bool _periodReminder = true;
  bool _dailyAlert = true;
  String _systemStatus = "Optimized";

  final ImagePicker _picker = ImagePicker();

  final List<String> defaultAvatars = [
    "assets/avatars/1.png",
    "assets/avatars/2.png",
    "assets/avatars/3.png",
    "assets/avatars/4.png",
  ];

  @override
  void initState() {
    super.initState();
    algo = CycleSession.algorithm;
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc['name'] ?? "Liora User";
          });
        }
      } catch (e) {
        debugPrint("User data load error: $e");
      }
    }
    
    final isOnline = await ConnectivityService().isConnected();
    final dailyAlert = await AppSettings.getDailyCycleAlert();

    setState(() {
      _systemStatus = isOnline ? "Online" : "Cached";
      _dailyAlert = dailyAlert;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
      if (picked == null) return;
      
      final bytes = await picked.readAsBytes();
      final base64 = base64Encode(bytes);
      
      await CycleSession.updateProfile(CycleSession.profile.copyWith(profileImage: base64));
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Photo Updated ✓")));
    } catch (e) {
      debugPrint("Gallery upload error: $e");
    }
  }

  Future<void> _selectAvatar(String asset) async {
    await CycleSession.updateProfile(CycleSession.profile.copyWith(profileImage: asset));
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Character Selected ✓")));
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Personalize Your Character", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: defaultAvatars.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    _selectAvatar(defaultAvatars[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE67598).withOpacity(0.2), width: 2),
                    ),
                    child: CircleAvatar(radius: 40, backgroundImage: AssetImage(defaultAvatars[index])),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFFE67598)),
              title: const Text("Upload from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (CycleSession.profile.profileImage != null)
              ListTile(
                leading: const Icon(Icons.no_accounts_rounded, color: Colors.grey),
                title: const Text("Reset to Default"),
                onTap: () async {
                  await CycleSession.updateProfile(CycleSession.profile.copyWith(profileImage: null));
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
    }
  }

  void _showPhilosophy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Our Philosophy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Text(
              "Liora is built on the Japanese concept of Ikigai — finding purpose and harmony in every action.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE67598)),
            ),
            const SizedBox(height: 12),
            Text(
              "Design with Reason: Every feature in Liora exists for a reason. We don't just track data; we transform it into meaningful insights that make your life smoother, faster, and more stable.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              "Intuitive for All: Whether you are a beginner or an expert, Liora is designed to be understood instantly. We believe clarity is the highest form of technology.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67598),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("UNDERSTOOD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Privacy Protocol"),
        content: const Text(
          "Your health data is encrypted and stored securely. We use it exclusively to personalize your cycle predictions and nutritional guidance. We never sell your data.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("SECURE", style: TextStyle(color: Color(0xFFE67598))))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFE67598))));

    final profile = CycleSession.profile;
    final healthScore = algo.calculateHealthScore(CycleSession.history).toInt();
    final streak = algo.getTrackingStreak(CycleSession.history);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCenteredHeader(profile),
              const SizedBox(height: 32),
              _buildMetricGrid(healthScore, streak),
              const SizedBox(height: 32),
              _buildSectionTitle("JOURNEY PREFERENCES"),
              _buildActionCard(Icons.auto_awesome_outlined, "Liora Philosophy", onTap: _showPhilosophy),
              _buildActionCard(Icons.person_outline_rounded, "Your Details", onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const YourDetailsScreen()));
              }),
              _buildActionCard(Icons.shopping_bag_outlined, "My Orders", onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
              }),
              _buildActionCard(Icons.notifications_active_rounded, "Cycle Reminders", trailing: Switch.adaptive(
                value: _periodReminder, 
                activeColor: const Color(0xFFE67598),
                onChanged: (v) {
                  setState(() => _periodReminder = v);
                  if (v) NotificationService.reschedulePeriodReminder(algo.getNextPeriodDate());
                  else NotificationService.cancelPeriodReminder();
                }
              )),
              
              _buildActionCard(Icons.calendar_today_rounded, "Daily Cycle Updates", trailing: Switch.adaptive(
                value: _dailyAlert, 
                activeColor: const Color(0xFFE67598),
                onChanged: (v) async {
                  setState(() => _dailyAlert = v);
                  await AppSettings.saveDailyCycleAlert(v);
                  if (v) await NotificationService.scheduleDailyCycleAlerts();
                  else await NotificationService.cancelDailyAlerts();
                }
              )),

              const SizedBox(height: 32),
              _buildSectionTitle("SECURITY & PROTECTION"),
              _buildActionCard(Icons.security_rounded, "App Lock & Privacy", onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()));
              }),
              _buildActionCard(Icons.key_rounded, "Change Password", onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              }),
              
              const SizedBox(height: 32),
              _buildSectionTitle("ACCOUNT & TRUST"),
              _buildActionCard(Icons.info_outline_rounded, "About Liora", onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              }),
              _buildActionCard(Icons.support_agent_rounded, "Liora Support", onTap: () {}),
              _buildActionCard(Icons.verified_user_rounded, "Privacy Protocol", onTap: _showPrivacy),
              _buildActionCard(Icons.logout_rounded, "Secure Sign Out", isDestructive: true, onTap: _logout),
              
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () async {
                  final isOnline = await ConnectivityService().isConnected();
                  StatusBottomSheet.showVersionStatus(context, isOnline, "v1.2.0-luxe");
                },
                child: Column(
                  children: [
                    Text("Liora v1.2.0 • System: $_systemStatus", style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text("Made with clinical care for your wellness", style: TextStyle(color: Colors.grey.shade300, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredHeader(profile) {
    ImageProvider? img;
    final pImg = profile.profileImage;
    if (pImg != null) {
      if (pImg.startsWith("assets/")) img = AssetImage(pImg);
      else img = MemoryImage(base64Decode(pImg));
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE67598).withOpacity(0.3), width: 3),
              ),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.white,
                backgroundImage: img,
                child: img == null ? const Icon(Icons.face_retouching_natural_rounded, size: 60, color: Color(0xFFE67598)) : null,
              ),
            ),
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFE67598), shape: BoxShape.circle),
                child: const Icon(Icons.auto_fix_high_rounded, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(userName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFFDEEF2), borderRadius: BorderRadius.circular(20)),
          child: const Text("PRO PREDICTOR MODEL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFE67598), letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildMetricGrid(int score, int streak) {
    return Row(
      children: [
        _metricTile("HEALTH", "$score%", Colors.green.shade400),
        const SizedBox(width: 16),
        _metricTile("STREAK", "$streak Days", Colors.orange.shade400),
      ],
    );
  }

  Widget _metricTile(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, {Widget? trailing, VoidCallback? onTap, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : const Color(0xFFE67598), size: 22),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDestructive ? Colors.redAccent : Colors.black87)),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

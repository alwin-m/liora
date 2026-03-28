import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';
import 'package:lioraa/Screens/your_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/cycle_session.dart';
import '../core/cycle_algorithm.dart';
import '../core/notification_service.dart';
import '../core/app_theme.dart';

import '../Screens/change_password_screen.dart';
import '../Screens/my_orders_screen.dart';
import '../Screens/about_screen.dart';
import '../Screens/Login_Screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late CycleAlgorithm algo;

  String userName = "User";
  bool periodReminder = true;

  String? avatarBase64;

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

    _loadUser();
    _loadSettings();
    _loadAvatar();
  }

  // ================= LOAD USER =================

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()!.containsKey('name')) {
      setState(() {
        userName = doc['name'];
      });
    }
  }

  // ================= EDIT NAME =================

  Future<void> _editNameDialog() async {
    final controller = TextEditingController(text: userName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: LioraColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Edit Your Name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LioraColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      final newName = controller.text.trim();

                      if (newName.isEmpty) return;

                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) return;

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'name': newName});

                      setState(() {
                        userName = newName;
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Name Updated Successfully 💖"),
                        ),
                      );
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= AVATAR STORAGE =================

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      avatarBase64 = prefs.getString('profile_avatar');
    });
  }

  Future<void> _saveAvatar(String base64) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_avatar', base64);
  }

  Future<void> _removeAvatar() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('profile_avatar');

    setState(() {
      avatarBase64 = null;
    });
  }

  // ================= PICK IMAGE =================

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Optimize quality for local storage
    );

    if (picked == null) return;

    // Use cross-platform readAsBytes (works on web & mobile)
    final bytes = await picked.readAsBytes();

    final base64 = base64Encode(bytes);

    await _saveAvatar(base64);

    setState(() {
      avatarBase64 = base64;
    });
  }

  // ================= DEFAULT AVATAR =================

  Future<void> _selectDefaultAvatar(String asset) async {
    final bytes = await rootBundle.load(asset);

    final base64 = base64Encode(bytes.buffer.asUint8List());

    await _saveAvatar(base64);

    setState(() {
      avatarBase64 = base64;
    });
  }

  // ================= AVATAR OPTIONS =================

  void _showAvatarOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Profile Photo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),

            ListTile(
              leading: const Icon(Icons.face),
              title: const Text("Select Default Avatar"),
              onTap: () {
                Navigator.pop(context);
                _showDefaultAvatars();
              },
            ),

            if (avatarBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDefaultAvatars() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Avatar"),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: defaultAvatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  _selectDefaultAvatar(defaultAvatars[index]);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: LioraColors.primaryLight,
                  backgroundImage: AssetImage(defaultAvatars[index]),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // ================= REMINDER =================

  Future<void> _loadSettings() async {
    setState(() {
      periodReminder = true;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      periodReminder = value;
    });

    if (value) {
      final nextPeriod = CycleSession.algorithm.getNextPeriodDate();

      await NotificationService.reschedulePeriodReminder(nextPeriod);
    } else {
      await NotificationService.cancelPeriodReminder();
    }
  }

  // ================= AUTH =================

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ✅ FIXED: Added confirmation dialog + error handling
  Future<void> _deleteAccount() async {
    // Step 1 — Confirm before doing anything
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Step 2 — Delete Firestore doc
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Step 3 — Delete Auth account
      await user.delete();

      // Step 4 — Navigate to login
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handles case where user logged in too long ago
      if (e.code == 'requires-recent-login' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please log out and log back in, then try deleting again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final nextPeriod = algo.getNextPeriodDate();
    final confidence = (algo.confidenceScore * 100).toInt();

    return Scaffold(
      backgroundColor: LioraColors.bgLight,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),

          child: Column(
            children: [
              _profileHeader(nextPeriod, confidence),

              const SizedBox(height: 25),

              _notificationCard(),

              const SizedBox(height: 25),

              _educationalSection(),

              const SizedBox(height: 25),

              _settingsSection(),

              const SizedBox(height: 30),

              const Text("Liora v1.0.0", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _profileHeader(DateTime nextPeriod, int confidence) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LioraColors.primary.withOpacity(0.3),
            LioraColors.kittenBlue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: LioraColors.primary.withOpacity(0.1)),
      ),

      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: LioraColors.primary,

                backgroundImage: avatarBase64 != null
                    ? MemoryImage(base64Decode(avatarBase64!))
                    : null,

                child: avatarBase64 == null
                    ? const Icon(Icons.person, size: 45, color: Colors.white)
                    : null,
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showAvatarOptions,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: LioraColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, $userName",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 6),

              GestureDetector(
                onTap: _editNameDialog,
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: LioraColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text("Cycle Health Score: $confidence%"),
          Text(
            "Next Period: ${nextPeriod.day}/${nextPeriod.month}/${nextPeriod.year}",
          ),
        ],
      ),
    );
  }

  // ================= NOTIFICATION =================

  Widget _notificationCard() {
    return SwitchListTile(
      value: periodReminder,
      activeThumbColor: LioraColors.primary,
      title: const Text("Period Reminder"),
      onChanged: _toggleReminder,
    );
  }

  // ================= EDUCATION =================

  Widget _educationalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📚 Menstrual Health Facts",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LioraColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        _educationCard(
          "Why Track Your Cycle?",
          "Regular menstrual cycles indicate your body is working normally. Tracking helps identify irregularities that may signal health conditions like PCOS, thyroid disease, or endometriosis. Early detection enables preventive care.",
          "Harvard Health, WHO",
        ),
        const SizedBox(height: 10),
        _educationCard(
          "What Counts as Irregular?",
          "Cycles shorter than 21 days or longer than 35 days, fewer than 8 cycles per year, or any cycle over 90 days may indicate a problem. Consult a healthcare provider about your specific pattern.",
          "World Health Organization",
        ),
        const SizedBox(height: 10),
        _educationCard(
          "Conditions to Monitor",
          "Menstrual irregularities can signal PCOS, thyroid disorders, endometriosis, or diabetes. Without monitoring, these may lead to bone loss, anemia, or infertility. Regular tracking enables early intervention.",
          "Harvard Health, WHO",
        ),
        const SizedBox(height: 10),
        _educationCard(
          "Prevention & Management",
          "Lifestyle changes are most effective: regular exercise, healthy diet, stress management, and maintaining a healthy weight. Even a 10% weight loss can improve cycle regularity. Consult your doctor for personalized advice.",
          "World Health Organization",
        ),
      ],
    );
  }

  Widget _educationCard(String title, String description, String source) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? LioraColors.surfaceDark.withOpacity(0.7) : Colors.white,
        border: Border.all(
          color: LioraColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: LioraColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: LioraColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Source: $source",
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SETTINGS =================

  Widget _settingsSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text("Change Password"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
        ),

        ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: const Text("My Orders"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text("Your Details"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const YourDetailsScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text("About"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          },
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red)),
          onTap: _logout,
        ),

        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text(
            "Delete Account",
            style: TextStyle(color: Colors.red),
          ),
          onTap: _deleteAccount,
        ),
      ],
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADDED
import 'package:lioraa/Screens/login_screen.dart'; // ✅ ADDED
import 'package:lioraa/Screens/change_password_screen.dart'; // ✅ ADDED
import 'package:lioraa/core/cycle_session.dart';
import 'package:lioraa/home/cycle_algorithm.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool cycleReminders = true;
  bool periodAlerts = true;
  bool cartUpdates = false;

  late final CycleAlgorithm algo;

  @override
  void initState() {
    super.initState();
    algo = CycleSession.algorithm;
  }

  void _openSettingsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFCF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              _SettingsItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: _logout,
              ),

              _SettingsItem(
                icon: Icons.delete_outline,
                title: 'Delete account',
                isDestructive: true,
                onTap: _deleteAccount,
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔐 LOGOUT
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // 🗑 DELETE ACCOUNT
  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please re-login before deleting account"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPeriod = algo.getNextPeriodDate();
    final daysLeft = nextPeriod.difference(DateTime.now()).inDays;
    final endPeriod =
        nextPeriod.add(Duration(days: algo.periodLength - 1));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔒 UI BELOW UNCHANGED

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LIORA',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: _openSettingsPopup,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              Row(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF4C7D8),
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 48,
                        color: Color(0xFFE67598),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome, User!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Here’s your gentle overview today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'Today · 14 January 2026',
                style: TextStyle(fontSize: 13, color: Color(0xFF6F6152)),
              ),

              const SizedBox(height: 32),

              _InfoCard(
                title: 'Next cycle',
                mainText: 'In $daysLeft days',
                subText:
                    'Expected around ${nextPeriod.day} ${_month(nextPeriod.month)} – ${endPeriod.day} ${_month(endPeriod.month)}',
                highlight: true,
                onTap: () {},
              ),

              const SizedBox(height: 16),

              _CardContainer(
                title: 'Notifications',
                child: Column(
                  children: [
                    _ToggleRow(
                      title: 'Cycle reminders',
                      subtitle: 'Gentle nudges about your cycle phases',
                      value: cycleReminders,
                      onChanged: (v) => setState(() => cycleReminders = v),
                    ),
                    _ToggleRow(
                      title: 'Upcoming period alerts',
                      subtitle: '2–3 days before your expected period',
                      value: periodAlerts,
                      onChanged: (v) => setState(() => periodAlerts = v),
                    ),
                    _ToggleRow(
                      title: 'Cart & order updates',
                      subtitle: 'When items ship or arrive',
                      value: cartUpdates,
                      onChanged: (v) => setState(() => cartUpdates = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _month(int m) {
    const months = [
      "", "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[m];
  }

  // ALL UI WIDGETS BELOW UNCHANGED

  Widget _SettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? const Color(0xFFE67598) : Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? const Color(0xFFE67598) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoCard({
    required String title,
    required String mainText,
    required String subText,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFF4C7D8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE8DFCE),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6F6152),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mainText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6F6152),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _CardContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8DFCE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _ToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6152),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE67598),
          ),
        ],
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lioraa/Screens/login_screen.dart';
import 'package:lioraa/Screens/change_password_screen.dart';
import 'package:lioraa/Screens/my_orders_screen.dart';
import 'package:lioraa/core/cycle_session.dart';
import 'package:lioraa/home/cycle_algorithm.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool cycleReminders = true;
  bool periodAlerts = true;
  bool cartUpdates = false;

  late final CycleAlgorithm algo;
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    algo = CycleSession.algorithm;
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
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

  void _openSettingsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFCF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚙️ Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: _logout,
              ),
              _SettingsItem(
                icon: Icons.delete_outline,
                title: 'Delete account',
                isDestructive: true,
                onTap: _deleteAccount,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await user.delete();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please re-login before deleting account"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayText = 'Today · ${now.day} ${_month(now.month)} ${now.year}';

    final nextPeriod = algo.getNextPeriodDate();
    final daysLeft = nextPeriod
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final endPeriod =
        nextPeriod.add(Duration(days: algo.periodLength - 1));

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFADADD), Color(0xFFE6E6FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFFE67598),
          ),
        ),
        centerTitle: true,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Color(0xFF6F6152)),
            onPressed: _openSettingsPopup,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),

            // 🌸 Profile Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFADADD), Color(0xFFE6E6FA)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade100.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: 0.6,
                          strokeWidth: 6,
                          color: const Color(0xFFE67598),
                          backgroundColor:
                              const Color(0xFFF4C7D8),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_outline,
                            size: 48,
                            color: Color(0xFFE67598)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Here’s your gentle overview today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              todayText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6F6152),
              ),
            ),

            const SizedBox(height: 32),

            _InfoCard(
              title: '🌙 Next cycle',
              mainText:
                  daysLeft <= 0 ? 'Today' : 'In $daysLeft days',
              subText:
                  'Expected around ${nextPeriod.day} ${_month(nextPeriod.month)} – '
                  '${endPeriod.day} ${_month(endPeriod.month)}',
              highlight: true,
              onTap: () {},
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyOrdersScreen(),
                  ),
                );
              },
              child: _CardContainer(
                title: '📦 My Orders',
                child: Row(
                  children: const [
                    Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFFE67598)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'View all your orders',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F6152),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: Color(0xFF6F6152)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _CardContainer(
              title: '🔔 Notifications',
              child: Column(
                children: [
                  _ToggleRow(
                    title: 'Cycle reminders',
                    subtitle:
                        'Gentle nudges about your cycle phases',
                    value: cycleReminders,
                    onChanged: (v) =>
                        setState(() => cycleReminders = v),
                  ),
                  _ToggleRow(
                    title: 'Upcoming period alerts',
                    subtitle:
                        '2–3 days before your expected period',
                    value: periodAlerts,
                    onChanged: (v) =>
                        setState(() => periodAlerts = v),
                  ),
                  _ToggleRow(
                    title: 'Cart & order updates',
                    subtitle:
                        'When items ship or arrive',
                    value: cartUpdates,
                    onChanged: (v) =>
                        setState(() => cartUpdates = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m];
  }

  // ---------- REUSABLE WIDGETS ----------

  Widget _SettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.pinkAccent.withOpacity(0.15),
              child: Icon(icon,
                  color: Colors.pinkAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? const Color(0xFFE67598)
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoCard({
    required String title,
    required String mainText,
    required String subText,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: highlight
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFADADD),
                    Color(0xFFF4C7D8)
                  ],
                )
              : null,
          color: highlight ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.pink.shade100.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE8DFCE),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6F6152),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mainText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE67598),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6F6152),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _CardContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.pink.shade100.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8DFCE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE67598),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _ToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F6152),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6152),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE67598),
            inactiveTrackColor:
                const Color(0xFFF4C7D8),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lioraa/Screens/login_screen.dart';
import 'package:lioraa/Screens/change_password_screen.dart';
import 'package:lioraa/Screens/my_orders_screen.dart';
import 'package:lioraa/core/cycle_session.dart';
import 'package:lioraa/home/cycle_algorithm.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool cycleReminders = true;
  bool periodAlerts = true;
  bool cartUpdates = false;

  late final CycleAlgorithm algo;
  String userName = 'User';
  int _settingsTabIndex = 0; // 0 = Settings, 1 = About

  @override
  void initState() {
    super.initState();
    algo = CycleSession.algorithm;
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
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

  void _openSettingsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDFCF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (context, scrollController) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ListView(
                controller: scrollController,
                children: [
                  // =====================
                  // TAB NAVIGATION
                  // =====================
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _settingsTabIndex = 0);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '⚙️ Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _settingsTabIndex == 0
                                      ? const Color(0xFFE67598)
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_settingsTabIndex == 0)
                                Container(
                                  height: 3,
                                  color: const Color(0xFFE67598),
                                  width: 40,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _settingsTabIndex = 1);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ℹ️ About',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _settingsTabIndex == 1
                                      ? const Color(0xFFE67598)
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_settingsTabIndex == 1)
                                Container(
                                  height: 3,
                                  color: const Color(0xFFE67598),
                                  width: 40,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // =====================
                  // SETTINGS TAB
                  // =====================
                  if (_settingsTabIndex == 0)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Change password',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        _SettingsItem(
                          icon: Icons.logout,
                          title: 'Log out',
                          onTap: _logout,
                        ),
                        _SettingsItem(
                          icon: Icons.delete_outline,
                          title: 'Delete account',
                          isDestructive: true,
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),

                  // =====================
                  // ABOUT TAB
                  // =====================
                  if (_settingsTabIndex == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutSection(
                          title: '🌸 About Liora',
                          content:
                              'Liora is a mobile application designed to support women\'s menstrual health and overall wellness. We help you track your cycles, understand your patterns, and access wellness products all in one place.',
                        ),
                        const SizedBox(height: 16),
                        _AboutSection(
                          title: '🎯 Our Mission',
                          content:
                              'Empower women by helping them stay aware of their menstrual cycles, providing a convenient platform for wellness products, and promoting self-care through technology.',
                        ),
                        const SizedBox(height: 16),
                        _AboutSection(
                          title: '✨ Key Features',
                          content:
                              '• Menstrual cycle tracking and logging\n• Future cycle prediction\n• Wellness e-commerce platform\n• Personalized wellness recommendations',
                        ),
                        const SizedBox(height: 16),
                        _AboutSection(
                          title: '🔒 Data Privacy',
                          content:
                              'Your data is your own. We use user-provided information only for cycle predictions and personalization. No physical or sensor-based data is collected. Your privacy and security are our priority.',
                        ),
                        const SizedBox(height: 16),
                        _AboutSection(
                          title: '⚠️ Medical Disclaimer',
                          content:
                              'Liora is not a medically approved application. Predictions are for informational purposes only and do not replace professional medical advice. Please consult healthcare professionals for medical concerns.',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.pink.shade100),
                          ),
                          child: const Center(
                            child: Text(
                              'Liora – A companion for menstrual awareness and women\'s wellness',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE67598),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await user.delete();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please re-login before deleting account"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayText = 'Today · ${now.day} ${_month(now.month)} ${now.year}';

    final nextPeriod = algo.getNextPeriodDate();
    final daysLeft = nextPeriod
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final endPeriod = nextPeriod.add(Duration(days: algo.periodLength - 1));

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFADADD), Color(0xFFE6E6FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFFE67598),
          ),
        ),
        centerTitle: true,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6F6152)),
            onPressed: _openSettingsPopup,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),

            // 🌸 Profile Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFADADD), Color(0xFFE6E6FA)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade100.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: 0.6,
                          strokeWidth: 6,
                          color: const Color(0xFFE67598),
                          backgroundColor: const Color(0xFFF4C7D8),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_outline,
                          size: 48,
                          color: Color(0xFFE67598),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Here’s your gentle overview today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              todayText,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6F6152)),
            ),

            const SizedBox(height: 32),

            _InfoCard(
              title: '🌙 Next cycle',
              mainText: daysLeft <= 0 ? 'Today' : 'In $daysLeft days',
              subText:
                  'Expected around ${nextPeriod.day} ${_month(nextPeriod.month)} – '
                  '${endPeriod.day} ${_month(endPeriod.month)}',
              highlight: true,
              onTap: () {},
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
              child: _CardContainer(
                title: '📦 My Orders',
                child: Row(
                  children: const [
                    Icon(Icons.shopping_bag_outlined, color: Color(0xFFE67598)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'View all your orders',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F6152),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF6F6152)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _CardContainer(
              title: '🔔 Notifications',
              child: Column(
                children: [
                  _ToggleRow(
                    title: 'Cycle reminders',
                    subtitle: 'Gentle nudges about your cycle phases',
                    value: cycleReminders,
                    onChanged: (v) => setState(() => cycleReminders = v),
                  ),
                  _ToggleRow(
                    title: 'Upcoming period alerts',
                    subtitle: '2–3 days before your expected period',
                    value: periodAlerts,
                    onChanged: (v) => setState(() => periodAlerts = v),
                  ),
                  _ToggleRow(
                    title: 'Cart & order updates',
                    subtitle: 'When items ship or arrive',
                    value: cartUpdates,
                    onChanged: (v) => setState(() => cartUpdates = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m];
  }

  // ---------- REUSABLE WIDGETS ----------

  Widget _SettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.pinkAccent.withValues(alpha: 0.15),
              child: Icon(icon, color: Colors.pinkAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? const Color(0xFFE67598) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoCard({
    required String title,
    required String mainText,
    required String subText,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: highlight
              ? const LinearGradient(
                  colors: [Color(0xFFFADADD), Color(0xFFF4C7D8)],
                )
              : null,
          color: highlight ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8DFCE), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6F6152),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mainText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE67598),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6F6152)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _CardContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8DFCE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE67598),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _ToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F6152),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6152),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFE67598),
            inactiveTrackColor: const Color(0xFFF4C7D8),
          ),
        ],
      ),
    );
  }

  // =====================
  // ABOUT SECTION WIDGET
  // =====================
  Widget _AboutSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DFCE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE67598),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6F6152),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

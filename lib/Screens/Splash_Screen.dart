import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../core/local_storage.dart';
import '../core/cycle_session.dart';
import '../core/security_service.dart';
import '../widgets/app_lock_sheet.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      // ❌ NOT LOGGED IN → Go to Signup
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/signup');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = (userDoc.data()?['role'] ?? 'user').toString();

      // 🔎 CHECK ONBOARDING COMPLETION
      final hasCompleted = await LocalStorage.isOnboardingCompleted();

      if (!mounted) return;

      // ❌ Onboarding NOT completed
      if (!hasCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingQuestionsScreen(),
          ),
        );
        return;
      }

      // 🔥 LOAD PROFILE INTO CYCLE ENGINE
      await CycleSession.loadFromLocalStorage();

      if (!mounted) return;

      // 🔐 APP LOCK SECURITY
      final isLockNeeded = await SecurityService.isLockEnabled();
      if (!isLockNeeded) {
        _continueToApp(role);
        return;
      }

      // SHOW BOTTOM SHEET FOR LOCK
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => AppLockSheet(
          onAuthenticated: () {
            Navigator.pop(context); // Close sheet
            _continueToApp(role);
          },
        ),
      );
    } catch (e) {
      debugPrint("Splash Error: $e");
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  void _continueToApp(String role) {
    if (!mounted) return;
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFBEAFF),
      body: Center(
        child: Text(
          "Liora",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

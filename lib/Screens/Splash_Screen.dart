/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // FIRST TIME USER
        Navigator.pushReplacementNamed(context, '/signup');
      } else {
        // USER ALREADY LOGGED IN
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFBEAFF),
      body: Center(
        child: Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),
      ),
    );
  }
}*/
/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // ⏱ Navigation after splash
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user == null) {
        Navigator.pushReplacementNamed(context, '/signup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBEAFF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite,
                    size: 80, color: Colors.pinkAccent),
                const SizedBox(height: 20),
                Text(
                  'Liora',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'care for your rhythm',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 ADDED

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // ⏱ Navigation after splash (🔥 UPDATED LOGIC)
    Timer(const Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      // 🔹 Not logged in
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // 🔹 Logged in → check role & profile
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'user';
      final profileCompleted = doc.data()?['profileCompleted'] ?? false;

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (profileCompleted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBEAFF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite,
                    size: 80, color: Colors.pinkAccent),
                const SizedBox(height: 20),
                Text(
                  'Liora',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'care for your rhythm',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

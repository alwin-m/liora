import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/cycle_provider.dart';
import '../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _fadeOutController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _fadeOutAnim;
  late final Animation<double> _subtitleSlideAnim;

  @override
  void initState() {
    super.initState();

    // Logo entrance animation (fast)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnim = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Exit animation
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _logoController.forward();

    // Begin navigation logic immediately (splash is purely cosmetic)
    _navigate();
  }

  Future<void> _navigate() async {
    // Give the logo animation time to breathe (min 900ms)
    final stopwatch = Stopwatch()..start();

    String route = '/login';

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final role = doc.data()?['role'] ?? 'user';
        final profileCompleted = doc.data()?['profileCompleted'] ?? false;

        if (role == 'admin') {
          route = '/admin';
        } else if (profileCompleted) {
          // Pre-load cycle data in parallel
          if (mounted) {
            await Provider.of<CycleProvider>(context, listen: false).loadData();
          }
          route = '/home';
        } else {
          route = '/onboarding';
        }
      }
    } catch (_) {
      route = '/login';
    }

    // Ensure minimum splash duration for smooth UX
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 900) {
      await Future.delayed(Duration(milliseconds: 900 - elapsed));
    }

    if (!mounted) return;

    // Smooth fade out before navigating
    await _fadeOutController.forward();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeOutAnim,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primaryContainer.withAlpha(100), cs.surface],
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated icon with gradient background
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [cs.primary, cs.secondary],
                            ),
                            borderRadius: BorderRadius.circular(
                              LioraTheme.radiusCard,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: LioraTheme.space24),

                        Text(
                          'Liora',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),

                        Transform.translate(
                          offset: Offset(0, _subtitleSlideAnim.value),
                          child: Opacity(
                            opacity: _fadeAnim.value,
                            child: Text(
                              'care for your rhythm',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: cs.onSurface.withAlpha(140),
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

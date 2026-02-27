import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/cycle_provider.dart';
import '../core/app_theme.dart';

/// Optimized splash screen — Luxury Minimal.
/// - Off-white background with Rose Clay logo
/// - Soft Sage tagline
/// - Smooth 600ms entrance animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _subtitleFade;

  static const _minVisibleMs = 700;
  static const _entranceDurationMs = 550;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _entranceDurationMs),
    );

    // scale: 0.88 → 1.0
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // full fade: 0 → 1 in first 65% of animation
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // subtitle fades in during last 50%
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Run auth check and animation in parallel
    final sw = Stopwatch()..start();
    _ctrl.forward();
    _navigate(sw);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _navigate(Stopwatch sw) async {
    String route = '/login';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Parallel: pre-load cycle data + fetch user role at the same time
        final results = await Future.wait([
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 5)),
          if (mounted)
            Provider.of<CycleProvider>(
              context,
              listen: false,
            ).loadData().then((_) => null),
        ]);

        final doc = results[0] as DocumentSnapshot?;
        if (doc != null && doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final role = data['role'] ?? 'user';
          final profileCompleted = data['profileCompleted'] ?? false;

          if (role == 'admin') {
            route = '/admin';
          } else if (profileCompleted == true) {
            route = '/home';
          } else {
            route = '/onboarding';
          }
        }
      }
    } catch (_) {
      // Offline / network error → gracefully fall back to login
      route = '/login';
    }

    // Guarantee minimum splash visibility for smooth UX
    final elapsed = sw.elapsedMilliseconds;
    if (elapsed < _minVisibleMs) {
      await Future<void>.delayed(
        Duration(milliseconds: _minVisibleMs - elapsed),
      );
    }

    if (!mounted) return;
    // Smooth fade-out of the animation controller before navigate
    await _ctrl.reverse(from: 0.3).orCancel.catchError((_) {});
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Off-white background per luxury minimal spec
      backgroundColor: LioraTheme.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Subtle Rose Clay tint at top, fading to off-white
              LioraTheme.roseClay.withAlpha(25),
              LioraTheme.primaryBackground,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _fade.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand icon — Rose Clay gradient
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            LioraTheme.roseClay,
                            LioraTheme.roseClayLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          LioraTheme.radiusCard,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: LioraTheme.roseClay.withAlpha(40),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: LioraTheme.space24),

                    Text(
                      'Liora',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        color: LioraTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: LioraTheme.space8),

                    // Tagline in Soft Sage
                    Opacity(
                      opacity: _subtitleFade.value,
                      child: Text(
                        'care for your rhythm',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: LioraTheme.softSage,
                          letterSpacing: 1.4,
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
  }
}

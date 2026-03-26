import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lioraa/onboarding/onboarding_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState
    extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  bool isChecking = true;
  int resendCooldown = 0;

  Timer? timer;
  Timer? cooldownTimer;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _animationController.forward();

    isEmailVerified =
        FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    cooldownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail = false;
        resendCooldown = 30;
      });

      cooldownTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          resendCooldown--;
        });

        if (resendCooldown <= 0) {
          timer.cancel();
          setState(() {
            canResendEmail = true;
          });
        }
      });
    } catch (_) {}
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser!;

    setState(() {
      isEmailVerified = user.emailVerified;
      isChecking = false;
    });

    if (isEmailVerified) {
      timer?.cancel();

      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const OnboardingQuestionsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDEBFF),
              Color(0xFFFADADD),
              Color(0xFFE6E6FA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius:
                      BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12
                          .withOpacity(0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Icon(
                      isEmailVerified
                          ? Icons.verified_rounded
                          : Icons.mark_email_unread_rounded,
                      size: 70,
                      color: const Color(0xFFE67598),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Verify Your Email",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE67598),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isEmailVerified
                          ? "Email successfully verified!"
                          : "We’ve sent a verification link to your email.\nPlease verify to continue.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (isChecking)
                      const CircularProgressIndicator(
                        color: Color(0xFFE67598),
                      ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: checkEmailVerified,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE67598),
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                      ),
                      child: const Text(
                        "I Have Verified",
                        style: TextStyle(
                            fontWeight:
                                FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed:
                          canResendEmail ? sendVerificationEmail : null,
                      child: Text(
                        canResendEmail
                            ? "Resend Email"
                            : "Resend in $resendCooldown s",
                        style: const TextStyle(
                          color: Color(0xFFE67598),
                          fontWeight:
                              FontWeight.w500,
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
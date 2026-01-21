import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../core/components.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      showCalmSnackBar(
        context,
        message: 'Please fill in all fields',
        icon: Icons.info_outline,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showCalmSnackBar(
        context,
        message: 'Passwords do not match',
        icon: Icons.error_outline,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      showCalmSnackBar(
        context,
        message: 'Password must be at least 6 characters',
        icon: Icons.error_outline,
      );
      return;
    }

    if (!_agreedToTerms) {
      showCalmSnackBar(
        context,
        message: 'Please agree to terms and conditions',
        icon: Icons.info_outline,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth user
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'profileCompleted': false,
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;

      // Navigate to onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } on FirebaseAuthException catch (e) {
      showCalmSnackBar(
        context,
        message: e.message ?? 'Signup failed',
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.xl),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: AppTheme.roundedLg,
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.favorite,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.lg),
                      Text(
                        'Create Account',
                        style: AppTheme.displayMedium,
                      ),
                      const SizedBox(height: AppTheme.md),
                      Text(
                        'Start your wellness journey with Liora',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.xl),

                // Name field
                MinimalTextField(
                  label: 'Full Name',
                  hintText: 'John Doe',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: AppTheme.lg),

                // Email field
                MinimalTextField(
                  label: 'Email',
                  hintText: 'your@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                ),

                const SizedBox(height: AppTheme.lg),

                // Password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: AppTheme.labelMedium,
                    ),
                    const SizedBox(height: AppTheme.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: AppTheme.roundedMd,
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppTheme.primary,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.lg,
                            vertical: AppTheme.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.lg),

                // Confirm password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password',
                      style: AppTheme.labelMedium,
                    ),
                    const SizedBox(height: AppTheme.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: AppTheme.roundedMd,
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: AppTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppTheme.primary,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            child: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.lg,
                            vertical: AppTheme.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.lg),

                // Terms checkbox
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToTerms = !_agreedToTerms;
                        });
                      },
                      child: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: _agreedToTerms
                              ? AppTheme.primary
                              : AppTheme.surfaceContainer,
                          border: Border.all(
                            color: _agreedToTerms
                                ? AppTheme.primary
                                : AppTheme.surfaceContainerHigh,
                            width: 1.5,
                          ),
                          borderRadius: AppTheme.roundedSm,
                        ),
                        child: _agreedToTerms
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'I agree to ',
                              style: AppTheme.bodySmall,
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.xxl),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: MinimalButton(
                    label: 'Create Account',
                    onPressed: _handleSignup,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: AppTheme.lg),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Sign In',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

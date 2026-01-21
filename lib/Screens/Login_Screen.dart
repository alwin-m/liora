import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../core/components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showCalmSnackBar(
        context,
        message: 'Please fill in all fields',
        icon: Icons.info_outline,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Authenticate user
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch user role and profile status
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      final role = userDoc['role'] ?? 'user';
      final profileCompleted = userDoc['profileCompleted'] ?? false;

      if (!mounted) return;

      // Role-based navigation
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (profileCompleted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } on FirebaseAuthException catch (e) {
      showCalmSnackBar(
        context,
        message: e.message ?? 'Login failed',
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
                const SizedBox(height: AppTheme.xxl),

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
                        'Welcome Back',
                        style: AppTheme.displayMedium,
                      ),
                      const SizedBox(height: AppTheme.md),
                      Text(
                        'Sign in to continue your wellness journey',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.xxl),

                // Email field
                MinimalTextField(
                  label: 'Email',
                  hintText: 'your@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                ),

                const SizedBox(height: AppTheme.lg),

                // Password field with toggle
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

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password
                      showCalmSnackBar(
                        context,
                        message: 'Password reset coming soon',
                        icon: Icons.hourglass_empty_outlined,
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.xxl),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: MinimalButton(
                    label: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: AppTheme.lg),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.surfaceContainerHigh,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.md,
                      ),
                      child: Text(
                        'New to Liora?',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.surfaceContainerHigh,
                        height: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.lg),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: Text(
                          'Create one',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/liora_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Sign Up Screen - Create Account with Care
///
/// Gentle onboarding into the LIORA ecosystem
/// Soft validation and encouraging feedback
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final authProvider = context.read<AuthProvider>();

    // Use auth provider's validation
    final validationError = authProvider.validateSignUpInputs(
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (validationError != null) {
      // Show validation error by calling signUp which will set the error
      return;
    }

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _confirmPasswordController.text,
      displayName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LioraColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Back Button
                    _buildBackButton(),

                    const SizedBox(height: 20),

                    // Header
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Form
                    _buildForm(),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    _buildSignUpButton(),

                    const SizedBox(height: 24),

                    // Sign In Link
                    _buildSignInLink(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: LioraShadows.soft,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: LioraColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Create Account',
          style: LioraTextStyles.h2,
        ),
        const SizedBox(height: 8),
        Text(
          'Begin your wellness journey with LIORA',
          style: LioraTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Name Field (Optional)
              AuthTextField(
                controller: _nameController,
                label: 'Name (optional)',
                hint: 'How should we call you?',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Email Field
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Password Field
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'At least 6 characters',
                isPassword: true,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: '••••••••',
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
                validator: _validateConfirmPassword,
              ),

              // Error Message (if any)
              if (authProvider.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(authProvider.error!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LioraColors.error.withOpacity(0.3),
        borderRadius: BorderRadius.circular(LioraRadius.large),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: LioraColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: LioraTextStyles.bodySmall.copyWith(
                color: LioraColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AuthButton(
          label: 'Create Account',
          onPressed: _signUp,
          isLoading: authProvider.isLoading,
        );
      },
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: LioraTextStyles.bodyMedium,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Sign in',
            style: LioraTextStyles.label.copyWith(
              color: LioraColors.deepRose,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final authProvider = context.read<AuthProvider>();
    return authProvider.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final authProvider = context.read<AuthProvider>();
    return authProvider.validatePassword(value);
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
